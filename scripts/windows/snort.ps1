# Global configuration
$global:Config = @{
    TempDir            = "C:\Temp"
    SnortInstallerUrl  = "https://www.snort.org/downloads/snort/Snort_2_9_20_Installer.x64.exe"
    SnortInstallerPath = "C:\Temp\Snort_Installer.exe"
    NpcapInstallerUrl  = "https://npcap.com/dist/npcap-1.79.exe"
    NpcapInstallerPath = "C:\Temp\Npcap_Installer.exe"
    SnortBinPath       = "C:\Snort\bin"
    SnortExePath       = "C:\Snort\bin\snort.exe"
    NpcapPath          = "C:\Program Files\Npcap"
    RulesDir           = "C:\Snort\rules"
    OssecConfigPath    = "C:\Program Files (x86)\ossec-agent\ossec.conf"
    SnortConfigPath    = "C:\Snort\etc\snort.conf"
    LocalRulesUrl      = "https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/main/scripts/windows/local.rules"
    SnortConfUrl       = "https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/main/scripts/windows/snort.conf"
    SnortLogDir        = "C:\Snort\log"
    TaskName           = "SnortStartup"
}

# Function to handle logging

function Log {
    param (
        [string]$Level,
        [string]$Message,
        [string]$Color = "White"  # Default color
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$Timestamp $Level $Message" -ForegroundColor $Color
}

# Logging helpers with colors
function InfoMessage {
    param ([string]$Message)
    Log "[INFO]" $Message "White"
}

function WarnMessage {
    param ([string]$Message)
    Log "[WARNING]" $Message "Yellow"
}

function ErrorMessage {
    param ([string]$Message)
    Log "[ERROR]" $Message "Red"
}

function SuccessMessage {
    param ([string]$Message)
    Log "[SUCCESS]" $Message "Green"
}

function PrintStep {
    param (
        [int]$StepNumber,
        [string]$Message
    )
    Log "[STEP]" "Step ${StepNumber}: $Message" "White"
}

# Helper: Create a directory if it doesn't exist.
function Ensure-Directory {
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )
    if (-Not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        InfoMessage "Created directory: $Path"
    }
}

# Helper: Download a file from a URL.
function Download-File {
    param (
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$OutputPath
    )
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -Headers @{"User-Agent"="Mozilla/5.0"} -ErrorAction Stop
        InfoMessage "Downloaded file from $Url to $OutputPath"
    }
    catch {
        ErrorMessage "Failed to download file from $Url. $_"
    }
}

# Install Snort (only run once)
function Install-SnortSoftware {
    if (Test-Path $global:Config.SnortExePath) {
        WarnMessage "Snort is already installed. Skipping installation."
    }
    else {
        InfoMessage "Downloading Snort installer..."
        Download-File -Url $global:Config.SnortInstallerUrl -OutputPath $global:Config.SnortInstallerPath
        InfoMessage "Installing Snort..."
        Start-Process -FilePath $global:Config.SnortInstallerPath -ArgumentList "/S" -Wait
    }
}

# Install Npcap (only run once)
function Install-NpcapSoftware {
    if (Test-Path $global:Config.NpcapPath) {
        WarnMessage "Npcap is already installed. Skipping installation."
    }
    else {
        InfoMessage "Downloading Npcap installer..."
        Download-File -Url $global:Config.NpcapInstallerUrl -OutputPath $global:Config.NpcapInstallerPath
        InfoMessage "Installing Npcap..."
        Start-Process -FilePath $global:Config.NpcapInstallerPath -Wait
        InfoMessage "Please follow the on-screen instructions to complete the Npcap installation."
    }
}

# Update environment variables to include Snort and Npcap directories.
function Update-EnvironmentVariables {
    $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $newPath = "$envPath;$($global:Config.SnortBinPath);$($global:Config.NpcapPath)"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    InfoMessage "Environment PATH updated with Snort and Npcap directories."
}

# Update local.rules file.
function Update-RulesFile {
    $localRulesTempPath = Join-Path -Path $global:Config.TempDir -ChildPath "local.rules"
    Download-File -Url $global:Config.LocalRulesUrl -OutputPath $localRulesTempPath

    Ensure-Directory -Path $global:Config.RulesDir
    $rulesFile = Join-Path -Path $global:Config.RulesDir -ChildPath "local.rules"
    
    if (Test-Path $localRulesTempPath) {
        Copy-Item -Path $localRulesTempPath -Destination $rulesFile -Force
        InfoMessage "local.rules file replaced."
    }
    else {
        ErrorMessage "Failed to download local.rules file."
    }
}

# Update ossec.conf by adding the Snort configuration node.
function Update-OSSECConfig {
    if (Test-Path $global:Config.OssecConfigPath) {
        try {
            [xml]$ossecConfig = Get-Content $global:Config.OssecConfigPath -Raw
        }
        catch {
            ErrorMessage "Failed to load ossec.conf as XML. Please check the file format."
            return
        }
        
        $snortLogFormat   = "snort-full"
        $snortAlertLocation = "C:\Snort\log\alert.ids"
        $nodeExists = $false

        foreach ($localfile in $ossecConfig.ossec_config.localfile) {
            if ($localfile.log_format -eq $snortLogFormat -and $localfile.location -eq $snortAlertLocation) {
                $nodeExists = $true
                break
            }
        }
        if (-not $nodeExists) {
            $newNode = $ossecConfig.CreateElement("localfile")
            $logFormat = $ossecConfig.CreateElement("log_format")
            $logFormat.InnerText = $snortLogFormat
            $location = $ossecConfig.CreateElement("location")
            $location.InnerText = $snortAlertLocation

            $newNode.AppendChild($logFormat) | Out-Null
            $newNode.AppendChild($location) | Out-Null
            $ossecConfig.ossec_config.AppendChild($newNode) | Out-Null

            $ossecConfig.Save($global:Config.OssecConfigPath)
            InfoMessage "Snort configuration added to ossec.conf." 
        }
        else {
            WarnMessage "Snort configuration already exists in ossec.conf. Skipping addition."
        }
    }
    else {
        ErrorMessage "ossec.conf file not found at $($global:Config.OssecConfigPath)."
    }
}

# Update snort.conf file.
function Update-SnortConf {
    $snortConfTempPath = Join-Path -Path $global:Config.TempDir -ChildPath "snort.conf"
    Download-File -Url $global:Config.SnortConfUrl -OutputPath $snortConfTempPath

    if (Test-Path $snortConfTempPath) {
        Copy-Item -Path $snortConfTempPath -Destination $global:Config.SnortConfigPath -Force
        InfoMessage "snort.conf file replaced."
    }
    else {
        ErrorMessage "Failed to download snort.conf file."
    }
}

# Register Snort as a scheduled task to run at startup.
function Register-SnortScheduledTask {
    # Ensure Snort executable and config paths are defined
    $exePath   = $global:Config.SnortExePath
    $cfgPath   = $global:Config.SnortConfigPath
    $logDir    = $global:Config.SnortLogDir

    if (-not (Test-Path $exePath)) {
        ErrorMessage "Cannot register Snort scheduled task: Snort executable not found at $exePath."
        return
    }
    if (-not (Test-Path $cfgPath)) {
        ErrorMessage "Cannot register Snort scheduled task: Config file not found at $cfgPath."
        return
    }
    if (-not (Test-Path $logDir)) {
        ErrorMessage "Cannot register Snort scheduled task: Log directory not found at $logDir."
        return
    }

    InfoMessage "Snort Exe Path: $exePath"
    InfoMessage "Snort Config Path: $cfgPath"
    InfoMessage "Snort Log Directory: $logDir"

    # Build the argument string, quoting each path for safety
    $arguments = "-c `"$cfgPath`" -A full -l `"$logDir`""

    # Create action, trigger, and settings
    $taskAction   = New-ScheduledTaskAction    -Execute $exePath    -Argument $arguments
    $taskTrigger  = New-ScheduledTaskTrigger   -AtStartup
    $taskSettings = New-ScheduledTaskSettingsSet -Hidden `
                                                  -AllowStartIfOnBatteries `
                                                  -DontStopIfGoingOnBatteries `
                                                  -StartWhenAvailable `
                                                  -RunOnlyIfNetworkAvailable

    # If a task with this name already exists, unregister it so we can replace it
    if (Get-ScheduledTask -TaskName $global:Config.TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $global:Config.TaskName -Confirm:$false
        WarnMessage "Scheduled Task already exists; unregistering so we can update it."
    }

    # Register new task running as SYSTEM at the highest run level
    Register-ScheduledTask -TaskName  $global:Config.TaskName `
                           -Action    $taskAction       `
                           -Trigger   $taskTrigger      `
                           -Settings  $taskSettings     `
                           -User      "SYSTEM"          `
                           -RunLevel  Highest

    InfoMessage "Registered Snort to run at startup as SYSTEM."
}


# Main function that runs the installation and configuration steps.
function Install-Snort {
    # Ensure the temporary directory exists.
    Ensure-Directory -Path $global:Config.TempDir

    InfoMessage "=== Installing Snort ==="
    Install-SnortSoftware

    InfoMessage "=== Installing Npcap ==="
    Install-NpcapSoftware

    InfoMessage "=== Updating Environment Variables ==="
    Update-EnvironmentVariables

    InfoMessage "=== Updating local.rules file ==="
    Update-RulesFile

    InfoMessage "=== Updating ossec.conf ==="
    Update-OSSECConfig

    InfoMessage "=== Updating snort.conf ==="
    Update-SnortConf

    # Clean up temporary files.
    Remove-Item -Path $global:Config.TempDir -Recurse -Force
    InfoMessage "Cleaned up temporary directory: $($global:Config.TempDir)"

    InfoMessage "=== Registering Scheduled Task ==="
    Register-SnortScheduledTask

    SuccessMessage "Installation and configuration completed!"
}

# Execute the main installation function.
Install-Snort
