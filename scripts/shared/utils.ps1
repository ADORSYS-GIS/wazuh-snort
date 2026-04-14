# Centralized Utility Functions for Windows Scripts
# Designed to be downloaded and sourced via a bootstrap mechanism

# Configuration object
$global:Config = @{
    SnortExePath         = "C:\Snort\bin\snort.exe"
    SnortBinPath         = "C:\Snort\bin"
    SnortConfigPath      = "C:\Snort\etc\snort.conf"
    SnortInstallerPath   = "C:\Temp\snort-installer.exe"
    SnortInstallerUrl    = "https://www.snort.org/downloads/snort/snort3-installer.exe"
    SnortLogDir          = "C:\Snort\log"
    SnortUninstallPath   = "C:\Snort\Uninstall.exe"
    NpcapPath            = "C:\Program Files\Npcap"
    NpcapInstallerPath   = "C:\Temp\npcap-installer.exe"
    NpcapInstallerUrl    = "https://npcap.com/dist/npcap-latest.exe"
    NpcapUninstallPath   = "C:\Program Files\Npcap\Uninstall.exe"
    OssecConfigPath      = "C:\Program Files (x86)\ossec-agent\ossec.conf"
    RulesDir             = "C:\Snort\etc\rules"
    TempDir              = "C:\Temp\wazuh-snort"
    TaskName             = "SnortIDS"
    LocalRulesUrl        = "https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/configs/local.rules"
    SnortConfUrl         = "https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/configs/snort.conf"
}

# Function for logging with timestamp
function Write-Log {
    param(
        [string]$Level,
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$timestamp $Level $Message"
}

# Logging helpers
function InfoMessage {
    param([string]$Message)
    Write-Log -Level "[INFO]" -Message $Message
}

function WarnMessage {
    param([string]$Message)
    Write-Log -Level "[WARNING]" -Message $Message
}

function ErrorMessage {
    param([string]$Message)
    Write-Log -Level "[ERROR]" -Message $Message
}

function SuccessMessage {
    param([string]$Message)
    Write-Log -Level "[SUCCESS]" -Message $Message
}

# Check if running as administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Ensure script is running as administrator
function Ensure-Admin {
    if (-not (Test-Administrator)) {
        ErrorMessage "This script requires administrative privileges. Please run as Administrator."
        exit 1
    }
}

# Download file with retry
function Download-File {
    param(
        [Parameter(Mandatory)]
        [string]$Url,
        [Parameter(Mandatory)]
        [string]$OutputPath,
        [int]$MaxRetries = 3
    )

    $retryCount = 0
    $success = $false

    while ($retryCount -lt $MaxRetries -and -not $success) {
        try {
            $directory = Split-Path -Parent $OutputPath
            if (-not (Test-Path $directory)) {
                New-Item -Path $directory -ItemType Directory -Force | Out-Null
            }

            Invoke-WebRequest -Uri $Url -OutFile $OutputPath -ErrorAction Stop
            $success = $true
            SuccessMessage "File downloaded successfully to $OutputPath"
        }
        catch {
            $retryCount++
            ErrorMessage "Download failed (attempt $retryCount of $MaxRetries): $($_.Exception.Message)"
            if ($retryCount -lt $MaxRetries) {
                Start-Sleep -Seconds 2
            }
        }
    }

    if (-not $success) {
        ErrorMessage "Failed to download file from $Url after $MaxRetries attempts"
        exit 1
    }
}

# Ensure directory exists
function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        InfoMessage "Created directory: $Path"
    }
}

# Validate base installation
function Validate-InstallationCommon {
    InfoMessage "Validating base installation..."
    
    if (-not (Test-Path $global:Config.SnortExePath)) {
        ErrorMessage "Snort is not installed on this system. Please install it and rerun the script."
        exit 1
    }
    
    SuccessMessage "Snort binary is present."
}

# Validate uninstallation
function Validate-UninstallationCommon {
    InfoMessage "Validating uninstallation..."
    
    if (Test-Path $global:Config.SnortExePath) {
        ErrorMessage "Snort is still installed. Uninstallation failed."
        exit 1
    }
    
    SuccessMessage "Snort has been successfully uninstalled."
}
