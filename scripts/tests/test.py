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

    elif os == "darwin":  # macOS
        host.run("brew install curl gnupg2 iproute2")

    else:
        pytest.fail("Unsupported OS for dependency installation")


@pytest.mark.usefixtures("install_dependencies")
def test_snort_is_installed(host):
    """Test if Snort is installed."""
    snort = host.package("snort")
    assert snort.is_installed, "Snort should be installed"


def test_snort_conf_file_exists(host):
    """Test if snort configuration file exists."""
    os = host.system_info.distribution
    if os == "darwin":  # macOS
        snort_conf = host.file("/usr/local/etc/snort/snort.lua")
    else:
        snort_conf = host.file("/etc/snort/snort.conf")
        
    assert snort_conf.exists, "snort.conf file should exist"


def test_snort_interface_configuration(host):
    """Test if the network interface is correctly configured in the Snort configuration file."""
    os = host.system_info.distribution
    interface = host.run("ip route | grep default | awk '{print $5}'").stdout.strip()
    
    if os == "darwin":  # macOS
        snort_conf = host.file("/usr/local/etc/snort/snort.lua")
    else:
        snort_conf = host.file("/etc/snort/snort.debian.conf")
    
    assert interface in snort_conf.content_string, "Interface should be present in Snort configuration file"


def test_update_ossec_conf_linux(host):
    """Test if ossec.conf is updated on Linux."""
    os = host.system_info.distribution
    if os == "darwin":  # macOS
        ossec_conf_path = "/usr/local/etc/ossec.conf"
        expected_content = """
            <!-- snort -->
            <localfile>
                <log_format>snort-full</log_format>
                <location>/usr/local/var/log/snort/snort.alert.fast</location>
            """
    else:
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
    ), "ossec.conf should be updated accordingly"
