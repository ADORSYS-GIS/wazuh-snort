$npcapPath = "C:\Program Files\Npcap"
$snortBinPath = "C:\Snort\bin"
$snortUninstallPath = "C:\Snort\uninstall.exe"
$npcapUninstallPath = "C:\Program Files\Npcap\uninstall.exe"
$taskName = "SnortStartup" 
$ossecConfigPath = "C:\Program Files (x86)\ossec-agent\ossec.conf"
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

# Restart wazuh agent
function Restart-WazuhAgent {
    InfoMessage "Restarting wazuh agent..."
    $service = Get-Service -Name WazuhSvc -ErrorAction SilentlyContinue
    if($service) {
        try {
            Restart-Service -Name WazuhSvc -ErrorAction Stop
            InfoMessage "Wazuh Agent restarted succesfully"
        }
        catch {
            ErrorMessage "Failed to restart Wazuh Agent: $($_.Exception.Message)"
        }
    }
    else {
        InfoMessage "Wazuh Service does not exist"
    }
}

function Remove-SystemPath {
    param (
        [string]$PathToRemove
    )

    # Get the current system Path
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

    # Split the Path into an array
    $pathArray = $currentPath -split ';'

    # Check if the specified path exists
    if ($pathArray -contains $PathToRemove) {
        InfoMessage "The path '$PathToRemove' exists in the system Path. Proceeding to remove it."

        # Remove the specified path
        $updatedPathArray = $pathArray | Where-Object { $_ -ne $PathToRemove }

        # Join the array back into a single string
        $updatedPath = ($updatedPathArray -join ';').TrimEnd(';')

        # Update the system Path
        [System.Environment]::SetEnvironmentVariable("Path", $updatedPath, [System.EnvironmentVariableTarget]::Machine)

        InfoMessage "Successfully removed '$PathToRemove' from the system Path."
    } else {
        WarnMessage "The path '$PathToRemove' does not exist in the system Path. No changes were made."
    }
}

# Function to uninstall Snort
function Uninstall-Snort {

    InfoMessage "Uninstalling snort..."
    
    if (-Not (Test-Path $snortUninstallPath)) {
        WarnMessage "Snort uninstaller not found: $snortUninstallPath" skipping
        return
    }

    Start-Process -FilePath $snortUninstallPath -NoNewWindow -Wait

    InfoMessage "Successfully uninstalled snort"
    Remove-SystemPath $snortBinPath
    Remove-ScheduledTask
}


function Uninstall-NpCap {

    InfoMessage "Uninstalling NpCap"

    if (-Not (Test-Path $npcapUninstallPath)) {
        WarnMessage "Npcap uninstaller not found: $npcapUninstallPath" skipping
        return
    }

    Start-Process -FilePath $npcapUninstallPath -NoNewWindow -Wait
    InfoMessage "Succesfully removed NpCap"
    Remove-SystemPath $npcapPath
}

function Remove-Configuration {
    # Restore the ossec.conf file if Snort-related changes were made
    InfoMessage "Removing Snort configuration from ossec.conf"
    
    if (Test-Path -Path $ossecConfigPath) {
        try {
            [xml]$ossecConfig = Get-Content $ossecConfigPath -Raw
            $snortNodes = $ossecConfig.ossec_config.localfile | Where-Object {
                $_.log_format -eq "snort-full" -and $_.location -eq "C:\Snort\log\alert.ids"
            }

            if ($snortNodes.Count -eq 0) {
                WarnMessage "No Snort configuration found in ossec.conf. Skipping removal."
                return
            }

            foreach ($node in $snortNodes) {
                $ossecConfig.ossec_config.RemoveChild($node) | Out-Null
            }
            $ossecConfig.Save($ossecConfigPath)
            InfoMessage "Removed Snort configuration from ossec.conf."
        } catch {
            ErrorMessage "Failed to modify ossec.conf. Check the file format." 
        }
    } else {
        WarnMessage "ossec.conf file not found. Skipping"
    }
}


function Remove-ScheduledTask {

    # Remove the Snort scheduled task
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        InfoMessage "Removed Snort scheduled task."
    } else {
        WarnMessage "Snort scheduled task not found."
    }
    
}
#Remove from Path

function Uninstall-All {
    try {
        Uninstall-NpCap
        Uninstall-Snort
        Remove-Configuration
        Restart-WazuhAgent
        SuccessMessage "Snort and components uninstalled successfully"
    }
    catch {
        ErrorMessage "Snort Uninstall Failed: $($_.Exception.Message)"
    }
}

# Execute the uninstallation function
Uninstall-All
