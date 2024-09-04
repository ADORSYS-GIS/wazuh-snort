import pytest
import testinfra
import subprocess


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
    print("Default network interface:", interface)



def test_snort_interface_configuration(host):
    # Read the interface value from the snort configuration file
    snort_config = host.file("/etc/snort/snort.debian.conf").content_string
    interface_line = [line for line in snort_config.split('\n') if line.startswith('DEBIAN_SNORT_INTERFACE=')]
    
    # Ensure the interface line is found
    assert len(interface_line) == 1
    
    # Extract the interface value
    interface_value = interface_line[0].split('=')[1].strip().strip('"')
    
    # Check if the interface value is not empty
    assert interface_value != ""




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




    