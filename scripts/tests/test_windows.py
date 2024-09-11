import pytest
import testinfra
import os

def get_windows_host():
    # Configure the backend to use a Windows host
    host = testinfra.get_host("local://")
    return host

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
    ossec_conf = host.file("C:\\Program Files\\ossec-agent\\ossec.conf")
    assert ossec_conf.exists

def test_snort_config_in_ossec_conf():
    host = get_windows_host()
    ossec_conf = host.file("C:\\Program Files\\ossec-agent\\ossec.conf")
    assert ossec_conf.contains("snort")

def test_environment_variables():
    host = get_windows_host()
    env_vars = host.run("set")
    assert "SNORT_HOME" in env_vars.stdout

def test_scheduled_task_registered():
    host = get_windows_host()
    task = host.run("schtasks /Query /TN SnortTask")
    assert "SnortTask" in task.stdout