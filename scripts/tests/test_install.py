import pytest
import testinfra

@pytest.fixture(scope="module")
def install_dependencies(host):
    """Install dependencies and run the install script."""
    os = host.system_info.distribution
    
    if os in ["ubuntu", "debian"]:
        host.run("apt-get update")
        host.run("apt-get install -y curl gnupg2 iproute2")

    elif os == "alpine":
        host.run("apk update")
        host.run("apk add curl gnupg2 iproute2")

    else:
        pytest.fail("Unsupported OS for dependency installation")

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
    interface = host.interface.default()
    snort_conf = host.file("/etc/snort/snort.conf")
    assert interface.name in snort_conf.content_string, f"Interface {interface.name} should be configured in snort.conf"

def test_home_net_configured_in_snort(host):
    """Test if HOME_NET is correctly configured in snort.conf."""
    interface = host.interface("default")
    home_net = host.check_output(f"ip -o -f inet addr show {interface.name} | awk '/scope global/ {{print $4}}'")
    snort_conf = host.file("/etc/snort/snort.conf")
    
    # Adjust the expected format based on how it is defined in snort.conf
    expected_home_net = f"ipvar HOME_NET [{home_net}]"
    
    assert expected_home_net in snort_conf.content_string, f"HOME_NET should be configured as {home_net} in snort.conf"

def test_ossec_conf_updated_with_snort(host):
    """Test if ossec.conf is updated with Snort logging configuration."""
    ossec_conf = host.file("/var/ossec/etc/ossec.conf")
    snort_log_config = """
    <!-- snort -->
    <localfile>
        <log_format>snort-full</log_format>
        <location>/var/log/snort/snort.alert.fast</location>
    </localfile>
    """.strip()
    
    assert snort_log_config in ossec_conf.content_string, "ossec.conf should contain the Snort logging configuration"
