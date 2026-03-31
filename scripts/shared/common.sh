#!/usr/bin/env bash

# Common helpers sourced by OS-specific install/uninstall scripts

set -euo pipefail

APP_NAME=${APP_NAME:-"snort"}
SNORT_LAUNCH_DAEMON_FILE=${SNORT_LAUNCH_DAEMON_FILE:-"/Library/LaunchDaemons/com.adorsys.$APP_NAME.plist"}

LOGGED_IN_USER=""
if [[ "$(uname -s)" = "Darwin" ]]; then
    LOGGED_IN_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ {print $3}')
fi

# Define text formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
BOLD='\033[1m'
NORMAL='\033[0m'

log() {
    local LEVEL="$1"
    shift
    local MESSAGE="$*"
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${TIMESTAMP} ${LEVEL} ${MESSAGE}"
}

info_message() { log "${BLUE}${BOLD}[INFO]${NORMAL}" "$*"; }
warn_message() { log "${YELLOW}${BOLD}[WARNING]${NORMAL}" "$*"; }
error_message() { log "${RED}${BOLD}[ERROR]${NORMAL}" "$*"; }
success_message() { log "${GREEN}${BOLD}[SUCCESS]${NORMAL}" "$*"; }
print_step() { log "${BLUE}${BOLD}[STEP]${NORMAL}" "$1: $2"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

maybe_sudo() {
    if [[ "$(id -u)" -ne 0 ]]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo "$@"
        else
            error_message "This script requires root privileges. Please run with sudo or as root."
            exit 1
        fi
    else
        "$@"
    fi
    return 0
}

sed_alternative() {
    if command_exists gsed; then
        maybe_sudo gsed "$@"
    else
        maybe_sudo sed "$@"
    fi
    return 0
}

brew_command() {
    if [[ -n "${LOGGED_IN_USER}" ]]; then
        sudo -u "${LOGGED_IN_USER}" brew "$@"
    else
        brew "$@"
    fi
    return 0
}

create_snort_dirs_files() {
    local dirs=("$@")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            maybe_sudo mkdir -p "$dir"
            info_message "Created directory $dir"
        fi
    done
    return 0
}

create_file() {
    local filepath="$1"
    local content="$2"
    maybe_sudo bash -c "cat > \"$filepath\" <<EOF
$content
EOF"
    info_message "Created file: $filepath"
    return 0
}

create_snort_files() {
    local files=("$@")
    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            maybe_sudo touch "$file"
            info_message "Created file $file"
        fi
    done
    return 0
}

validate_installation_common() {
    info_message "Validating base installation..."
    if ! command_exists snort; then
        error_message "Snort is not installed on this system. Please install it and rerun script."
        exit 1
    fi
    success_message "Snort binary is present."
    return 0
}
