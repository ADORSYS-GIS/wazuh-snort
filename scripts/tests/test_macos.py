import pytest
import testinfra

@pytest.fixture(scope="module")
def install_dependencies(host):
    """Install dependencies for macOS."""
    host.run("brew install curl gnupg2 iproute2")

@pytest.mark.usefixtures("install_dependencies")
def test_snort_is_installed_mac(host):
    """Test if Snort is installed on macOS."""
    snort = host.package("snort")
    assert snort.is_installed, "Snort should be installed"

def test_snort_conf_file_exists_mac(host):
    """Test if snort.lua file exists on macOS."""
    snort_conf = host.file("/opt/homebrew/etc/snort/snort.lua")
    assert snort_conf.exists, "snort.lua file should exist"

def test_snort_interface_configuration_mac(host):
    """Test if the network interface is correctly configured in the Snort configuration file on macOS."""
    interface = host.run("ip route | grep default | awk '{print $5}'").stdout.strip()
    snort_conf = host.file("/opt/homebrew/etc/snort/snort.lua")
    assert interface in snort_conf.content_string, "Interface should be present in snort.lua"

def test_update_ossec_conf_mac(host):
    """Test if ossec.conf is correctly updated on macOS."""
    ossec_conf_path = "/opt/homebrew/etc/snort/snort.lua"
    expected_content = """
<location>/var/log/snort/alert_fast.txt</location>
    """

    ossec_conf = host.file(ossec_conf_path)
    assert (
        expected_content.strip() in ossec_conf.content_string.strip()
    ), "ossec.conf should be updated correctly on macOS"
