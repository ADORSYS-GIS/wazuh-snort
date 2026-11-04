# Installation & Setup

This guide covers installing and configuring Snort on Linux, macOS, and Windows, and
connecting Snort to a Wazuh agent.

## Prerequisites

- A **Wazuh agent** installed on the endpoint (required so Snort alerts can be
  forwarded to the Wazuh manager).
- Administrative/root privileges — the scripts use `sudo` (Linux/macOS) or require a
  PowerShell session running as **Administrator** (Windows).
- An internet connection so the scripts can download Snort, rules, and dependencies.

Each install script bootstraps by downloading the relevant shared utility
(`scripts/shared/common.sh` for Linux/macOS, `scripts/shared/common.ps1` for
Windows), verifies its SHA-256 against `checksums.sha256`, and only then proceeds.

## Linux (Ubuntu / Debian)

Install:

```bash
sudo curl -SL https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/scripts/linux/install.sh | bash
```

The script (`scripts/linux/install.sh`):

1. Installs Snort from the package repository (`apt-get install snort`).
2. Detects the default network interface (`ip route show default`) and records it in
   `/etc/snort/snort.debian.conf` (Debian) or `/etc/snort/snort.conf` (non-Debian).
3. Configures `/etc/snort/snort.conf`:
   - alert output written to `snort.alert` (`output alert_fast: snort.alert`),
   - syslog alerting enabled (`output alert_syslog: LOG_AUTH LOG_ALERT`),
   - an ICMP detection rule appended to `/etc/snort/rules/local.rules`,
   - the Snort community rules downloaded from snort.org and
     `include $RULE_PATH/community.rules` added.
4. Restarts the Snort service and validates the installation.

### Verifying the service

```bash
systemctl status snort
```

Snort is also started in the foreground/background writing to `/var/log/snort`.

### Uninstall

```bash
sudo curl -SL https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/scripts/linux/uninstall.sh | bash
```

This purges the Snort packages (`snort`, `snort-common`, `snort-common-libraries`,
`snort-rules-default`), removes `/etc/snort/` and `/var/log/snort`, and validates
that nothing remains.

## macOS

Install:

```bash
curl -SL https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/scripts/macos/install.sh | bash
```

The script (`scripts/macos/install.sh`):

1. Installs Snort 3 via Homebrew (`brew install snort`).
2. Locates the Snort 3 config at `/opt/homebrew/etc/snort/snort.lua` (Apple Silicon)
   or `/usr/local/etc/snort/snort.lua` (Intel).
3. Creates the rules, lists, and log directories and a `local.rules` file with an
   ICMP detection rule.
4. Enables file-based `alert_full` logging in `snort.lua`.
5. Downloads `rules/snort3.rules` as `snort3-community.rules`.
6. Creates and loads a launchd daemon
   (`/Library/LaunchDaemons/com.adorsys.snort.plist`) that runs Snort with
   `-c <snort.lua> -R snort3-community.rules -i en0 -A alert_full -l /var/log/snort`
   and keeps it alive.

### Verifying the service

```bash
sudo launchctl list | grep adorsys
```

Snort alert logs are written to `/var/log/snort`.

### Uninstall

```bash
curl -SL https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/scripts/macos/uninstall.sh | bash
```

This uninstalls Snort via Homebrew, removes the rules/log directories
(`/usr/local/etc/rules`, `/usr/local/etc/so_rules`, `/usr/local/etc/lists`,
`/var/log/snort`), and validates the uninstall.

## Windows

Install, in an **Administrator** PowerShell:

```powershell
Invoke-Expression (Invoke-WebRequest -Uri https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/main/scripts/windows/install.ps1).Content
```

The script (`scripts/windows/install.ps1`) uses configuration from
`scripts/shared/common.ps1` and:

1. Downloads and installs the Snort installer and Npcap.
2. Adds `C:\Snort\bin` and the Npcap directory to the system `PATH`.
3. Downloads `scripts/windows/local.rules` and `scripts/windows/snort.conf` into
   `C:\Snort\`.
4. **Adds a `<localfile>` entry to the Wazuh agent's `ossec.conf`** pointing at
   `C:\Snort\log\alert.ids` with `log_format snort-full`.
5. Registers a scheduled task (`SnortStartup`) that runs Snort at startup as
   `SYSTEM`.

### Verifying the service

```powershell
Get-ScheduledTask -TaskName SnortStartup
Get-Process snort
```

Snort alerts are written to `C:\Snort\log\alert.ids`.

### Uninstall

Run `scripts/windows/uninstall.ps1` as Administrator. It uninstalls Npcap and Snort,
removes the Snort `<localfile>` block from `ossec.conf`, removes the `SnortStartup`
scheduled task, cleans the `PATH`, and restarts the Wazuh agent.

## Connecting Snort to the Wazuh agent

The Wazuh agent reads the Snort alert log through a `<localfile>` entry in its
`ossec.conf`. The Windows installer adds this automatically; on Linux and macOS it
must be added manually.

Add a `<localfile>` block (inside the `<ossec_config>` element) matching the alert
log path Snort writes to:

```xml
<localfile>
  <log_format>snort-full</log_format>
  <location>/var/log/snort/snort.alert</location>
</localfile>
```

- **Linux:** `/var/log/snort/snort.alert` (the install script configures
  `output alert_fast: snort.alert`).
- **macOS:** `/var/log/snort` (Snort 3 `alert_full`).
- **Windows:** `C:\Snort\log\alert.ids` — added automatically by the installer.

After editing `ossec.conf`, restart the Wazuh agent:

```bash
# Linux
sudo systemctl restart wazuh-agent
# or
/var/ossec/bin/wazuh-control restart
```

```powershell
# Windows
Restart-Service WazuhSvc
```

Once configured, Snort events are forwarded to the Wazuh manager and can be searched
in the Wazuh dashboard.
