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

# Test if Snort is installed
@test "Snort is installed" {
  run which snort
  [ "$status" -eq 0 ]
  [ -x "$output" ]
}

# Test if Snort service is active
@test "Snort service is active" {
  run systemctl is-active snort3
  [ "$status" -eq 0 ]
  [ "$output" = "active" ]
}

# Test if Snort configuration file exists
@test "Snort configuration file exists" {
  run test -f /usr/local/etc/snort/snort.lua
  [ "$status" -eq 0 ]
}

# Test if Snort configuration is valid
@test "Snort configuration is valid" {
  if command -v snort &> /dev/null; then
    run snort -T -c /usr/local/etc/snort/snort.lua
    [ "$status" -eq 0 ]
  else
    skip "Snort command not found"
  fi
}

# Test if Snort rules file exists
@test "Snort rules file exists" {
  run test -f /usr/local/etc/rules/local.rules
  [ "$status" -eq 0 ]
}

# Test if Snort rules are loaded
@test "Snort rules are loaded" {
  run grep -q "ICMP Traffic Detected" /usr/local/etc/rules/local.rules
  [ "$status" -eq 0 ]
}

# Test Snort log directory permissions
@test "Snort log directory permissions" {
  run stat -c "%a" /var/log/snort
  [ "$status" -eq 0 ]
  [ "$output" -eq 5775 ]
}

# Test Snort log directory ownership
@test "Snort log directory ownership" {
  run stat -c "%U:%G" /var/log/snort
  [ "$status" -eq 0 ]
  [ "$output" = "snort:snort" ]
}
