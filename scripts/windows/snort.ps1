# Function to install Snort
function Install-Snort {
    # Define paths and URLs
    $tempDir = "C:\Temp"
    $snortInstallerUrl = "https://www.snort.org/downloads/snort/Snort_2_9_20_Installer.x64.exe"
    $snortInstallerPath = "$tempDir\Snort_Installer.exe"
    $npcapInstallerUrl = "https://npcap.com/dist/npcap-1.79.exe"
    $npcapInstallerPath = "$tempDir\Npcap_Installer.exe"
    $snortBinPath = "C:\Snort\bin"
    $npcapPath = "C:\Program Files\Npcap"
    $rulesDir = "C:\Snort\rules"
    $rulesFile = Join-Path -Path $rulesDir -ChildPath "local.rules"
    $ossecConfigPath = "C:\Program Files (x86)\ossec-agent\ossec.conf"
    $snortConfigPath = "C:\Snort\etc\snort.conf"

    # Create the C:\Temp directory if it doesn't exist
    if (-Not (Test-Path -Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir
    }

    # Function to download a file
    function Download-File($url, $outputPath) {
        try {
            curl.exe -L $url -o $outputPath
            Write-Host "Downloaded $url to $outputPath"
        } catch {
            Write-Host "Failed to download $url"
            exit 1
        }
    }

    # Download and install Snort
    Invoke-WebRequest -Uri $snortInstallerUrl -OutFile $snortInstallerPath -Headers @{"User-Agent"="Mozilla/5.0"}
    Start-Process -FilePath $snortInstallerPath -ArgumentList "/S" -Wait

    # Download Npcap (manual installation required)
    Invoke-WebRequest $npcapInstallerUrl -OutFile $npcapInstallerPath
    Start-Process -FilePath $npcapInstallerPath -Wait
    Write-Host "Please follow the on-screen instructions to complete the Npcap installation."

    # Add environment variables
    $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$snortBinPath;$npcapPath", "Machine")

    # Create the rules directory if it does not exist
    if (-Not (Test-Path -Path $rulesDir)) {
        New-Item -ItemType Directory -Force -Path $rulesDir
    }

    # Download the local.rules file
    $localRulesUrl = "https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/main/scripts/windows/local.rules" #todo: update the URL
    $localRulesPath = "$tempDir\local.rules"
    Invoke-WebRequest -Uri $localRulesUrl -OutFile $localRulesPath

    # Replace the existing local.rules file
    if (Test-Path $localRulesPath) {
        Copy-Item -Path $localRulesPath -Destination $rulesFile -Force
        Write-Host "local.rules file replaced."
    } else {
        Write-Host "Failed to download local.rules file."
    }

    # Add Snort configuration to ossec.conf
    $snortConfig = @"
<!-- snort -->
<localfile>
    <log_format>snort-full</log_format>
    <location>C:\Snort\log\alert.ids</location>
</localfile>
"@

    if (Test-Path $ossecConfigPath) {
        $ossecConfigContent = Get-Content $ossecConfigPath
        $ossecConfigContent -replace "</ossec_config>", "$snortConfig</ossec_config>" | Set-Content $ossecConfigPath
        Write-Host "Snort configuration added to ossec.conf."
    } else {
        Write-Host "ossec.conf file not found."
    }

    # Download the new snort.conf file
    $snortConfUrl = "https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/main/scripts/windows/snort.conf" #todo: update the URL
    $snortConfPath = "$tempDir\snort.conf"
    Invoke-WebRequest -Uri $snortConfUrl -OutFile $snortConfPath

    # Replace the existing snort.conf file
    if (Test-Path $snortConfPath) {
        Copy-Item -Path $snortConfPath -Destination $snortConfigPath -Force
        Write-Host "snort.conf file replaced."
    } else {
        Write-Host "Failed to download snort.conf file."
    }
    
    # Delete temp directory
    Remove-Item -Path $tempDir -Recurse -Force

    # Register Snort as a scheduled task to run at startup
    $taskName = "SnortStartup"
    $taskAction = New-ScheduledTaskAction -Execute "C:\Snort\bin\snort.exe" -Argument "-c C:\Snort\etc\snort.conf -A full -l C:\Snort\log\ -i 5 -A console"
    $taskTrigger = New-ScheduledTaskTrigger -AtStartup
    $taskSettings = New-ScheduledTaskSettingsSet -Hidden

    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Scheduled Task already exists, Unregisting to Update Scheduled Task"
    }
    Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger - Settings $taskSettings -RunLevel Highest 
    Write-Host "Registering Snort to Run at Startup"


    Write-Host "Installation and configuration completed!"
}

Install-Snort