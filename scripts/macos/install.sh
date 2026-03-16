#!/usr/bin/env bash

set -euo pipefail


COMMON="/tmp/common.sh"

if [[ ! -f "$COMMON" ]]; then
  curl -fsSL https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/refactor/split-linux-macos-scripts/scripts/shared/common.sh -o "$COMMON"
fi

source "$COMMON"

OSSEC_CONF_PATH="/Library/Ossec/etc/ossec.conf"

ARCH=$(uname -m)
BREW_PATH=""
if command_exists brew; then
    BREW_PATH=$(brew --prefix || true)
fi

install_snort() {
    # Check if the architecture is M1/ARM or Intel
    ARCH=$(uname -m)
    BREW_PATH=$(brew --prefix)

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

    #update_ossec_conf_macos
    if maybe_sudo [[ -f "$OSSEC_CONF_PATH" ]]; then
        # Call the function to update OSSEC configuration
        update_ossec_conf
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
    success_message "Snort started"

    info_message "Validating installation..."
    validate_installation
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

update_ossec_conf() {
   
    info_message "Updating $OSSEC_CONF_PATH"

    # Check if the specific <location> tag exists in the configuration file
    if ! maybe_sudo grep -q "<location>/var/log/snort/alert_full.txt</location>" "$OSSEC_CONF_PATH"; then
        

        sed_alternative -i -e "/<\/ossec_config>/i\\
<!-- snort -->\\
<localfile>\\
    <log_format>snort-full</log_format>\\
    <location>/var/log/snort/alert_full.txt</location>\\
</localfile>" "$OSSEC_CONF_PATH"
    

        success_message "ossec.conf updated."
    else
        info_message "The content already exists in $OSSEC_CONF_PATH"
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
        error_message "Snort configuration file not found at $SNORT_CONF_PATH"
        exit 1
    fi

    success_message "Snort configuration file found at $SNORT_CONF_PATH"
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_snort
fi
