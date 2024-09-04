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

@pytest.fixture
def host_interface_and_homenet(host):
    # Get the default network interface
    interface = host.check_output("ip route | grep default | awk '{print $5}'").strip()
    
    # Get the IP address associated with this interface
    homenet = host.check_output(f"ip -4 addr show {interface} | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}(?=/)'").strip()
    
    if not homenet:
        pytest.fail(f"Failed to retrieve IP address for interface {interface}")

    return interface, homenet

@pytest.fixture
def snort_conf(host):
    return host.file("/etc/snort/snort.conf")

@pytest.mark.usefixtures("install_dependencies")
def test_snort_is_installed(host):
    """Test if Snort is installed."""
    snort = host.package("snort")
    assert snort.is_installed, "Snort should be installed"

def test_snort_conf_file_exists(host):
    """Test if snort.conf file exists."""
    snort_conf = host.file("/etc/snort/snort.conf")
    assert snort_conf.exists, "snort.conf file should exist"

def test_home_net_defined(snort_conf, host_interface_and_homenet):
    """Test if HOME_NET is correctly defined in snort.conf."""
    _, homenet = host_interface_and_homenet
    assert snort_conf.contains(f"var HOME_NET {homenet}"), f"HOME_NET {homenet} is not correctly defined in snort.conf"

def test_interface_defined(snort_conf, host_interface_and_homenet):
    """Test if the network interface is correctly defined in snort.conf."""
    interface, _ = host_interface_and_homenet
    assert snort_conf.contains(f"interface: {interface}"), f"Network interface {interface} is not correctly defined in snort.conf"

def test_default_network_interface(host):
    """Check if the default network interface is correctly identified."""
    interface = host.run("ip route | grep default | awk '{print $5}'").stdout.strip()
    assert interface != "", "A network interface should be found"

def test_update_ossec_conf_linux(host):
    """Test if ossec.conf is updated on Linux."""
    ossec_conf_path = "/var/ossec/etc/ossec.conf"
    expected_content = """
        <!-- snort -->
        <localfile>
            <log_format>snort-full</log_format>
            <location>/var/log/snort/snort.alert.fast</location>
        """

    ossec_conf = host.file(ossec_conf_path)
    assert (
        expected_content.strip() in ossec_conf.content_string.strip()
    ), "ossec.conf should be updated on Linux"

