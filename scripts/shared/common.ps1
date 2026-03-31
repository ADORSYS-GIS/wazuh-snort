# Global configuration for Windows Snort scripts
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

# Check if command exists
function Command-Exists {
    param (
        [Parameter(Mandatory)]
        [string]$Command
    )
    return Get-Command $Command -ErrorAction SilentlyContinue
}

# Validate common installation requirements
function Validate-InstallationCommon {
    InfoMessage "Validating base installation..."
    
    # Check if Snort is installed
    if (-not (Test-Path $global:Config.SnortExePath)) {
        ErrorMessage "Snort binary is not present."
        exit 1
    }
    SuccessMessage "Snort binary is present."
    
    return 0
}

# Validate common uninstallation requirements  
function Validate-UninstallationCommon {
    InfoMessage "Validating uninstallation..."
    
    # Check if Snort is still installed
    if (Test-Path $global:Config.SnortExePath) {
        ErrorMessage "Snort is still installed. Uninstallation failed."
        exit 1
    }
    
    SuccessMessage "Snort successfully uninstalled"
    return 0
}
