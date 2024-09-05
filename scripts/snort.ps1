function Install-Snort {
    # Define paths and URLs
    $tempDir = "C:\Temp"
    $snortInstallerUrl = "https://www.snort.org/downloads/snort/Snort_2_9_20_Installer.x64.exe"
    $snortInstallerPath = "$tempDir\Snort_Installer.exe"
    $npcapInstallerUrl = "https://npcap.com/dist/npcap-1.79.exe"
    $npcapInstallerPath = "$tempDir\Npcap_Installer.exe"
    $winpcapInstallerUrl = "https://www.winpcap.org/install/bin/WinPcap_4_1_3.exe"
    $winpcapInstallerPath = "$tempDir\WinPcap_Installer.exe"
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
            Invoke-WebRequest -Uri $url -OutFile $outputPath
            Write-Host "Downloaded $url to $outputPath"
        } catch {
            Write-Host "Failed to download $url"
            exit 1
        }
    }

    # Download and install Snort
    Download-File $snortInstallerUrl $snortInstallerPath
    Start-Process -FilePath $snortInstallerPath -ArgumentList "/S" -Wait

    # Download and install WinPcap
    Download-File $winpcapInstallerUrl $winpcapInstallerPath
    Start-Process -FilePath $winpcapInstallerPath -ArgumentList "/S" -Wait

    # Download Npcap (manual installation required)
    Download-File $npcapInstallerUrl $npcapInstallerPath
    Start-Process -FilePath $npcapInstallerPath -Wait
    Write-Host "Please follow the on-screen instructions to complete the Npcap installation."

    # Add environment variables
    $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$snortBinPath;$npcapPath", "Machine")

    # Create the rules directory if it does not exist
    if (-Not (Test-Path -Path $rulesDir)) {
        New-Item -ItemType Directory -Force -Path $rulesDir
    }

    # Define the rules
    $rules = @(
        'alert icmp any any -> any any (msg:"ICMP connection attempt:"; sid:1000010; rev:1;)',
        'alert tcp any any -> any 80 (msg:"HTTP traffic detected"; sid:1000020; rev:1;)',
        'alert tcp any any -> any 22 (msg:"SSH traffic detected"; sid:1000030; rev:1;)',
        'alert tcp any any -> any 21 (msg:"FTP traffic detected"; sid:1000040; rev:1;)',
        'alert tcp any any -> any 25 (msg:"SMTP traffic detected"; sid:1000050; rev:1;)',
        'alert icmp any any -> any any (msg:"ICMP Testing Rule"; sid:1000001; rev:1;)',
        'alert tcp any any -> any 80 (msg:"TCP Testing Rule"; sid:1000002; rev:1;)',
        'alert udp any any -> any any (msg:"UDP Testing Rule"; sid:1000003; rev:1;)'
    )

    # Write the rules to the file, ensuring correct encoding
    $rules | Set-Content -Path $rulesFile -Encoding UTF8

    # Add Snort configuration to ossec.conf
    $snortConfig = @"
<!-- snort -->
<localfile>
  <log_format>snort-full</log_format>
  <location>/var/log/snort/snort.alert.fast</location>
</localfile>
"@

    if (Test-Path $ossecConfigPath) {
        $ossecConfigContent = Get-Content $ossecConfigPath
        $ossecConfigContent = $ossecConfigContent -replace "</ossec_config>", "$snortConfig</ossec_config>"
        Set-Content -Path $ossecConfigPath -Value $ossecConfigContent
        Write-Host "Snort configuration added to ossec.conf."
    } else {
        Write-Host "ossec.conf file not found."
    }

    # Add configurations to snort.conf
    $snortAdditions = @"
output alert_syslog: LOG_AUTH LOG_ALERT
output alert_fast: snort.alert
config logdir: C:\Snort\log
var RULE_PATH C:\Snort\rules
var PREPROC_RULE_PATH C:\Snort\preproc_rules
var WHITE_LIST_PATH C:\Snort\rules
var BLACK_LIST_PATH C:\Snort\rules
dynamicpreprocessor directory C:\Snort\lib\snort_dynamicpreprocessor
dynamicengine C:\Snort\lib\snort_dynamicengine\sf_engine.dll
preprocessor sfportscan: proto { all } memcap { 10000000 } sense_level { low }
include \$PREPROC_RULE_PATH\preprocessor.rules
include \$PREPROC_RULE_PATH\decoder.rules
include \$PREPROC_RULE_PATH\sensitive-data.rules
"@

    if (Test-Path $snortConfigPath) {
        Add-Content -Path $snortConfigPath -Value $snortAdditions
        Write-Host "Configurations added to snort.conf."
    } else {
        Write-Host "snort.conf file not found."
    }

    Write-Host "Installation and configuration completed!"
}

Install-Snort
