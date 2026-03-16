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

revert_ossec_conf() {
    local ossec_conf="$1"
    local snort_tag="<!-- snort -->"

    if maybe_sudo [[ -f "$ossec_conf" ]]; then
        if maybe_sudo grep -q "$snort_tag" "$ossec_conf"; then
            sed_alternative -i "/$snort_tag/,/<\/localfile>/d" "$ossec_conf"
            info_message "Reverted changes in $ossec_conf"
        else
            info_message "No Snort-related changes found in $ossec_conf. Skipping"
        fi
    else
        warn_message "The file $ossec_conf no longer exists. Skipping"
    fi
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

    revert_ossec_conf "$OSSEC_CONF_PATH"
    success_message "Snort uninstalled"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    uninstall_snort
fi
