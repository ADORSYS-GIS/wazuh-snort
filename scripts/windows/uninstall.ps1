# Download and source common helper functions
$commonUrl = "https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/refactor/split-linux-macos-scripts/scripts/shared/common.ps1"
$commonPath = Join-Path -Path $global:Config.TempDir -ChildPath "common.ps1"

try {
    Invoke-WebRequest -Uri $commonUrl -OutFile $commonPath -Headers @{"User-Agent"="Mozilla/5.0"} -ErrorAction Stop
    . "$commonPath"
    InfoMessage "Loaded common helper functions"
}
catch {
    ErrorMessage "Failed to download common helper functions: $_"
    exit 1
}

# Function to uninstall Snort
function Uninstall-Snort {
    InfoMessage "Uninstalling snort..."
    
    if (-Not (Test-Path $snortUninstallPath)) {
        WarnMessage "Snort uninstaller not found: $snortUninstallPath" skipping
        return
    }

    Start-Process -FilePath $global:Config.SnortUninstallPath -NoNewWindow -Wait
    InfoMessage "Successfully uninstalled snort"
    Remove-SystemPath $global:Config.SnortBinPath
    return 0
}

# Function to uninstall Npcap
function Uninstall-NpCap {
    InfoMessage "Uninstalling NpCap"

    if (-Not (Test-Path $global:Config.NpcapUninstallPath)) {
        WarnMessage "Npcap uninstaller not found: $global:Config.NpcapUninstallPath skipping"
        return
    }

    Start-Process -FilePath $global:Config.NpcapUninstallPath -NoNewWindow -Wait
    InfoMessage "Successsfully removed NpCap"
    Remove-SystemPath $global:Config.NpcapPath
    return 0
}

# Function to remove Snort configuration from OSSEC
function Remove-Configuration {
    # Restore ossec.conf file if Snort-related changes were made
    InfoMessage "Removing Snort configuration from ossec.conf"
    
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
        $snortNodes = $ossecConfig.ossec_config.localfile | Where-Object {
            $_.log_format -eq $snortLogFormat -and $_.location -eq $snortAlertLocation
        }

        if ($snortNodes.Count -gt 0) {
            foreach ($node in $snortNodes) {
                $ossecConfig.ossec_config.RemoveChild($node) | Out-Null
            }
            $ossecConfig.Save($global:Config.OssecConfigPath)
            InfoMessage "Removed Snort configuration from ossec.conf."
        }
        else {
            WarnMessage "No Snort configuration found in ossec.conf. Skipping removal."
        }
    }
    else {
        WarnMessage "ossec.conf file not found. Skipping"
    }
    return 0
}

# Function to remove scheduled task
function Remove-ScheduledTask {
    # Remove the Snort scheduled task
    if (Get-ScheduledTask -TaskName $global:Config.TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $global:Config.TaskName -Confirm:$false
        InfoMessage "Removed Snort scheduled task."
    }
    else {
        WarnMessage "Snort scheduled task not found."
    }
    return 0
}

# Function to remove path from system PATH
function Remove-SystemPath {
    param (
        [Parameter(Mandatory)]
        [string]$PathToRemove
    )

    # Get current system Path
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

    # Split Path into an array
    $pathArray = $currentPath -split ';'

    # Check if specified path exists
    if ($pathArray -contains $PathToRemove) {
        InfoMessage "The path '$PathToRemove' exists in system Path. Proceeding to remove it."

        # Remove the specified path
        $updatedPathArray = $pathArray | Where-Object { $_ -ne $PathToRemove }

        # Join array back into a single string
        $updatedPath = ($updatedPathArray -join ';').TrimEnd(';')

        # Update system Path
        [System.Environment]::SetEnvironmentVariable("Path", $updatedPath, [System.EnvironmentVariableTarget]::Machine)

        InfoMessage "Successfully removed '$PathToRemove' from system Path."
    }
    else {
        WarnMessage "The path '$PathToRemove' does not exist in system Path. No changes were made."
    }
    return 0
}

# Function to restart Wazuh agent
function Restart-WazuhAgent {
    InfoMessage "Restarting wazuh agent..."
    $service = Get-Service -Name WazuhSvc -ErrorAction SilentlyContinue
    if($service) {
        try {
            Restart-Service -Name WazuhSvc -ErrorAction Stop
            InfoMessage "Wazuh Agent restarted successfully"
        }
        catch {
            ErrorMessage "Failed to restart Wazuh Agent: $($_.Exception.Message)"
        }
    }
    else {
        InfoMessage "Wazuh Service does not exist"
    }
    return 0
}

# Main uninstall function
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

# Execute the main uninstall function
Uninstall-All

# Validate uninstallation
Validate-UninstallationCommon