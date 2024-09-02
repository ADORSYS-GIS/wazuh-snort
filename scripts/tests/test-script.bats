#!/usr/bin/env bats

# Variables
WAZUH_MANAGER="10.0.0.2"
OSSEC_CONF_PATH="/var/ossec/etc/ossec.conf"

# Function to install dependencies
install_dependencies() {
  echo "Starting dependency installation..."
  local os
  os=$(uname -o)
  echo "Detected OS: $os"

  case "$os" in
    "GNU/Linux")
      echo "Installing dependencies for Linux..."
      apt-get update
      apt-get install -y curl gnupg2 iproute2
      curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
      chmod 644 /usr/share/keyrings/wazuh.gpg

      if ! grep -q "https://packages.wazuh.com/4.x/apt/" /etc/apt/sources.list.d/wazuh.list; then
        echo "Adding Wazuh APT repository..."
        echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
      fi

      apt-get update
      apt-get install -y wazuh-agent
      sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" "$OSSEC_CONF_PATH"
      ;;

    "Alpine")
      echo "Installing dependencies for Alpine..."
      wget -O /etc/apk/keys/alpine-devel@wazuh.com-633d7457.rsa.pub https://packages.wazuh.com/key/alpine-devel%40wazuh.com-633d7457.rsa.pub
      echo "https://packages.wazuh.com/4.x/alpine/v3.12/main" | tee /etc/apk/repositories
      apk update
      apk add wazuh-agent
      sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" "$OSSEC_CONF_PATH"
      ;;

    *)
      echo "Unsupported OS for Wazuh installation." >&2
      return 1
      ;;
  esac

  chmod +x scripts/install.sh
  echo "Running Snort installation script..."
  output=$(run scripts/install.sh)
  status=$?
  echo "Snort installation script output: $output"
  echo "Snort installation script status: $status"
  [ "$status" -eq 0 ] || return 1
}

# Test to check if Snort is installed
@test "Snort should be installed" {
  echo "Starting test: Snort should be installed"
  install_dependencies
  run which snort
  echo "Snort path: $output"
  echo "Snort installation check status: $status"
  [ "$status" -eq 0 ]
  [ -x "$output" ]
}

# Test to check if the snort.conf file exists
@test "snort.conf should exist" {
  echo "Starting test: snort.conf should exist"
  install_dependencies
  run test -f /etc/snort/snort.conf
  echo "snort.conf existence check status: $status"
}

# Test to check if the default network interface is correctly configured in snort.conf
@test "Default network interface should be correctly configured in snort.conf" {
  echo "Starting test: Default network interface should be correctly configured in snort.conf"
  install_dependencies
  local interface
  interface=$(ip route | grep default | awk '{print $5}')
  run grep -E "^ipvar HOME_NET" /etc/snort/snort.conf
  echo "Interface: $interface"
  echo "Default network interface check status: $status"
  [[ "$output" == *"$interface"* ]]
}

# Test to check if HOME_NET is correctly configured in snort.conf
@test "HOME_NET should be correctly configured in snort.conf" {
  echo "Starting test: HOME_NET should be correctly configured in snort.conf"
  install_dependencies
  local interface home_net
  interface=$(ip route | grep default | awk '{print $5}')
  home_net=$(ip -o -f inet addr show "$interface" | awk '/scope global/ {print $4}')
  run grep -E "^ipvar HOME_NET \[?$home_net\]?" /etc/snort/snort.conf
  echo "HOME_NET: $home_net"
  echo "HOME_NET configuration check status: $status"
}

# Test to check if ossec.conf is updated with Snort logging configuration
@test "ossec.conf should be updated with Snort logging configuration" {
  echo "Starting test: ossec.conf should be updated with Snort logging configuration"
  install_dependencies
  sed -i '/<\/ossec_config>/i\
        <!-- snort -->\
        <localfile>\
            <log_format>snort-full<\/log_format>\
            <location>\/var\/log\/snort\/snort.alert.fast<\/location>\
        <\/localfile>' "$OSSEC_CONF_PATH"

  run grep -A 3 '<!-- snort -->' "$OSSEC_CONF_PATH"
  echo "ossec.conf update check status: $status"
  echo "ossec.conf content: $output"
  [[ "$output" == *"<log_format>snort-full</log_format>"* ]]
  [[ "$output" == *"<location>/var/log/snort/snort.alert.fast</location>"* ]]
}
