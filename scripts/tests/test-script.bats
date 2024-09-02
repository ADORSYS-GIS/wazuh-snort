#!/usr/bin/env bats

WAZUH_MANAGER="10.0.0.2"
OSSEC_CONF_PATH="/var/ossec/etc/ossec.conf"

# setup_file runs once before all the tests in the file
setup_file() {
  if [ "$(uname -o)" = "GNU/Linux" ]; then
    sudo apt-get update && sudo apt-get install -y curl gnupg2
    (curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import)
    sudo chmod 644 /usr/share/keyrings/wazuh.gpg

    if ! grep -q "https://packages.wazuh.com/4.x/apt/" /etc/apt/sources.list.d/wazuh.list 2>/dev/null; then
      echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list
    fi

    sudo apt-get update
    sudo apt-get install -y wazuh-agent
    sudo sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" "$OSSEC_CONF_PATH"
  elif [ "$(which apk)" = "/sbin/apk" ]; then
    sudo wget -O /etc/apk/keys/alpine-devel@wazuh.com-633d7457.rsa.pub https://packages.wazuh.com/key/alpine-devel%40wazuh.com-633d7457.rsa.pub
    echo "https://packages.wazuh.com/4.x/alpine/v3.12/main" | sudo tee -a /etc/apk/repositories
    sudo apk update
    sudo apk add wazuh-agent
    sudo sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" "$OSSEC_CONF_PATH"
  else
    echo "Unsupported OS for Wazuh installation." >&2
    exit 1
  fi

  sudo chmod +x scripts/install.sh

  # Run the Snort installation script
  run sudo scripts/install.sh
  [ "$status" -eq 0 ] || skip "Snort installation failed"
}

# Test to check if Snort is installed
@test "Snort should be installed" {
  run which snort
  [ "$status" -eq 0 ]
  [ -x "$output" ]
}

# Test to check if the snort.conf file exists
@test "snort.conf should exist" {
  run test -f /etc/snort/snort.conf
  [ "$status" -eq 0 ]
}

# Test to check if the default network interface is correctly configured in snort.conf
@test "Default network interface should be correctly configured in snort.conf" {
  INTERFACE=$(ip route | grep default | awk '{print $5}')
  run grep -E "^ipvar HOME_NET" /etc/snort/snort.conf
  [ "$status" -eq 0 ]
  [[ "$output" == *"$INTERFACE"* ]]
}

# Test to check if HOME_NET is correctly configured in snort.conf
@test "HOME_NET should be correctly configured in snort.conf" {
  INTERFACE=$(ip route | grep default | awk '{print $5}')
  HOME_NET=$(ip -o -f inet addr show $INTERFACE | awk '/scope global/ {print $4}')
  run grep -E "^ipvar HOME_NET \[?$HOME_NET\]?" /etc/snort/snort.conf
  [ "$status" -eq 0 ]
}

# Test to check if ossec.conf is updated correctly with Snort logging configuration
@test "ossec.conf should be updated with Snort logging configuration" {
  sudo sed -i '/<\/ossec_config>/i\
        <!-- snort -->\
        <localfile>\
            <log_format>snort-full<\/log_format>\
            <location>\/var\/log\/snort\/snort.alert.fast<\/location>\
        <\/localfile>' "$OSSEC_CONF_PATH"

  run grep -A 3 '<!-- snort -->' "$OSSEC_CONF_PATH"
  [ "$status" -eq 0 ]
  [[ "$output" == *"<log_format>snort-full</log_format>"* ]]
  [[ "$output" == *"<location>/var/log/snort/snort.alert.fast</location>"* ]]
}
