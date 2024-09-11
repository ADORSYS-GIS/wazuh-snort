import pytest
import testinfra
import os

def get_windows_host():
    # Configure the backend to use a Windows host
    backend = testinfra.get_backend("local://")
    return testinfra.host.Host(backend)

def test_snort_installed():
    host = get_windows_host()
    snort_bin = host.file("C:\\Snort\\bin\\snort.exe")
    assert snort_bin.exists

def test_npcap_installed():
    host = get_windows_host()
    npcap_dir = host.file("C:\\Program Files\\Npcap")
    assert npcap_dir.exists

def test_rules_directory_exists():
    host = get_windows_host()
    rules_dir = host.file("C:\\Snort\\rules")
    assert rules_dir.exists

def test_local_rules_file_exists():
    host = get_windows_host()
    local_rules = host.file("C:\\Snort\\rules\\local.rules")
    assert local_rules.exists

def test_snort_conf_file_exists():
    host = get_windows_host()
    snort_conf = host.file("C:\\Snort\\etc\\snort.conf")
    assert snort_conf.exists

def test_ossec_conf_file_exists():
    host = get_windows_host()
    ossec_conf = host.file("C:\\Program Files (x86)\\ossec-agent\\ossec.conf")
    assert ossec_conf.exists

def test_snort_config_in_ossec_conf():
    host = get_windows_host()
    ossec_conf = host.file("C:\\Program Files (x86)\\ossec-agent\\ossec.conf")
    assert ossec_conf.contains("<!-- snort -->")
    assert ossec_conf.contains("<localfile>")
    assert ossec_conf.contains("<log_format>snort-full</log_format>")
    assert ossec_conf.contains("<location>C:\\Snort\\log\\alert.ids</location>")
    assert ossec_conf.contains("</localfile>")

def test_environment_variables():
    host = get_windows_host()
    env_path = host.check_output("echo %PATH%")
    if isinstance(env_path, bytes):
        env_path = env_path.decode("utf-8")
    assert "C:\\Snort\\bin" in env_path
    assert "C:\\Program Files\\Npcap" in env_path

def test_scheduled_task_registered():
    host = get_windows_host()
    task_list = host.check_output("schtasks /Query /TN SnortStartup")
    if isinstance(task_list, bytes):
        task_list = task_list.decode("utf-8")
    assert "SnortStartup" in task_list