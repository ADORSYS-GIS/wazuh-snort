#!/usr/bin/env bash

# Variables
DEBUG=${DEBUG:-}
LOG_LEVEL=${LOG_LEVEL:-INFO}
ARCH=$(dpkg --print-architecture)
BUILD_DIR=${BUILD_DIR:-$(pwd)/output}

## Activate debugging on DEBUG
if [ -n "$DEBUG" ]; then
    set -ex
else
    if [ -n "$BASH_VERSION" ]; then
        set -euo pipefail
    else
        set -eu
    fi
fi

# Define text formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
BOLD='\033[1m'
NORMAL='\033[0m'

# Function for logging with timestamp
log() {
    local LEVEL="$1"
    shift
    local MESSAGE="$*"
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$TIMESTAMP [$LEVEL] $MESSAGE"
}

# Logging helpers
info_success() {
    log GREEN "$*"
}

# Logging helpers
info_message() {
    log INFO "$*"
}

error_message() {
    log ERROR "$*"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure root privileges, either directly or through sudo
maybe_sudo() {
    if [ "$(id -u)" -ne 0 ]; then
        if command_exists sudo; then
            sudo "$@"
        else
            "$@"
        fi
    else
        "$@"
    fi
}

sed_alternative() {
    if command_exists gsed; then
        gsed "$@"
    else
        sed "$@"
    fi
}

# Disable interactive prompts
export DEBIAN_FRONTEND=noninteractive