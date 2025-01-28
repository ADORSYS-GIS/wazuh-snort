# Function to uninstall Snort and associated changes
function Uninstall-Snort {
    # Define paths and variables
    $tempDir = "C:\Temp"
    $snortBinPath = "C:\Snort\bin"
    $snortPath = "C:\Snort"
    $npcapPath = "C:\Program Files\Npcap"
    $rulesDir = "C:\Snort\rules"
    $ossecConfigPath = "C:\Program Files (x86)\ossec-agent\ossec.conf"
    $taskName = "SnortStartup"

    # Remove the Snort directory and its contents
    if (Test-Path -Path $snortPath) {
        Remove-Item -Path $snortPath -Recurse -Force
        Write-Host "Removed Snort directory and its contents."
    } else {
        Write-Host "Snort directory not found."
    }

    # Remove Npcap if installed
    if (Test-Path -Path $npcapPath) {
        $npcapUninstallPath = Join-Path -Path $npcapPath -ChildPath "Uninstall.exe"
        if (Test-Path -Path $npcapUninstallPath) {
            Start-Process -FilePath $npcapUninstallPath -ArgumentList "/S" -Wait
            Write-Host "Npcap uninstalled."
        } else {
            Write-Host "Npcap uninstall executable not found."
        }
    } else {
        Write-Host "Npcap directory not found."
    }

    # Remove Snort-specific environment variables
    $envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $newEnvPath = $envPath -replace [regex]::Escape(";$snortBinPath;$npcapPath"), ""
    [Environment]::SetEnvironmentVariable("Path", $newEnvPath, "Machine")
    Write-Host "Removed Snort and Npcap from environment variables."

    # Restore the ossec.conf file if Snort-related changes were made
    if (Test-Path -Path $ossecConfigPath) {
        try {
            [xml]$ossecConfig = Get-Content $ossecConfigPath -Raw
            $snortNodes = $ossecConfig.ossec_config.localfile | Where-Object {
                $_.log_format -eq "snort-full" -and $_.location -eq "C:\Snort\log\alert.ids"
            }
            foreach ($node in $snortNodes) {
                $ossecConfig.ossec_config.RemoveChild($node) | Out-Null
            }
            $ossecConfig.Save($ossecConfigPath)
            Write-Host "Removed Snort configuration from ossec.conf."
        } catch {
            Write-Host "Failed to modify ossec.conf. Check the file format." -ForegroundColor Red
        }
    } else {
        Write-Host "ossec.conf file not found."
    }

    # Remove the Snort scheduled task
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Removed Snort scheduled task."
    } else {
        Write-Host "Snort scheduled task not found."
    }

    # Clean up the temporary directory
    if (Test-Path -Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
        Write-Host "Removed temporary directory."
    } else {
        Write-Host "Temporary directory not found."
    }

    Write-Host "Uninstallation and cleanup completed!"
}

# Execute the uninstallation function
Uninstall-Snort
