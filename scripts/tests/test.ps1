# Initialize a list to store test results
$testResults = @()

# Function to run a test and log the result
function Run-Test {
    param (
        [string]$TestName,
        [scriptblock]$TestScript
    )

    try {
        & $TestScript
        $testResults += [pscustomobject]@{ TestName = $TestName; Status = "Passed" }
    } catch {
        $testResults += [pscustomobject]@{ TestName = $TestName; Status = "Failed"; Error = $_.Exception.Message }
    }
}

# Define the test scripts
$tests = @{
    "SnortInstalled" = { 
        if (Test-Path "C:\Snort\bin\snort.exe") { 
            Write-Output "Snort is installed." 
        } else { 
            throw "Snort is not installed." 
        }
    }
    "NpcapInstalled" = { 
        if (Test-Path "C:\Program Files\Npcap") { 
            Write-Output "Npcap is installed." 
        } else { 
            throw "Npcap is not installed." 
        }
    }
    "RulesDirectoryExists" = { 
        if (Test-Path "C:\Snort\rules") { 
            Write-Output "Rules directory exists." 
        } else { 
            throw "Rules directory does not exist." 
        }
    }
    "LocalRulesFileExists" = { 
        if (Test-Path "C:\Snort\rules\local.rules") { 
            Write-Output "Local rules file exists." 
        } else { 
            throw "Local rules file does not exist." 
        }
    }
    "SnortConfFileExists" = { 
        if (Test-Path "C:\Snort\etc\snort.conf") { 
            Write-Output "Snort configuration file exists." 
        } else { 
            throw "Snort configuration file does not exist." 
        }
    }
    "OssecConfFileExists" = { 
        if (Test-Path "C:\Program Files\Wazuh\ossec.conf") { 
            Write-Output "OSSEC configuration file exists." 
        } else { 
            throw "OSSEC configuration file does not exist." 
        }
    }
    "SnortConfigInOssecConf" = { 
        if (Select-String -Path "C:\Program Files\Wazuh\ossec.conf" -Pattern "snort") { 
            Write-Output "Snort is configured in OSSEC configuration." 
        } else { 
            throw "Snort is not configured in OSSEC configuration." 
        }
    }
    "EnvironmentVariables" = { 
        if ([System.Environment]::GetEnvironmentVariable("SNORT_PATH") -ne $null) { 
            Write-Output "SNORT_PATH environment variable is set." 
        } else { 
            throw "SNORT_PATH environment variable is not set." 
        }
    }
    "ScheduledTaskRegistered" = { 
        $task = Get-ScheduledTask | Where-Object { $_.TaskName -eq "SnortTask" }
        if ($task) { 
            Write-Output "Scheduled task is registered." 
        } else { 
            throw "Scheduled task is not registered." 
        }
    }
}

# Run all tests
foreach ($test in $tests.GetEnumerator()) {
    Run-Test -TestName $test.Key -TestScript $test.Value
}

# Output the test results
Write-Output "Test Results:"
$testResults | Format-Table -AutoSize
