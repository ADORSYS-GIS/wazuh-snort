#!/usr/bin/env bash

set -euo pipefail

COMMON="/tmp/common.sh"

if [[ ! -f "$COMMON" ]]; then
  curl -fsSL https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/refactor/split-linux-macos-scripts/scripts/shared/common.sh -o "$COMMON"
fi

source "$COMMON"


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
}

configure_snort() {
    info_message "Configuring Snort"
    sed_alternative -i 's/output alert_fast: snort.alert.fast/output alert_fast: snort.alert/g' /etc/snort/snort.conf
    sed_alternative -i 's/# output alert_syslog: LOG_AUTH LOG_ALERT/output alert_syslog: LOG_AUTH LOG_ALERT/g' /etc/snort/snort.conf
    echo 'alert icmp any any -> any any (msg:"ICMP connection attempt:"; sid:1000010; rev:1;)' | maybe_sudo tee -a /etc/snort/rules/local.rules > /dev/null

    info_message "Downloading and configuring Snort rule files"
    maybe_sudo curl -SL --progress-bar -o community-rules.tar.gz https://www.snort.org/downloads/community/community-rules.tar.gz
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
    return 0
}

validate_installation() {
    validate_installation_common

    if [[ ! -f "/etc/snort/snort.conf" ]]; then
        error_message "Snort configuration file not found at /etc/snort/snort.conf"
        exit 1
    fi

    # Check if interface is present in snort.debian.conf file
    INTERFACE=$(ip route show default | awk '/default/ {print $5}' | head -1)
    if [[ -f "/etc/snort/snort.debian.conf" ]]; then
        CONFIG_INTERFACE=$(grep "DEBIAN_SNORT_INTERFACE" /etc/snort/snort.debian.conf | sed 's/.*"\([^"]*\)".*/\1/' | tr -d ' ')
        if [[ ! "$INTERFACE" =~ $CONFIG_INTERFACE ]]; then
            error_message "Interface $INTERFACE not found in snort.debian.conf (found: $CONFIG_INTERFACE)"
            exit 1
        fi
        success_message "Interface $INTERFACE found in snort.debian.conf"
    fi

    success_message "Snort configuration file found at /etc/snort/snort.conf"
    return 0
}
install_snort
