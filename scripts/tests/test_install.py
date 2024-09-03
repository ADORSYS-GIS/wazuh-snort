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
    assert (
        interface.name in snort_conf.content_string
    ), f"Interface {interface.name} should be configured in snort.conf"


def test_snort_homenet_configuration(host):
    """Test if Snort is configured with the correct homenet."""
    interface = host.interface.default()
    snort_conf = host.file("/etc/snort/snort.conf")
    homenet = host.run("ip -4 addr show {} | grep -oP '(?<=inet\s)\d+(\.\d+){3}'".format(interface.name)).stdout.strip()

    assert (
        "ipvar HOME_NET {}/24".format(homenet) in snort_conf.content_string
    ), "Snort should be configured with the correct homenet"


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