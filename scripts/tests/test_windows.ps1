# Check if Snort is installed
function Test-SnortInstalled {
    $snortPath = "C:\Snort\bin\snort.exe"
    if (Test-Path $snortPath) {
        Write-Output "Snort is installed."
    } else {
        Write-Output "Snort is not installed."
        exit 1
    }
}

# Check if Npcap is installed
function Test-NpcapInstalled {
    $npcapPath = "C:\Program Files\Npcap"
    if (Test-Path $npcapPath) {
        Write-Output "Npcap is installed."
    } else {
        Write-Output "Npcap is not installed."
        exit 1
    }
}

# Check if rules directory exists
function Test-RulesDirectoryExists {
    $rulesDir = "C:\Snort\rules"
    if (Test-Path $rulesDir) {
        Write-Output "Rules directory exists."
    } else {
        Write-Output "Rules directory does not exist."
        exit 1
    }
}

# Check if local rules file exists
function Test-LocalRulesFileExists {
    $localRulesFile = "C:\Snort\rules\local.rules"
    if (Test-Path $localRulesFile) {
        Write-Output "Local rules file exists."
    } else {
        Write-Output "Local rules file does not exist."
        exit 1
    }
}

# Check if Snort configuration file exists
function Test-SnortConfFileExists {
    $snortConfFile = "C:\Snort\etc\snort.conf"
    if (Test-Path $snortConfFile) {
        Write-Output "Snort configuration file exists."
    } else {
        Write-Output "Snort configuration file does not exist."
        exit 1
    }
}

# Check if OSSEC configuration file exists
function Test-OssecConfFileExists {
    $ossecConfFile = "C:\Program Files\Wazuh\ossec.conf"
    if (Test-Path $ossecConfFile) {
        Write-Output "OSSEC configuration file exists."
    } else {
        Write-Output "OSSEC configuration file does not exist."
        exit 1
    }
}

# Check if Snort is configured in OSSEC configuration
function Test-SnortConfigInOssecConf {
    $ossecConfFile = "C:\Program Files\Wazuh\ossec.conf"
    if (Select-String -Path $ossecConfFile -Pattern "snort") {
        Write-Output "Snort is configured in OSSEC configuration."
    } else {
        Write-Output "Snort is not configured in OSSEC configuration."
        exit 1
    }
}

# Check environment variables
function Test-EnvironmentVariables {
    $snortPath = [System.Environment]::GetEnvironmentVariable("SNORT_PATH")
    if ($snortPath) {
        Write-Output "SNORT_PATH environment variable is set."
    } else {
        Write-Output "SNORT_PATH environment variable is not set."
        exit 1
    }
}

# Check if scheduled task is registered
function Test-ScheduledTaskRegistered {
    $taskName = "SnortTask"
    $task = Get-ScheduledTask | Where-Object { $_.TaskName -eq $taskName }
    if ($task) {
        Write-Output "Scheduled task is registered."
    } else {
        Write-Output "Scheduled task is not registered."
        exit 1
    }
}

# Run all tests
Test-SnortInstalled
Test-NpcapInstalled
Test-RulesDirectoryExists
Test-LocalRulesFileExists
Test-SnortConfFileExists
Test-OssecConfFileExists
Test-SnortConfigInOssecConf
Test-EnvironmentVariables
Test-ScheduledTaskRegistered
