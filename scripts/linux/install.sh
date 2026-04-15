#!/usr/bin/env bash

if [[ -n "$BASH_VERSION" ]]; then
    set -euo pipefail
else
    set -eu
fi

# OS guard early in the script
if [[ "$(uname -s)" != "Linux" ]]; then
    printf "%s\n" "[ERROR] This installation script is intended for Linux systems. Please use the appropriate script for your operating system." >&2
    exit 1
fi

# Repository reference
WAZUH_SNORT_REPO_REF=${WAZUH_SNORT_REPO_REF:-"main"}
WAZUH_SNORT_REPO_URL="https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/${WAZUH_SNORT_REPO_REF}"

# Source shared utilities
TMP_DIR=$(mktemp -d)
if ! curl -fsSL "${WAZUH_SNORT_REPO_URL}/scripts/shared/common.sh" -o "$TMP_DIR/common.sh"; then
    echo "Failed to download common.sh"
    exit 1
fi

# Function to calculate SHA256 (cross-platform bootstrap)
calculate_sha256_bootstrap() {
    local file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
    else
        shasum -a 256 "$file" | awk '{print $1}'
    fi
    return 0
}

# Download checksums and verify common.sh integrity BEFORE sourcing it
if ! curl -fsSL "${WAZUH_SNORT_REPO_URL}/checksums.sha256" -o "$TMP_DIR/checksums.sha256"; then
    echo "Failed to download checksums.sha256"
    exit 1
fi

EXPECTED_HASH=$(grep "scripts/shared/common.sh" "$TMP_DIR/checksums.sha256" | awk '{print $1}')
ACTUAL_HASH=$(calculate_sha256_bootstrap "$TMP_DIR/common.sh")

if [[ -z "$EXPECTED_HASH" ]] || [[ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]]; then
    echo "Error: Checksum verification failed for common.sh" >&2
    echo "Expected hash: $EXPECTED_HASH" >&2
    echo "Actual hash: $ACTUAL_HASH" >&2
    exit 1
fi

# shellcheck disable=SC1091
. "$TMP_DIR/common.sh"

# Register cleanup to run on exit
trap cleanup EXIT

install_snort() {
    print_step "Installing" "Snort"

    INTERFACE=$(ip route show default | awk '/default/ {print $5}' | head -1)

    install_snort_apt() {
        sudo DEBIAN_FRONTEND=noninteractive apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install snort -y --no-install-recommends
    }

    if command_exists snort; then
        info_message "Snort is already installed. Skipping installation."
    else
        install_snort_apt
        info_message "Snort installed successfully"
    fi

    configure_debian_snort_interface() {
        if [[ ! -f /etc/snort/snort.debian.conf ]]; then
            echo "DEBIAN_SNORT_INTERFACE=\"$INTERFACE\"" | sudo tee -a /etc/snort/snort.debian.conf
        else
            sed_alternative -i "s/^DEBIAN_SNORT_INTERFACE=.*/DEBIAN_SNORT_INTERFACE=\"$INTERFACE\"/" /etc/snort/snort.debian.conf
        fi
        return 0
    }

    configure_snort_interface() {
        if [[ ! -f /etc/snort/snort.conf ]]; then
            echo "config interface: $INTERFACE" | sudo tee -a /etc/snort/snort.conf
        else
            sed_alternative -i "s/^config interface: .*/config interface: $INTERFACE/" /etc/snort/snort.conf
        fi
        return 0
    }

    if [[ -f /etc/debian_version ]]; then
        echo "This is a Debian-based OS. Configuring snort.debian.conf"
        configure_debian_snort_interface
    else
        echo "This is not a Debian-based OS. Configuring snort.conf"
        configure_snort_interface
    fi

    maybe_sudo systemctl restart snort || {
        echo "Failed to restart Snort. Check the configuration."
    }

    configure_snort

    start_snort

    validate_installation
    return $?
}

configure_snort() {
    info_message "Configuring Snort"
    sed_alternative -i 's/output alert_fast: snort.alert.fast/output alert_fast: snort.alert/g' /etc/snort/snort.conf
    sed_alternative -i 's/# output alert_syslog: LOG_AUTH LOG_ALERT/output alert_syslog: LOG_AUTH LOG_ALERT/g' /etc/snort/snort.conf
    echo 'alert icmp any any -> any any (msg:"ICMP connection attempt:"; sid:1000010; rev:1;)' | maybe_sudo tee -a /etc/snort/rules/local.rules > /dev/null

    info_message "Downloading and configuring Snort rule files"
    download_file https://www.snort.org/downloads/community/community-rules.tar.gz community-rules.tar.gz "snort community rules"
    maybe_sudo tar -xvzf community-rules.tar.gz -C /etc/snort/rules --strip-components=1
    maybe_sudo rm community-rules.tar.gz

    if ! maybe_sudo grep -q "include \$RULE_PATH/community.rules" /etc/snort/snort.conf; then
        echo "include \$RULE_PATH/community.rules" | maybe_sudo tee -a /etc/snort/snort.conf
        success_message "Snort rule files configured"
    fi
    return 0
}

start_snort() {
    info_message "Starting Snort"
    maybe_sudo systemctl restart snort
    success_message "Snort started"
    maybe_sudo snort -q -c /etc/snort/snort.conf -l /var/log/snort -A full &
    return $?
}

validate_installation() {
    validate_installation_common

    if [[ ! -f "/etc/snort/snort.conf" ]]; then
        error_exit "Snort configuration file not found at /etc/snort/snort.conf"
    fi

    # Check if interface is present in snort.debian.conf file
    INTERFACE=$(ip route show default | awk '/default/ {print $5}' | head -1)
    if [[ -f "/etc/snort/snort.debian.conf" ]]; then
        CONFIG_INTERFACE=$(grep "DEBIAN_SNORT_INTERFACE" /etc/snort/snort.debian.conf | sed 's/.*"\([^"]*\)".*/\1/' | tr -d ' ')
        if [[ ! "$INTERFACE" =~ $CONFIG_INTERFACE ]]; then
            error_exit "Interface $INTERFACE not found in snort.debian.conf (found: $CONFIG_INTERFACE)"
        fi
        success_message "Interface $INTERFACE found in snort.debian.conf"
    fi

    success_message "Snort configuration file found at /etc/snort/snort.conf"
    return 0
}
install_snort
