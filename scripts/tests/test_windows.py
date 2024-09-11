import pytest
import testinfra

@pytest.fixture
def host():
    return testinfra.get_host("local://")

def test_snort_installed(host):
    snort_bin = host.file("C:\\Snort\\bin\\snort.exe")
    assert snort_bin.exists
    assert snort_bin.is_file

def test_npcap_installed(host):
    npcap_dir = host.file("C:\\Program Files\\Npcap")
    assert npcap_dir.exists
    assert npcap_dir.is_directory

def test_rules_directory_exists(host):
    rules_dir = host.file("C:\\Snort\\rules")
    assert rules_dir.exists
    assert rules_dir.is_directory

def test_local_rules_file_exists(host):
    local_rules = host.file("C:\\Snort\\rules\\local.rules")
    assert local_rules.exists
    assert local_rules.is_file

def test_snort_conf_file_exists(host):
    snort_conf = host.file("C:\\Snort\\etc\\snort.conf")
    assert snort_conf.exists
    assert snort_conf.is_file

def test_ossec_conf_file_exists(host):
    ossec_conf = host.file("C:\\Program Files (x86)\\ossec-agent\\ossec.conf")
    assert ossec_conf.exists
    assert ossec_conf.is_file

def test_snort_config_in_ossec_conf(host):
    ossec_conf = host.file("C:\\Program Files (x86)\\ossec-agent\\ossec.conf")
    assert ossec_conf.contains("<!-- snort -->")
    assert ossec_conf.contains("<localfile>")
    assert ossec_conf.contains("<log_format>snort-full</log_format>")
    assert ossec_conf.contains("<location>C:\\Snort\\log\\alert.ids</location>")
    assert ossec_conf.contains("</localfile>")

def test_environment_variables(host):
    env_path = host.check_output("echo %PATH%")
    assert "C:\\Snort\\bin" in env_path
    assert "C:\\Program Files\\Npcap" in env_path

def test_scheduled_task_registered(host):
    task_list = host.check_output("schtasks /Query /TN SnortStartup")
    assert "SnortStartup" in task_list
