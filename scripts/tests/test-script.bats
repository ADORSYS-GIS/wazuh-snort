#!/usr/bin/env bats

WAZUH_MANAGER="10.0.0.2"

# Check if the environment is Linux and prepare for Wazuh agent installation
setup() {
  if [ "$(uname -o)" = "GNU/Linux" ]; then
    apt-get update && apt-get install -y curl gnupg2
    (curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import)
    chmod 644 /usr/share/keyrings/wazuh.gpg

    if ! grep -q "https://packages.wazuh.com/4.x/apt/" /etc/apt/sources.list.d/wazuh.list 2>/dev/null; then
      echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
    fi

    apt-get update
    apt-get install -y wazuh-agent
    sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" /var/ossec/etc/ossec.conf
  elif [ "$(which apk)" = "/sbin/apk" ]; then
    wget -O /etc/apk/keys/alpine-devel@wazuh.com-633d7457.rsa.pub https://packages.wazuh.com/key/alpine-devel%40wazuh.com-633d7457.rsa.pub
    echo "https://packages.wazuh.com/4.x/alpine/v3.12/main" >> /etc/apk/repositories
    apk update
    apk add wazuh-agent
    sed -i "s|MANAGER_IP|$WAZUH_MANAGER|g" /var/ossec/etc/ossec.conf
  else
    echo "Unsupported OS for Wazuh installation." >&2
    exit 1
  fi

  chmod +x /app/scripts/install.sh
}

# Test if the Snort installation script runs without errors
@test "Snort installation script runs without errors" {
  if [ -f /app/scripts/install.sh ]; then
    run /app/scripts/install.sh
    [ "$status" -eq 0 ]
  else
    skip "/app/scripts/install.sh not found"
  fi
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
