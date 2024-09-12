import pytest
import testinfra

@pytest.fixture(scope="module")
def install_dependencies(host):
    """Install dependencies for macOS."""
    os = host.system_info.distribution

    if os == "darwin":  # macOS
        host.run("brew install curl gnupg2 iproute2")
    else:
        pytest.fail("This test is only for macOS")

@pytest.mark.usefixtures("install_dependencies")
def test_snort_is_installed_mac(host):
    """Test if Snort is installed on macOS."""
    snort = host.package("snort")
    assert snort.is_installed, "Snort should be installed"


def test_snort_conf_file_exists_mac(host):
    """Test if snort.lua file exists on macOS."""
    snort_conf = host.file("/usr/local/etc/snort/snort.lua")
    assert snort_conf.exists, "snort.lua file should exist"


def test_snort_interface_configuration_mac(host):
    """Test if the network interface is correctly configured in the Snort configuration file on macOS."""
    interface = host.run("ip route | grep default | awk '{print $5}'").stdout.strip()
    
    # Read the snort configuration file
    snort_conf = host.file("/usr/local/etc/snort/snort.lua")
    assert interface in snort_conf.content_string, "Interface should be present in snort.lua"


def test_update_ossec_conf_mac(host):
    """Test if ossec.conf is correctly updated on macOS."""
    ossec_conf_path = "/usr/local/etc/ossec.conf"
    expected_content = """
        <!-- snort -->
        <localfile>
            <log_format>snort-full</log_format>
            <location>/usr/local/var/log/snort/snort.alert.fast</location>
        """

    ossec_conf = host.file(ossec_conf_path)
    assert (
        expected_content.strip() in ossec_conf.content_string.strip()
    ), "ossec.conf should be updated correctly on macOS"