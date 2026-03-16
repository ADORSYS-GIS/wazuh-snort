#!/usr/bin/env bash

set -euo pipefail

COMMON="/tmp/common.sh"

if [[ ! -f "$COMMON" ]]; then
  curl -fsSL https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/refactor/split-linux-macos-scripts/scripts/shared/common.sh -o "$COMMON"
fi

source "$COMMON"

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


validate_uninstallation() {
    if command_exists snort; then
        error_message "Snort is still installed. Uninstallation failed."
        exit 1
    fi

    if [[ -d "/etc/snort" ]]; then
        error_message "Snort directory /etc/snort still exists. Uninstallation incomplete."
        exit 1
    fi

    if [[ -d "/var/log/snort" ]]; then
        error_message "Snort log directory /var/log/snort still exists. Uninstallation incomplete."
        exit 1
    fi

    success_message "Snort successfully uninstalled"
    return 0
}

uninstall_snort() {
    info_message "Uninstalling Snort"
    if command -v apt >/dev/null 2>&1; then
        sudo apt-get purge -y snort snort-common snort-common-libraries snort-rules-default && sudo apt-get autoremove -y
    else
        warn_message "This script supports only Debian-based systems for uninstallation."
    fi

    remove_snort_dirs_files \
        "/etc/snort/" \
        "/var/log/snort"

    validate_uninstallation
    success_message "Snort uninstalled"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${0}" == *"uninstall.sh" ]]; then
    uninstall_snort
fi
