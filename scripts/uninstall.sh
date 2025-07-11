#!/bin/bash

# Check if we're running in bash; if not, adjust behavior
if [ -n "$BASH_VERSION" ]; then
    set -euo pipefail
else
    set -eu
fi

LOGGED_IN_USER=""

if [ "$(uname -s)" = "Darwin" ]; then
    LOGGED_IN_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ {print $3}')
fi

# Determine OS-specific paths
OS_NAME=$(uname)
if [[ $OS_NAME == "Linux" ]]; then
    OSSEC_CONF_PATH="/var/ossec/etc/ossec.conf"
elif [[ $OS_NAME == "Darwin" ]]; then
    OSSEC_CONF_PATH="/Library/Ossec/etc/ossec.conf"
else
    error_message "Unsupported operating system."
    exit 1
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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure root privileges, either directly or through sudo
maybe_sudo() {
    if [ "$(id -u)" -ne 0 ]; then
        if command_exists sudo; then
            sudo "$@"
        else
            error_message "This script requires root privileges. Please run with sudo or as root."
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

brew_command() {
    sudo -u "$LOGGED_IN_USER" brew "$@"
}

# Function to remove directories and files
remove_snort_dirs_files() {
    local dirs=("$@")
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            maybe_sudo rm -rf "$dir"
            info_message "Removed directory $dir"
        fi
    done
}

remove_snort_files() {
    local files=("$@")
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            maybe_sudo rm -f "$file"
            info_message "Removed file $file"
        fi
    done
}

# Function to revert changes in ossec.conf
revert_ossec_conf() {
    local ossec_conf="$1"
    local snort_tag="<!-- snort -->"

    if maybe_sudo [ -f "$ossec_conf" ]; then
        if maybe_sudo grep -q "$snort_tag" "$ossec_conf"; then
            sed_alternative -i "/$snort_tag/,/<\/localfile>/d" "$ossec_conf"
            info_message "Reverted changes in $ossec_conf"
        else
            info_message "No Snort-related changes found in $ossec_conf. Skipping"
        fi
    else
        warn_message "The file $ossec_conf no longer exists. Skipping"
    fi    
}

# Function to uninstall Snort on macOS
uninstall_snort_macos() {
    info_message "Uninstalling Snort on macOS"
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
    success_message "Snort uninstalled on macOS"
}

# Function to uninstall Snort on Linux
uninstall_snort_linux() {
    info_message "Uninstalling Snort on Linux"
    if command -v apt >/dev/null 2>&1; then
        sudo apt-get purge -y snort snort-common snort-common-libraries snort-rules-default && sudo apt-get autoremove -y
    else
        warn_message "This script supports only Debian-based systems for uninstallation."
    fi

    remove_snort_dirs_files \
        "/etc/snort/" \
        "/var/log/snort"

    revert_ossec_conf "$OSSEC_CONF_PATH"
    success_message "Snort uninstalled on Linux"
}

# Main logic: uninstall Snort based on the operating system
case "$OS_NAME" in
    Linux)
        uninstall_snort_linux
        ;;
    Darwin)
        uninstall_snort_macos
        ;;
    *)
        error_message "Unsupported OS: $OS_NAME"
        exit 1
        ;;
esac
