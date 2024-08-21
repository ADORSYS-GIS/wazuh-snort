#!/usr/bin/env bats

WAZUH_MANAGER="10.0.0.2"

if [ "$(uname -o)" = "GNU/Linux" ] && command -v groupadd >/dev/null 2>&1; then
    apt-get update && apt-get install -y curl gnupg2
    (curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import)
    chmod 644 /usr/share/keyrings/wazuh.gpg
    echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
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

# Test if the script runs without errors
@test "script runs without errors" {
  run /app/scripts/install.sh
  [ "$status" -eq 0 ]
}

# Test if Snort is installed
@test "Snort is installed" {
  run dpkg -l | grep -q snort
  [ "$status" -eq 0 ]
}

# Test if Snort directories were created
@test "Snort directories were created" {
  /app/scripts/install.sh
  [ -d "/var/log/snort" ]
  [ -d "/etc/snort/rules" ]
}

# Test if Snort local rules file was created
@test "Snort local rules file created" {
  /app/scripts/install.sh
  [ -f "/etc/snort/rules/local.rules" ]
}

# Test if ossec.conf was updated
@test "ossec.conf updated" {
  /app/scripts/install.sh
  grep -q '<log_format>snort-full<\/log_format>' "$OSSEC_CONF_PATH"
  grep -q '<location>\/var\/log\/snort\/snort.alert.fast<\/location>' "$OSSEC_CONF_PATH"
}

# Test if Snort was started
@test "Snort started" {
  /app/scripts/install.sh
  run systemctl status snort
  [ "$status" -eq 0 ]
}
