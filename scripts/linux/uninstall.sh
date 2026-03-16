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
    if command -v apt >/dev/null 2>&1; then
        sudo apt-get purge -y snort snort-common snort-common-libraries snort-rules-default && sudo apt-get autoremove -y
    else
        warn_message "This script supports only Debian-based systems for uninstallation."
    fi

    remove_snort_dirs_files \
        "/etc/snort/" \
        "/var/log/snort"

    revert_ossec_conf "$OSSEC_CONF_PATH"
    success_message "Snort uninstalled"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    uninstall_snort
fi
