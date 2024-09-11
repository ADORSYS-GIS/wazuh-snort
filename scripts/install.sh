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

# Function for logging with timestamp
log() {
    local LEVEL="$1"
    shift
    local MESSAGE="$*"
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo -e "${TIMESTAMP} ${LEVEL} ${MESSAGE}"
}

# Logging helpers
info_message() {
    log "${BLUE}${BOLD}[INFO]${NORMAL}" "$*"
}

warn_message() {
    log "${YELLOW}${BOLD}[WARNING]${NORMAL}" "$*"
}

error_message() {
    log "${RED}${BOLD}[ERROR]${NORMAL}" "$*"
}

success_message() {
    log "${GREEN}${BOLD}[SUCCESS]${NORMAL}" "$*"
}

print_step() {
    log "${BLUE}${BOLD}[STEP]${NORMAL}" "$1: $2"
}

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

# Function to create necessary directories and files for Snort
create_snort_dirs_files() {
    local dirs=("$@")
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            maybe_sudo mkdir -p "$dir"
            info_message "Created directory $dir"
        fi
    done
}

create_snort_files() {
    local files=("$@")
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            maybe_sudo touch "$file"
            info_message "Created file $file"
        fi
    done
}

# Function to install Snort on macOS
install_snort_macos() {
    print_step "Installing" "Snort for macOS"
    # Install brew if it doesn't exist
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install snort

    create_snort_dirs_files /usr/local/etc/rules /usr/local/etc/so_rules /usr/local/etc/lists /var/log/snort
    create_snort_files /usr/local/etc/rules/local.rules /usr/local/etc/lists/default.blocklist

    echo 'alert icmp any any -> any any ( msg:"ICMP Traffic Detected"; sid:10000001; metadata:policy security-ips alert; )' | maybe_sudo tee /usr/local/etc/rules/local.rules > /dev/null

    configure_snort_logging_macos
    update_ossec_conf_macos
    start_snort_macos
}

# Function to install Snort on Linux
install_snort_linux() {
    print_step "Installing" "Snort for Linux"

    # Get the default network interface
    INTERFACE=$(ip route | grep default | awk '{print $5}')

    # Function to install Snort on Linux
    install_snort_apt() {
        sudo DEBIAN_FRONTEND=noninteractive apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install snort -y --no-install-recommends
    }

    # Install Snort
    install_snort_apt

    # Function to configure Snort to use the main network interface and set HomeNet
    configure_snort_interface() {
        if [ ! -f /etc/snort/snort.conf ]; then
            # Create snort.conf with minimal configuration
            echo "config interface: $INTERFACE" | sudo tee -a /etc/snort/snort.conf
        else
            # Update existing snort.conf
            maybe_sudo sed -i "s/^config interface: .*/config interface: $INTERFACE/" /etc/snort/snort.conf
        fi
    }

    # Run the configuration function
    configure_snort_interface

    # Restart Snort service
    maybe_sudo systemctl restart snort || {
        echo "Failed to restart Snort. Check the configuration."
    }

    configure_snort_linux
    update_ossec_conf_linux
    start_snort_linux
}

# Function to configure Snort logging on macOS
configure_snort_logging_macos() {
    local config_file="/opt/homebrew/etc/snort/snort.lua"
    local content_to_add='alert_fast =\n{\n    file = true\n}'

    info_message "Configuring Snort logging"
    if ! grep -q "$content_to_add" "$config_file"; then
        echo -e "$content_to_add" | maybe_sudo tee -a "$config_file" > /dev/null
        success_message "Snort logging configured in $config_file"
    else
        info_message "Snort logging is already configured in $config_file"
    fi
}

# Function to update ossec.conf on macOS
update_ossec_conf_macos() {
    local content_to_add="<!-- snort -->
    <localfile>
        <log_format>snort-full<\/log_format>
        <location>\/var\/log\/snort\/alert_fast.txt<\/location>
    <\/localfile>"

    info_message "Updating $OSSEC_CONF_PATH"
    if ! grep -q "$content_to_add" "$OSSEC_CONF_PATH"; then
        maybe_sudo sed -i '' "/<\/ossec_config>/i\\
    $content_to_add" "$OSSEC_CONF_PATH"
        success_message "ossec.conf updated on macOS"
    else
        info_message "The content already exists in $OSSEC_CONF_PATH"
    fi
}

# Function to start Snort on macOS
start_snort_macos() {
    info_message "Starting Snort"
    maybe_sudo snort -c /opt/homebrew/etc/snort/snort.lua -R /usr/local/etc/rules/local.rules -i en0 -A fast -q -D -l /var/log/snort
    success_message "Snort started on macOS"
}

# Function to configure Snort on Linux
configure_snort_linux() {
    info_message "Configuring Snort"
    maybe_sudo sed -i 's/output alert_fast: snort.alert.fast/output alert_fast: snort.alert/g' /etc/snort/snort.conf
    maybe_sudo sed -i 's/# output alert_syslog: LOG_AUTH LOG_ALERT/output alert_syslog: LOG_AUTH LOG_ALERT/g' /etc/snort/snort.conf
    echo 'alert icmp any any -> any any (msg:"ICMP connection attempt:"; sid:1000010; rev:1;)' | maybe_sudo tee -a /etc/snort/rules/local.rules > /dev/null

    info_message "Downloading and configuring Snort rule files"
    maybe_sudo curl -SL --progress-bar -o community-rules.tar.gz https://www.snort.org/downloads/community/community-rules.tar.gz
    maybe_sudo tar -xvzf community-rules.tar.gz -C /etc/snort/rules --strip-components=1
    maybe_sudo rm community-rules.tar.gz

    if ! grep -q "include \$RULE_PATH/community.rules" /etc/snort/snort.conf; then
        echo "include \$RULE_PATH/community.rules" | maybe_sudo tee -a /etc/snort/snort.conf
        success_message "Snort rule files configured on Linux"
    fi
}

# Function to update ossec.conf on Linux
update_ossec_conf_linux() {
    info_message "Updating $OSSEC_CONF_PATH"
    maybe_sudo sed -i '/<\/ossec_config>/i\
        <!-- snort -->\
        <localfile>\
            <log_format>snort-full<\/log_format>\
            <location>\/var\/log\/snort\/snort.alert.fast<\/location>\
        <\/localfile>' "$OSSEC_CONF_PATH"
    success_message "ossec.conf updated on Linux"
}

# Function to start Snort on Linux
start_snort_linux() {
    info_message "Restarting Snort"
    maybe_sudo systemctl restart snort
    maybe_sudo snort -q -c /etc/snort/snort.conf -l /var/log/snort -A fast &
    success_message "Snort started on Linux"
}

# Function to ensure the script runs with root privileges
maybe_sudo() {
    if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            sudo "$@"
        else
            error_message "This script requires root privileges. Please run with sudo or as root."
            exit 1
        fi
    else
        "$@"
    fi
}

# Main function to install and configure Snort
install_snort() {
    case "$OSTYPE" in
        darwin*)
            install_snort_macos
            ;;
        linux*)
            install_snort_linux
            ;;
        *)
            error_message "Unsupported OS type: $OSTYPE"
            exit 1
            ;;
    esac
}

# Run the main installation function
install_snort

