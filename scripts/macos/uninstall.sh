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

