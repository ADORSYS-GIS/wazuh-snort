#!/usr/bin/env bash

if [[ -n "$BASH_VERSION" ]]; then
    set -euo pipefail
else
    set -eu
fi

# OS guard early in the script
if [[ "$(uname -s)" != "Darwin" ]]; then
    printf "%s\n" "[ERROR] This installation script is intended for macOS systems. Please use the appropriate script for your operating system." >&2
    exit 1
fi

# Repository reference
WAZUH_SNORT_REPO_REF=${WAZUH_SNORT_REPO_REF:-"main"}
WAZUH_SNORT_REPO_URL="https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/${WAZUH_SNORT_REPO_REF}"

# Source shared utilities
TMP_DIR=$(mktemp -d)
if ! curl -fsSL "${WAZUH_SNORT_REPO_URL}/scripts/shared/common.sh" -o "$TMP_DIR/common.sh"; then
    echo "Failed to download common.sh"
    exit 1
fi

# Function to calculate SHA256 (cross-platform bootstrap)
calculate_sha256_bootstrap() {
    local file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
    else
        shasum -a 256 "$file" | awk '{print $1}'
    fi
    return 0
}

# Download checksums and verify common.sh integrity BEFORE sourcing it
if ! curl -fsSL "${WAZUH_SNORT_REPO_URL}/checksums.sha256" -o "$TMP_DIR/checksums.sha256"; then
    echo "Failed to download checksums.sha256"
    exit 1
fi

EXPECTED_HASH=$(grep "scripts/shared/common.sh" "$TMP_DIR/checksums.sha256" | awk '{print $1}')
ACTUAL_HASH=$(calculate_sha256_bootstrap "$TMP_DIR/common.sh")

if [[ -z "$EXPECTED_HASH" ]] || [[ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]]; then
    echo "Error: Checksum verification failed for common.sh" >&2
    echo "Expected hash: $EXPECTED_HASH" >&2
    echo "Actual hash: $ACTUAL_HASH" >&2
    exit 1
fi

# shellcheck disable=SC1091
. "$TMP_DIR/common.sh"

# Register cleanup to run on exit
trap cleanup EXIT

OSSEC_CONF_PATH="/Library/Ossec/etc/ossec.conf"

ARCH=$(uname -m)
BREW_PATH=""
APP_NAME=${APP_NAME:-"snort"}
SNORT_LAUNCH_DAEMON_FILE=${SNORT_LAUNCH_DAEMON_FILE:-"/Library/LaunchDaemons/com.adorsys.$APP_NAME.plist"}

LOGGED_IN_USER=""
if [[ "$(uname -s)" = "Darwin" ]]; then
    LOGGED_IN_USER=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ {print $3}')
fi

brew_command() {
    if [[ -n "${LOGGED_IN_USER}" ]]; then
        sudo -u "${LOGGED_IN_USER}" brew "$@"
    else
        brew "$@"
    fi
    return 0
}

if command_exists brew; then
    BREW_PATH=$(brew --prefix || true)
fi


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

install_snort() {
    print_step "Installing" "Snort ($ARCH)"
    
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

    configure_snort_logging

    info_message "Downloading and configuring Snort rule files"
    download_file https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/rules/snort3.rules  /usr/local/etc/rules/snort3-community.rules "snort community rules"
    info_message "Snort rule files downloaded and configured successfully"

    info_message "Creating plist file..."
    create_snort_plist_file
    success_message "Snort started"

    info_message "Validating installation..."
    validate_installation
    return $?
}

configure_snort_logging() {
    local config_file="$SNORT_CONF_PATH"
    local content_to_add='alert_full =\n{\n    file = true\n}'

    info_message "Configuring Snort logging"
    if ! maybe_sudo grep -q "$content_to_add" "$config_file"; then
        echo -e "$content_to_add" | maybe_sudo tee -a "$config_file" > /dev/null
        success_message "Snort logging configured in $config_file"
    else
        info_message "Snort logging is already configured in $config_file"
    fi
    return 0
}


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
    return 0
}

validate_installation() {
    validate_installation_common

    if [[ ! -f "$SNORT_CONF_PATH" ]]; then
        error_exit "Snort configuration file not found at $SNORT_CONF_PATH"
    fi

    success_message "Snort configuration file found at $SNORT_CONF_PATH"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${0}" == *"install.sh" ]]; then
    install_snort
fi

install_snort
