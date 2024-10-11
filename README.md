[![Build Snort3 Docker Multi Arch](https://github.com/ADORSYS-GIS/wazuh-snort/actions/workflows/snort-build.yml/badge.svg)](https://github.com/ADORSYS-GIS/wazuh-snort/actions/workflows/snort-build.yml)[![Build and Package Snort 3](https://github.com/ADORSYS-GIS/wazuh-snort/actions/workflows/package-snort.yml/badge.svg?branch=main)](https://github.com/ADORSYS-GIS/wazuh-snort/actions/workflows/package-snort.yml)[![Run Snort tests](https://github.com/ADORSYS-GIS/wazuh-snort/actions/workflows/snort-tests.yml/badge.svg)](https://github.com/ADORSYS-GIS/wazuh-snort/actions/workflows/snort-tests.yml)
# Wazuh Snort 
This repository contains several resources for installing and configuring Snort, as well as its integration with Wazuh. Here is a detailed description of each item:


# Overview
**Wazuh snort**  is a project focused on integrating Snort with Wazuh to improve network security monitoring and threat detection. By combining Snort's network intrusion detection capabilities with Wazuh’s host-based security monitoring, this integration enhances overall security visibility and response.

## Features
- **Network Intrusion Detection**: Monitors network traffic for suspicious activity and potential threats.
- **Signature-Based Detection**: Uses predefined rules (signatures) to identify known threats and malicious activities.
- **Protocol Analysis**: Inspects and analyzes network protocols to detect anomalies and unauthorized activities.
- **Real-Time Alerting**: Provides real-time alerts and notifications for detected threats and suspicious behavior.
- **Customizable Rules**: Allows users to create and customize detection rules based on specific network environments and security needs.

## Supported Operating Systems
- **Ubuntu**
- **macOS**
- **Windows**

## Directory Contents

- `Dockerfile`: A Docker file to create a Docker image.
- `helm`: This folder contains a Helm chart for installing Snort in DaemonSet mode in a Kubernetes cluster and monitoring it.
- `README.md`: This file provides general information about the project.
- `rules`: This folder contains the rules for configuring Snort.
- `scripts`: This folder contains a script for installing and configuring Snort on Linux and MacOS. It also includes a README with instructions for building and packaging Snort 3 using GitHub Actions.
- `scripts/tests`: Additionally, for details on testing with Pytest and Powershell, see **[scripts/tests/README.md](scripts/tests/README.md)**

## Getting Started
### Prerequisites
- Wazuh Agent installed on endpoints

### Installation 
## Installation (Linux)
Install using this command:
   ```bash
   sudo curl -SL https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/scripts/install.sh | bash
   ```
   ## Installation (MacOS)
   Install using this command:
      ```bash
      curl -SL https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/main/scripts/install.sh | bash
      ```

   ## Installation (Windows)
   To install on Windows, follow these steps in PowerShell:

    1. Execute the installation script directly:
         ```powershell
         Invoke-Expression (Invoke-WebRequest -Uri https://raw.githubusercontent.com/ADORSYS-GIS/wazuh-snort/refs/heads/main/scripts/windows/snort.ps1).Content
         ```

## Description

1. **Helm Chart**: The Helm chart in the `helm` folder allows you to install Snort in DaemonSet mode in a Kubernetes cluster. This allows Snort to run on each node of the cluster, providing cluster-wide network monitoring.

2. **Scripts**: The `scripts` folder contains a script that facilitates the installation and configuration of Snort on Linux and MacOS systems. Additionally, it automates the process of building and packaging Snort 3 for `amd64` and `arm64` architectures using GitHub Actions.

3. **Integration with Wazuh**: This repository also contains the necessary configurations for integrating Snort with Wazuh, an open-source security tool for intrusion detection, endpoint security, and compliance monitoring.

## Snort 3 Build and Packaging

This repository automates the process of building and packaging Snort 3 for `amd64` and `arm64` architectures using GitHub Actions.

### Objective

The goal of this project is to simplify the Snort 3 build and packaging process. By leveraging GitHub Actions, you can automatically generate `.deb` packages for Snort 3, eliminating the need for manual builds.

### How to Use

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/ADORSYS-GIS/wazuh-snort.git
   cd wazuh-snort
   ```

2. **Trigger a Build:**
   - Push changes to the `main` branch or open a pull request to automatically trigger the build and packaging process.

3. **Retrieve the Packages:**
   - After the build completes, download the generated `.deb` packages from the corresponding GitHub Release.

## License

This project is licensed under the MIT License.

