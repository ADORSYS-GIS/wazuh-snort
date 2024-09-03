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


def test_default_network_interface(host):
    # Check if the default network interface is correctly identified
    interface = host.run("ip route | grep default | awk '{print $5}'").stdout.strip()
    assert interface != ""  # Ensure an interface is found

# def test_home_network_ip(host):
#     # Check if the HOME_NET is correctly set in the configuration file
#     interface = host.run("ip route | grep default | awk '{print $5}'").stdout.strip()
#     homenet = host.run(f"ip -4 addr show {interface} | grep -oP r'(?<=inet\s)\d+(\.\d+){3}'").stdout.strip()
#     conf_file = host.file("/etc/snort/snort.conf")
#     print(f"Home Network IP: {homenet}")
#     print(f"Configuration File Content:\n{conf_file.content_string}")
#     assert conf_file.contains(f"ipvar HOME_NET {homenet}/24")

# def test_snort_configuration_file(host):
#     """Verify the Snort configuration file contains the correct settings."""
#     conf_file = host.file("/etc/snort/snort.conf")
#     interface = host.run("ip route | grep default | awk '{print $5}'").stdout.strip()
#     print(f"Network Interface: {interface}")
#     print(f"Configuration File Content:\n{conf_file.content_string}")
#     assert conf_file.contains(f"config interface: {interface}")


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



    