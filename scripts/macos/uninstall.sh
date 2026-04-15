#!/usr/bin/env bash

if [ -n "$BASH_VERSION" ]; then
    set -euo pipefail
else
    set -eu
fi

# OS guard early in the script
if [[ "$(uname -s)" != "Darwin" ]]; then
    printf "%s\n" "[ERROR] This installation script is intended for macOS systems. Please use the appropriate script for your operating system." >&2
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

LOGGED_IN_USER=""
if [[ "$(uname -s)" = "Darwin" ]]; then
    LOGGED_IN_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ {print $3}')
fi

brew_command() {
    if [[ -n "${LOGGED_IN_USER}" ]]; then
        sudo -u "${LOGGED_IN_USER}" brew "$@"
    else
        brew "$@"
    fi
    return 0
}

remove_snort_dirs_files() {
    local dirs=("$@")
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            maybe_sudo rm -rf "$dir"
            info_message "Removed directory $dir"
        fi
    done
    return 0
}

remove_snort_files() {
    local files=("$@")
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            maybe_sudo rm -f "$file"
            info_message "Removed file $file"
        fi
    done
    return 0
}


uninstall_snort() {
    info_message "Uninstalling Snort"
    brew_command uninstall snort || warn_message "Snort was not installed via Homebrew."

    remove_snort_dirs_files \
        "/usr/local/etc/rules" \
        "/usr/local/etc/so_rules" \
        "/usr/local/etc/lists" \
        "/var/log/snort"

    remove_snort_files \
        "/usr/local/etc/rules/local.rules" \ 
        "/usr/local/etc/lists/default.blocklist"

    validate_uninstallation

    success_message "Snort uninstalled"
/
validate_uninstallation() {
    if command_exists snort; then
        error_message "Snort is still installed. Uninstallation failed."
        exit 1
    fi

    if [[ -d "/usr/local/etc/rules" ]]; then
        error_message "Snort rules directory /usr/local/etc/rules still exists. Uninstallation incomplete."
        exit 1
    fi

    if [[ -d "/var/log/snort" ]]; then
        error_message "Snort log directory /var/log/snort still exists. Uninstallation incomplete."
        exit 1
    fi

    success_message "Snort successfully uninstalled"
    return 0
}

    return 0
}

uninstall_snort

