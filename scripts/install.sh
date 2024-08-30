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
    maybe_sudo brew install snort

    create_snort_dirs_files /usr/local/etc/rules /usr/local/etc/so_rules /usr/local/etc/lists /var/log/snort
    create_snort_files /usr/local/etc/rules/local.rules /usr/local/etc/lists/default.blocklist

    echo 'alert icmp any any -> any any ( msg:"ICMP Traffic Detected"; sid:10000001; metadata:policy security-ips alert; )' | maybe_sudo tee /usr/local/etc/rules/local.rules >/dev/null

    configure_snort_logging_macos
    update_ossec_conf_macos
    start_snort_macos

    # Change ownership and set capabilities
    maybe_sudo chown "$USER" /usr/local/bin/snort
    maybe_sudo chmod u+s /usr/local/bin/snort
}

# Function to install Snort on Linux
install_snort_linux() {
    # Disable interactive prompts
    export DEBIAN_FRONTEND=noninteractive
    print_step "Installing" "Snort for Linux"
    maybe_sudo apt-get update
    maybe_sudo apt install net-tools -y

    # Determine the system architecture
    ARCH=$(dpkg --print-architecture)

    # Define the URL of the archive based on the architecture
    if [[ "$ARCH" == "amd64" ]]; then
        URL="https://github.com/ADORSYS-GIS/wazuh-snort/releases/download/fix-scripts-tests/snort3-packages-amd64.zip" # to be updated
    elif [[ "$ARCH" == "arm64" ]]; then
        URL="https://github.com/ADORSYS-GIS/wazuh-snort/releases/download/fix-scripts-tests/snort3-packages-arm64.zip" # to be updated
    else
        error_message "Unsupported architecture: $ARCH"
        exit 1
    fi

    # Install required packages if not already installed
    if ! command -v unzip &>/dev/null; then
        echo "unzip could not be found. Installing unzip..."
        sudo apt-get update && sudo apt-get install -y unzip
    fi

    # Create a temporary directory
    TEMP_DIR=$(mktemp -d)

    # Download the archive to the temporary directory
    curl -L $URL -o $TEMP_DIR/snort3-packages.zip

    # Extract the archive
    unzip $TEMP_DIR/snort3-packages.zip -d $TEMP_DIR

    # Make the .deb files executable
    sudo chmod +x $TEMP_DIR/*.deb

    # Install all .deb files
    sudo dpkg -i $TEMP_DIR/*.deb

    # Check if /usr/local/lib is in the library path
    if ! grep -q "/usr/local/lib" /etc/ld.so.conf.d/*; then
        echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/local-lib.conf
    fi

    # Update the linker cache
    sudo ldconfig

    # Clean up the temporary directory
    rm -rf $TEMP_DIR

    success_message "Installation completed for architecture $ARCH"

    # Get the default network interface
    INTERFACE=$(ip route | grep default | awk '{print $5}')

    # Check if the interface is found
    if [ -z "$INTERFACE" ]; then
        error_message "No network interface found."
        exit 1
    fi

    # Create the snort system user
    maybe_sudo useradd -r -s /usr/sbin/nologin -M -c SNORT_IDS snort

    # Grant permissions to the log directory
    maybe_sudo chmod -R 5775 /var/log/snort
    maybe_sudo chown -R snort:snort /var/log/snort

    # Create the systemd service file
maybe_sudo cat > /etc/systemd/system/snort3.service << EOL
[Unit]
Description=Snort3 NIDS Daemon
After=syslog.target network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/snort -c /usr/local/etc/snort/snort.lua -s 65535 -k none -l /var/log/snort -D -u snort -g snort -i $INTERFACE -m 0x1b --create-pidfile
ExecStop=/bin/kill -9 \$MAINPID

[Install]
WantedBy=multi-user.target
EOL

    # Enable and start the service
    sudo systemctl enable snort3
    #sudo systemctl start snort3
    sudo service snort3 start
    # Check the status of the service
    sudo service snort3 status

    # Check the status of the service
    if systemctl is-active --quiet snort3.service; then
        success_message "Service 'snort3' is running."
    else
        error_message "Service 'snort3' is not running."
    fi

    # Show detailed status of the service
    systemctl status snort3.service

    configure_snort_linux
    #update_ossec_conf_linux
    #start_snort_linux

}

# Function to configure Snort logging on macOS
configure_snort_logging_macos() {
    local config_file="/usr/local/etc/snort/snort.lua"
    local content_to_add='alert_fast =\n{\n    file = true\n}'

    info_message "Configuring Snort logging"
    if ! grep -q "$content_to_add" "$config_file"; then
        echo -e "$content_to_add" | maybe_sudo tee -a "$config_file" >/dev/null
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
    maybe_sudo snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/rules/local.rules -i en0 -A fast -q -D -l /var/log/snort
    success_message "Snort started on macOS"
}

# Function to configure Snort on Linux
configure_snort_linux() {
    info_message "Configuring Snort"

# Function to check and create directories if necessary
check_create_directories() {
    local directories=("$@")
    for directory in "${directories[@]}"; do
        if [ ! -d "$directory" ]; then
            maybe_sudo mkdir -p "$directory"
            info_message "Created directory $directory"
        fi
    done
}

# Function to check and create files if necessary
check_create_files() {
    local files=("$@")
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            maybe_sudo touch "$file"
            info_message "Created file $file"
        fi
    done
}

# Directories to check and create
directories=("/usr/local/etc/rules" "/usr/local/etc/so_rules" "/usr/local/etc/lists" "/var/log/snort")

# Files to check and create
files=("/usr/local/etc/rules/local.rules" "/usr/local/etc/lists/default.blocklist")

# Check and create directories if necessary
check_create_directories "${directories[@]}"

# Check and create files if necessary
check_create_files "${files[@]}"

# Add the rule if it does not already exist
RULE="alert icmp any any -> any any ( msg:\"ICMP Traffic Detected\"; sid:10000001; metadata:policy security-ips alert; )"
grep -qF "$RULE" /usr/local/etc/rules/local.rules || echo "$RULE" | maybe_sudo tee -a /usr/local/etc/rules/local.rules > /dev/null


# Get the IP address of the default network interface
HOME_NET=$(ip -o -f inet addr show "$INTERFACE" | awk '{print $4}')

# Download and extract Snort 3 community rules
cd /usr/local/etc/rules || exit
wget https://www.snort.org/downloads/community/snort3-community-rules.tar.gz
tar xzf snort3-community-rules.tar.gz

# Verify the extraction
echo "Listing extracted files:"
ls -l snort3-community-rules

# Path to the snort.lua file
SNORT_LUA="/usr/local/etc/snort/snort.lua"

# Check if the snort.lua file exists
if [ ! -f "$SNORT_LUA" ]; then
    echo "Error: $SNORT_LUA file not found."
    exit 1
fi
maybe_sudo 
# Update the ips section to enable decoder and inspector alerts, include local and community rules
sed -i '/ips = {/,/variables = default_variables/ s/^--\(enable_builtin_rules\s*=\s*true\)/\1/' "$SNORT_LUA"
sed -i '/ips = {/,/variables = default_variables/ s/^--\(include\s*=\s*RULE_PATH\s*\.\.\s*\"\/local\.rules\"\)/\1/' "$SNORT_LUA"
sed -i '/ips = {/,/variables = default_variables/ s/^--\(include\s*=\s*RULE_PATH\s*\.\.\s*\"\/snort3-community-rules\/snort3-community\.rules\"\)/\1/' "$SNORT_LUA"

# Ensure the HOME_NET and EXTERNAL_NET variables are set dynamically
sed -i "s|HOME_NET = .*$|HOME_NET = \"$HOME_NET\"|" "$SNORT_LUA"
sed -i 's|EXTERNAL_NET = .*$|EXTERNAL_NET = "!$HOME_NET"|' "$SNORT_LUA"

# Notify the user of success
echo "Successfully configured Snort with community rules and updated HOME_NET to $HOME_NET and EXTERNAL_NET variables in $SNORT_LUA."


success_message "Snort configured on Linux"
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
# Run Snort
snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/rules/local.rules
snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/rules/local.rules -i "$INTERFACE" -A alert_fast -s 65535 -k none 
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
    linux-gnu*)
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
