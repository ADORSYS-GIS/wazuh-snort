#!/bin/bash

# Check if we're running in bash; if not, adjust behavior
if [ -n "$BASH_VERSION" ]; then
    set -euo pipefail
else
    set -eu
fi

APP_NAME=${APP_NAME:-"snort"}
SNORT_LAUNCH_DAEMON_FILE=${SNORT_LAUNCH_DAEMON_FILE:-"/Library/LaunchDaemons/com.adorsys.$APP_NAME.plist"}
LOGGED_IN_USER=""

if [ "$(uname -s)" = "Darwin" ]; then
    LOGGED_IN_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ {print $3}')
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

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if sudo is available or if the script is run as root
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

# General Utility Functions
create_file() {
    local filepath="$1"
    local content="$2"
    maybe_sudo bash -c "cat > \"$filepath\" <<EOF
$content
EOF"
    info_message "Created file: $filepath"
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
    # Check if the architecture is M1/ARM or Intel
    ARCH=$(uname -m)
    BREW_PATH=$(brew --prefix)

    print_step "Installing" "Snort for macOS ($ARCH)"
    
    if command_exists snort; then
        info_message "snort is already installed. Skipping installation."
    else
        brew_command install snort
        info_message "snort installed successfully"
    fi

    if [[ $BREW_PATH == "/opt/homebrew" ]]; then
        SNORT_CONF_PATH="/opt/homebrew/etc/snort/snort.lua"
    else
        SNORT_CONF_PATH="/usr/local/etc/snort/snort.lua"
    fi

    create_snort_dirs_files /usr/local/etc/rules /usr/local/etc/so_rules /usr/local/etc/lists /var/log/snort
    create_snort_files /usr/local/etc/rules/local.rules /usr/local/etc/lists/default.blocklist

    echo 'alert icmp any any -> any any ( msg:"ICMP Traffic Detected"; sid:10000001; metadata:policy security-ips alert; )' | sudo tee /usr/local/etc/rules/local.rules > /dev/null

    configure_snort_logging_macos

    #update_ossec_conf_macos
    if maybe_sudo [ -f "$OSSEC_CONF_PATH" ]; then
        # Call the function to update OSSEC configuration
        update_ossec_conf_macos
    else
        # Notify the user that the file is missing
        warn_message "OSSEC configuration file not found at $OSSEC_CONF_PATH."
        # Exit the script with a non-zero status
        exit 1
    fi
    
    info_message "Downloading and configuring Snort rule files"
    maybe_sudo curl -SL --progress-bar -o /usr/local/etc/rules/snort3-community.rules https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/rules/snort3.rules
    info_message "Snort rule files downloaded and configured successfully"

    info_message "Creating plist file..."
    create_snort_plist_file
    success_message "Snort started on macOS"
}

# Function to install Snort on Linux
install_snort_linux() {
    print_step "Installing" "Snort for Linux"

    # Get the default network interface
    # Get all network interface excluding virtual network interfaces
    INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(en|eth|wl)' | tr '\n' ' ')

    # Function to install Snort on Linux
    install_snort_apt() {
        sudo DEBIAN_FRONTEND=noninteractive apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install snort -y --no-install-recommends
    }

    # Install Snort
    if command_exists snort; then
        info_message "Snort is already installed. Skipping installation."
    else
        install_snort_apt
        info_message "Snort installed successfully"
    fi

    # Function to configure Snort to use the main network interface and set HomeNet
    configure_debian_snort_interface() {
        if [ ! -f /etc/snort/snort.debian.conf ]; then
            # Create snort.conf with minimal configuration
            echo "DEBIAN_SNORT_INTERFACE=\"$INTERFACE\"" | sudo tee -a /etc/snort/snort.debian.conf
        else
            # Update existing snort.conf
            sed_alternative -i "s/^DEBIAN_SNORT_INTERFACE=.*/DEBIAN_SNORT_INTERFACE=\"$INTERFACE\"/" /etc/snort/snort.debian.conf
        fi
    }

    configure_snort_interface() {
        if [ ! -f /etc/snort/snort.conf ]; then
            # Create snort.conf with minimal configuration
            echo "config interface: $INTERFACE" | sudo tee -a /etc/snort/snort.conf
        else
            # Update existing snort.conf
            sed_alternative -i "s/^config interface: .*/config interface: $INTERFACE/" /etc/snort/snort.conf
        fi
    }

    # Run the configuration function   
    if [ -f /etc/debian_version ]; then
        echo "This is a Debian-based OS. Configuring snort.debian.conf"
        configure_debian_snort_interface
    else
        echo "This is not a Debian-based OS. Configuring snort.conf"
        configure_snort_interface
    fi
 
    

    # Restart Snort service
    maybe_sudo systemctl restart snort || {
        echo "Failed to restart Snort. Check the configuration."
    }

    configure_snort_linux
    #update_ossec_conf_linux
    if maybe_sudo [ -f "$OSSEC_CONF_PATH" ]; then
        # Call the function to update OSSEC configuration
        update_ossec_conf_linux
    else
        # Notify the user that the file is missing
        warn_message "OSSEC configuration file not found at $OSSEC_CONF_PATH."
        # Exit the script with a non-zero status
        exit 1
    fi

    start_snort_linux

}

# Function to configure Snort logging on macOS
configure_snort_logging_macos() {
    local config_file="$SNORT_CONF_PATH"
    local content_to_add='alert_full =\n{\n    file = true\n}'

    info_message "Configuring Snort logging"
    if ! maybe_sudo grep -q "$content_to_add" "$config_file"; then
        echo -e "$content_to_add" | maybe_sudo tee -a "$config_file" > /dev/null
        success_message "Snort logging configured in $config_file"
    else
        info_message "Snort logging is already configured in $config_file"
    fi
}

# Function to update ossec.conf on macOS (M1 and Intel)
update_ossec_conf_macos() {
   
    info_message "Updating $OSSEC_CONF_PATH"

    # Check if the specific <location> tag exists in the configuration file
    if ! maybe_sudo grep -q "<location>/var/log/snort/alert_full.txt</location>" "$OSSEC_CONF_PATH"; then
        

        sed_alternative -i -e "/<\/ossec_config>/i\\
<!-- snort -->\\
<localfile>\\
    <log_format>snort-full</log_format>\\
    <location>/var/log/snort/alert_full.txt</location>\\
</localfile>" "$OSSEC_CONF_PATH"
    

        success_message "ossec.conf updated on macOS"
    else
        info_message "The content already exists in $OSSEC_CONF_PATH"
    fi
}

# macOS Launchd Plist File
create_snort_plist_file() {
    if [[ $BREW_PATH == "/opt/homebrew" ]]; then
        BIN_FOLDER="/opt/homebrew/bin"
    else
        BIN_FOLDER="/usr/local/bin"
    fi
    
    info_message "Creating plist file for $APP_NAME..."
    create_file "$SNORT_LAUNCH_DAEMON_FILE" "
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>com.adorsys.$APP_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BIN_FOLDER/$APP_NAME</string>
        <string>-c</string>
        <string>$SNORT_CONF_PATH</string>
        <string>-R</string>
        <string>/usr/local/etc/rules/snort3-community.rules</string>
        <string>-i</string>
        <string>en0</string>
        <string>-A</string>
        <string>alert_full</string>
        <string>-q</string>
        <string>-D</string>
        <string>-l</string>
        <string>/var/log/snort</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
"
    info_message "Unloading previous plist file (if any)..."
    maybe_sudo launchctl unload "$SNORT_LAUNCH_DAEMON_FILE" 2>/dev/null || true
    
    info_message "Loading new plist file..."
    maybe_sudo launchctl load -w "$SNORT_LAUNCH_DAEMON_FILE" 2>/dev/null || true
    
    info_message "macOS Launchd plist file created and loaded: $SNORT_LAUNCH_DAEMON_FILE"
}

# Function to configure Snort on Linux
configure_snort_linux() {
    info_message "Configuring Snort"
    sed_alternative -i 's/output alert_fast: snort.alert.fast/output alert_fast: snort.alert/g' /etc/snort/snort.conf
    sed_alternative -i 's/# output alert_syslog: LOG_AUTH LOG_ALERT/output alert_syslog: LOG_AUTH LOG_ALERT/g' /etc/snort/snort.conf
    echo 'alert icmp any any -> any any (msg:"ICMP connection attempt:"; sid:1000010; rev:1;)' | maybe_sudo tee -a /etc/snort/rules/local.rules > /dev/null

    info_message "Downloading and configuring Snort rule files"
    maybe_sudo curl -SL --progress-bar -o community-rules.tar.gz https://www.snort.org/downloads/community/community-rules.tar.gz
    maybe_sudo tar -xvzf community-rules.tar.gz -C /etc/snort/rules --strip-components=1
    maybe_sudo rm community-rules.tar.gz

    if ! maybe_sudo grep -q "include \$RULE_PATH/community.rules" /etc/snort/snort.conf; then
        echo "include \$RULE_PATH/community.rules" | maybe_sudo tee -a /etc/snort/snort.conf
        success_message "Snort rule files configured on Linux"
    fi
}

# Function to update ossec.conf on Linux
update_ossec_conf_linux() {
    # Check if the specific <location> tag exists in the configuration file
    if ! maybe_sudo grep -q "<location>/var/log/snort/snort.alert.fast</location>" "$OSSEC_CONF_PATH"; then
        info_message "Updating $OSSEC_CONF_PATH"
        sed_alternative -i '/<\/ossec_config>/i\
            <!-- snort -->\
            <localfile>\
                <log_format>snort-full<\/log_format>\
                <location>\/var\/log\/snort\/snort.alert<\/location>\
            <\/localfile>' "$OSSEC_CONF_PATH"
        success_message "ossec.conf updated."
    else
        info_message "The content already exists in $OSSEC_CONF_PATH"
    fi
    
}

# Function to start Snort on Linux
start_snort_linux() {
    info_message "Starting Snort"
    maybe_sudo systemctl restart snort
    success_message "Snort started on Linux"
    maybe_sudo snort -q -c /etc/snort/snort.conf -l /var/log/snort -A full &
}

# Function to validate the installation and configuration
validate_installation() {
    info_message "Validating the installation..."

    # Check if Snort is installed (Linux)
    if [[ $OS_NAME == "Linux" ]]; then
        if ! command -v snort &>/dev/null; then
            error_message "Snort is not installed on this system. Please install it and rerun the script."
            exit 1
        else
            success_message "Snort is installed on Linux."
        fi
    fi

    # Check if Snort is installed (macOS)
    if [[ $OS_NAME == "Darwin" ]]; then
        if ! command -v snort &>/dev/null; then
            error_message "Snort is not installed on this system. Please install it and rerun the script."
            exit 1
        else
            success_message "Snort is installed on macOS."
        fi
    fi

    # Validate Snort rules and directories
    if [[ ! -d "/usr/local/etc/rules" ]] || [[ ! -f "/usr/local/etc/rules/local.rules" ]]; then
        warn_message "Snort rules or directories are missing. Please check the configuration."
    else
        success_message "Snort rules and directories are properly configured."
    fi

    # Validate logging configuration for Snort
    if [[ $OS_NAME == "Darwin" && ! -f "$SNORT_CONF_PATH" ]]; then
        error_message "Snort configuration file not found at $SNORT_CONF_PATH. Please ensure Snort is installed properly."
        exit 1
    elif [[ $OS_NAME == "Linux" && ! -f "/etc/snort/snort.conf" ]]; then
        error_message "Snort configuration file not found at /etc/snort/snort.conf. Please ensure Snort is installed properly."
        exit 1
    else
        success_message "Snort configuration file is present."
    fi

    success_message "Validation completed successfully."
}

# Main logic: install Snort based on the operating system
case "$OS_NAME" in
    Linux)
        install_snort_linux
        success_message "Snort installed successfully"
        ;;
    Darwin)
        install_snort_macos
        success_message "Snort installed successfully"
        ;;
    *)
        error_message "Unsupported OS: $OS_NAME"
        exit 1
        ;;
esac
