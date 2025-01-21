#!/bin/bash

# Check if we're running in bash; if not, adjust behavior
if [ -n "$BASH_VERSION" ]; then
    set -euo pipefail
else
    set -eu
fi

# Define text formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
BOLD='\033[1m'
NORMAL='\033[0m'

# Logging functions
log() {
    local LEVEL="$1"
    shift
    local MESSAGE="$*"
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${TIMESTAMP} ${LEVEL} ${MESSAGE}"
}

info_message() {
    log "${BLUE}${BOLD}[INFO]${NORMAL}" "$*"
}

warn_message() {
    log "${YELLOW}${BOLD}[WARNING]${NORMAL}" "$*"
}

success_message() {
    log "${GREEN}${BOLD}[SUCCESS]${NORMAL}" "$*"
}

error_message() {
    log "${RED}${BOLD}[ERROR]${NORMAL}" "$*"
}

# Determine OS-specific paths
OS_NAME=$(uname)
if [[ $OS_NAME == "Linux" ]]; then
    SNORT_CONF_PATH="/etc/snort/snort.conf"
    SNORT_SERVICE="snort"
    RULES_DIR="/etc/snort/rules"
    LOG_DIR="/var/log/snort"
elif [[ $OS_NAME == "Darwin" ]]; then
    ARCH=$(uname -m)
    if [[ $ARCH == "arm64" ]]; then
        SNORT_CONF_PATH="/opt/homebrew/etc/snort/snort.lua"
    else
        SNORT_CONF_PATH="/usr/local/etc/snort/snort.lua"
    fi
    SNORT_SERVICE="snort"
    RULES_DIR="/usr/local/etc/rules"
    LOG_DIR="/var/log/snort"
else
    error_message "Unsupported operating system."
    exit 1
fi

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

maybe_sudo() {
    if [ "$(id -u)" -ne 0 ]; then
        if command_exists sudo; then
            sudo "$@"
        else
            error_message "Root privileges required. Run with sudo."
            exit 1
        fi
    else
        "$@"
    fi
}

sed_alternative() {
    if command_exists gsed; then
        maybe_sudo gsed "$@"
    else
        maybe_sudo sed "$@"
    fi
}

remove_snort() {
    if command_exists snort; then
        info_message "Removing Snort package..."
        if [[ $OS_NAME == "Linux" ]]; then
            maybe_sudo apt-get remove --purge -y snort snort-common snort-common-libraries snort-rules-default
            maybe_sudo apt-get autoremove -y
        elif [[ $OS_NAME == "Darwin" ]]; then
            brew uninstall snort || warn_message "Snort may not be installed via Homebrew."
        fi
        success_message "Snort package removed."
    else
        warn_message "Snort is not installed. Skipping removal."
    fi
}

clean_snort_files() {
    info_message "Cleaning Snort configuration and logs..."
    maybe_sudo rm -rf "$SNORT_CONF_PATH" "$RULES_DIR" "$LOG_DIR"
    info_message "Snort configuration and logs removed."
}

remove_ossec_snort_integration() {
    local OSSEC_CONF_PATH
    if [[ $OS_NAME == "Linux" ]]; then
        OSSEC_CONF_PATH="/var/ossec/etc/ossec.conf"
    elif [[ $OS_NAME == "Darwin" ]]; then
        OSSEC_CONF_PATH="/Library/Ossec/etc/ossec.conf"
    fi
    
    if [ -f "$OSSEC_CONF_PATH" ]; then
        sed_alternative -i '/<!-- snort -->/,/<\/localfile>/d' "$OSSEC_CONF_PATH"
        info_message "Snort integration removed from OSSEC configuration."
    else
        warn_message "OSSEC configuration file not found. Skipping OSSEC cleanup."
    fi
}

stop_snort_service() {
    if command_exists systemctl && systemctl is-active --quiet "$SNORT_SERVICE"; then
        info_message "Stopping Snort service..."
        maybe_sudo systemctl stop "$SNORT_SERVICE"
        maybe_sudo systemctl disable "$SNORT_SERVICE"
        info_message "Snort service stopped and disabled."
    else
        warn_message "Snort service is not running or systemctl is unavailable. Skipping."
    fi
}

uninstall_snort() {
    stop_snort_service
    remove_snort
    clean_snort_files
    remove_ossec_snort_integration
    success_message "Snort uninstallation completed successfully."
}

# Start the uninstallation
uninstall_snort
