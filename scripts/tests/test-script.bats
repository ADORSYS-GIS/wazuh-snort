#!/usr/bin/env bats

WAZUH_MANAGER="10.0.0.2"

if [ "$(uname -o)" = "GNU/Linux" ] && command -v groupadd >/dev/null 2>&1; then
    apt-get update && apt-get install -y curl gnupg2
    (curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import)
    chmod 644 /usr/share/keyrings/wazuh.gpg

    # Check if the repository is already added
    if ! grep -q "https://packages.wazuh.com/4.x/apt/" /etc/apt/sources.list.d/wazuh.list 2>/dev/null; then
        echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
    fi

    apt-get update
    apt-get install wazuh-agent -y
    sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" /var/ossec/etc/ossec.conf
elif [ "$(which apk)" = "/sbin/apk" ]; then
    wget -O /etc/apk/keys/alpine-devel@wazuh.com-633d7457.rsa.pub https://packages.wazuh.com/key/alpine-devel%40wazuh.com-633d7457.rsa.pub
    echo "https://packages.wazuh.com/4.x/alpine/v3.12/main" >> /etc/apk/repositories
    apk update
    apk add wazuh-agent
    sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" /var/ossec/etc/ossec.conf
else
    log ERROR "Unsupported OS for creating user."
    exit 1
fi

chmod +x /app/scripts/install.sh

# Function to run the install script and check its status
run_install_script() {
  run /app/scripts/install.sh
  if [ "$status" -ne 0 ]; then
    echo "Install script failed with status: $status"
    echo "Output: $output"
    return 1
  fi
  return 0
}

# Test if the script runs without errors
@test "Script runs without errors" {
  run_install_script
}

# Test if Snort is installed and running
@test "Snort is installed and running" {
  # Check if Snort is installed
  run snort -V
  echo "snort -V output: $output"
  [ "$status" -eq 0 ]

  # Check if Snort service is running
  run systemctl status snort3
  echo "systemctl status snort3 output: $output"
  [ "$status" -eq 0 ]
}

# Test if Snort directories were created
@test "Snort directories were created" {
  [ -d "/var/log/snort" ]
  [ -d "/etc/snort/rules" ]
}

# Test if Snort local rules file was created
@test "Snort local rules file created" {
  [ -f "/etc/snort/rules/local.rules" ]
}

# Test if ossec.conf was updated
@test "ossec.conf updated" {
  run grep -q '<log_format>snort-full<\/log_format>' /var/ossec/etc/ossec.conf
  [ "$status" -eq 0 ]
  run grep -q '<location>\/var\/log\/snort\/snort.alert.fast<\/location>' /var/ossec/etc/ossec.conf
  [ "$status" -eq 0 ]
}

