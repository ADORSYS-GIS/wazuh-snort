import pytest
import testinfra

WAZUH_MANAGER = "10.0.0.2"
OSSEC_CONF_PATH = "/var/ossec/etc/ossec.conf"

@pytest.fixture(scope="module")
def install_dependencies(host):
    """Install dependencies and run the install script."""
    os = host.system_info.distribution
    if os in ["ubuntu", "debian"]:
        host.run("apt-get update")
        host.run("apt-get install -y curl gnupg2 iproute2")
        host.run("curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import")
        host.run("chmod 644 /usr/share/keyrings/wazuh.gpg")

        if not host.file("/etc/apt/sources.list.d/wazuh.list").exists:
            host.run("echo 'deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main' | tee /etc/apt/sources.list.d/wazuh.list")
        
        host.run("apt-get update")
        host.run("apt-get install -y wazuh-agent")
        host.run(f"sed -i 's|MANAGER_IP|{WAZUH_MANAGER}|g' {OSSEC_CONF_PATH}")

    elif os == "alpine":
        host.run("wget -O /etc/apk/keys/alpine-devel@wazuh.com-633d7457.rsa.pub https://packages.wazuh.com/key/alpine-devel%40wazuh.com-633d7457.rsa.pub")
        host.run("echo 'https://packages.wazuh.com/4.x/alpine/v3.12/main' | tee /etc/apk/repositories")
        host.run("apk update")
        host.run("apk add wazuh-agent")
        host.run(f"sed -i 's|MANAGER_IP|{WAZUH_MANAGER}|g' {OSSEC_CONF_PATH}")
    
    else:
        pytest.fail("Unsupported OS for Wazuh installation")

    result = host.run("bash /app/scripts/install.sh")
    assert result.rc == 0, f"Installation failed: {result.stderr}"

@pytest.mark.usefixtures("install_dependencies")
def test_snort_is_installed(host):
    """Test if Snort is installed."""
    snort = host.package("snort")
    assert snort.is_installed, "Snort should be installed"

def test_snort_conf_file_exists(host):
    """Test if snort.conf file exists."""
    snort_conf = host.file("/etc/snort/snort.conf")
    assert snort_conf.exists, "snort.conf file should exist"

def test_snort_default_interface_configured(host):
    """Test if the default network interface is correctly configured in snort.conf."""
    interface = host.interface.default
    snort_conf = host.file("/etc/snort/snort.conf")
    assert interface.name in snort_conf.content_string, f"Interface {interface.name} should be configured in snort.conf"

def test_home_net_configured_in_snort(host):
    """Test if HOME_NET is correctly configured in snort.conf."""
    interface = host.interface("default")
    home_net = host.check_output(f"ip -o -f inet addr show {interface.name} | awk '/scope global/ {{print $4}}'")
    snort_conf = host.file("/etc/snort/snort.conf")
    assert f"ipvar HOME_NET [{home_net}]" in snort_conf.content_string, f"HOME_NET should be configured as {home_net} in snort.conf"

def test_ossec_conf_updated_with_snort(host):
    """Test if ossec.conf is updated with Snort logging configuration."""
    ossec_conf = host.file("/var/ossec/etc/ossec.conf")
    snort_log_config = """
        <!-- snort -->
        <localfile>
            <log_format>snort-full</log_format>
            <location>/var/log/snort/snort.alert.fast</location>
        </localfile>
    """
    assert snort_log_config.strip() in ossec_conf.content_string, "ossec.conf should contain the Snort logging configuration"