#!/usr/bin/env bats

WAZUH_MANAGER="10.0.0.2"
OSSEC_CONF_PATH="/var/ossec/etc/ossec.conf"

install_dependencies() {
  local os
  os=$(uname -o)

  case "$os" in
    "GNU/Linux")
      apt-get update
      apt-get install -y curl gnupg2 iproute2
      curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
      chmod 644 /usr/share/keyrings/wazuh.gpg
      
      if ! grep -q "https://packages.wazuh.com/4.x/apt/" /etc/apt/sources.list.d/wazuh.list; then
        echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
      fi
      
      apt-get update
      apt-get install -y wazuh-agent
      sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" "$OSSEC_CONF_PATH"
      ;;

    "Alpine")
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
  output=$(run scripts/install.sh)
  status=$?
  echo "Snort installation script output: $output"
  echo "Snort installation script status: $status"
  [ "$status" -eq 0 ] || return 1
}

@test "Snort should be installed" {
  install_dependencies
  run which snort
  [ "$status" -eq 0 ]
  [ -x "$output" ]
}

@test "snort.conf should exist" {
  install_dependencies
  run test -f /etc/snort/snort.conf
  [ "$status" -eq 0 ]
}

@test "Default network interface should be correctly configured in snort.conf" {
  install_dependencies
  local interface
  interface=$(ip route | grep default | awk '{print $5}')
  run grep -E "^ipvar HOME_NET" /etc/snort/snort.conf
  [ "$status" -eq 0 ]
  [[ "$output" == *"$interface"* ]]
}

@test "HOME_NET should be correctly configured in snort.conf" {
  install_dependencies
  local interface home_net
  interface=$(ip route | grep default | awk '{print $5}')
  home_net=$(ip -o -f inet addr show "$interface" | awk '/scope global/ {print $4}')
  run grep -E "^ipvar HOME_NET \[?$home_net\]?" /etc/snort/snort.conf
  [ "$status" -eq 0 ]
}

@test "ossec.conf should be updated with Snort logging configuration" {
  install_dependencies
  sed -i '/<\/ossec_config>/i\
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
