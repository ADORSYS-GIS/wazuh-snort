# Set strict mode for error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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
        [string]$Color = "White"
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

function ErrorExit {
    param ([string]$Message)
    ErrorMessage $Message
    exit 1
}

function Ensure-Admin {
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        ErrorExit "This script requires administrative privileges. Please run it as Administrator."
    }
}

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

function Get-FileChecksum {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) {
        throw "File not found: $FilePath"
    }
    return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash.ToLower()
}

function Test-Checksum {
    param(
        [string]$FilePath,
        [string]$ExpectedHash
    )
    $actualHash = Get-FileChecksum -FilePath $FilePath
    if ($actualHash -ne $ExpectedHash.ToLower()) {
        ErrorMessage "Checksum verification FAILED for $FilePath!"
        ErrorMessage "  Expected: $ExpectedHash"
        ErrorMessage "  Got:      $actualHash"
        return $false
    }
    return $true
}

function Download-File {
    param(
        [string]$Url,
        [string]$Destination,
        [string]$Description = "file",
        [int]$MaxRetries = 3
    )

    InfoMessage "Downloading $Description..."

    $destDir = Split-Path -Parent $Destination
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }

    $attempt = 0
    while ($attempt -lt $MaxRetries) {
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
            SuccessMessage "$Description downloaded successfully"
            return
        } catch {
            $attempt++
            if ($attempt -lt $MaxRetries) {
                WarnMessage "Download failed, retrying ($attempt/$MaxRetries)..."
                Start-Sleep -Seconds 2
            }
        }
    }

    ErrorExit "Failed to download $Description from $Url after $MaxRetries attempts"
}

function Download-And-VerifyFile {
    param(
        [string]$Url,
        [string]$Destination,
        [string]$ChecksumPattern,
        [string]$FileName = "Unknown file",
        [string]$ChecksumFile = $global:ChecksumsPath,
        [string]$ChecksumUrl = $null
    )

    Download-File -Url $Url -Destination $Destination -Description $FileName

    # If a direct checksum URL is provided, download it and use it as the source of truth
    if (-not [string]::IsNullOrWhiteSpace($ChecksumUrl)) {
        $tempChecksumFile = Join-Path ([System.IO.Path]::GetTempPath()) "checksums-$([System.Guid]::NewGuid().ToString()).sha256"
        Download-File -Url $ChecksumUrl -Destination $tempChecksumFile -Description "checksum file"
        $ChecksumFile = $tempChecksumFile
    }

    if (-not [string]::IsNullOrWhiteSpace($ChecksumFile) -and (Test-Path -Path $ChecksumFile)) {
        $expectedHash = (Select-String -Path $ChecksumFile -Pattern $ChecksumPattern).Line.Split(" ")[0].Trim()
        if (-not [string]::IsNullOrWhiteSpace($expectedHash)) {
            if (-not (Test-Checksum -FilePath $Destination -ExpectedHash $expectedHash)) {
                ErrorExit "$FileName checksum verification failed"
            }
            InfoMessage "$FileName checksum verification passed."
        } else {
            ErrorExit "No checksum found for $FileName in $ChecksumFile using pattern $ChecksumPattern"
        }

        # Cleanup temporary checksum file if it was downloaded from a URL
        if (-not [string]::IsNullOrWhiteSpace($ChecksumUrl) -and (Test-Path -Path $ChecksumFile)) {
            Remove-Item -Path $ChecksumFile -Force -ErrorAction SilentlyContinue
        }
    } else {
        ErrorExit "Checksum file not found at $ChecksumFile, cannot verify $FileName"
    }

    SuccessMessage "$FileName downloaded and verified successfully."
    return $true
}

function Remove-SystemPath {
    param (
        [string]$PathToRemove
    )
    try {
        $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
        $pathArray = $currentPath -split ';'
        if ($pathArray -contains $PathToRemove) {
            InfoMessage "The path '$PathToRemove' exists in the system Path. Proceeding to remove it."
            $updatedPathArray = $pathArray | Where-Object { $_ -ne $PathToRemove }
            $updatedPath = ($updatedPathArray -join ';').TrimEnd(';')
            [System.Environment]::SetEnvironmentVariable("Path", $updatedPath, [System.EnvironmentVariableTarget]::Machine)
            InfoMessage "Successfully removed '$PathToRemove' from the system Path."
        } else {
            WarnMessage "The path '$PathToRemove' does not exist in the system Path. No changes were made."
        }
    } catch {
        ErrorMessage "Failed to update system Path: $_"
    }
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
