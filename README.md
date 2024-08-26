![Workflow Status](https://github.com/ADORSYS-GIS/wazuh-snort/actions/workflows/snort-build.yml/badge.svg)

# Wazuh Snort 
This repository contains several resources for installing and configuring Snort, as well as its integration with Wazuh. Here is a detailed description of each item:

## Directory Contents

- `Dockerfile`: A Docker file to create a Docker image.
- `helm`: This folder contains a Helm chart for installing Snort in DaemonSet mode in a Kubernetes cluster and monitoring it.
- `README.md`: This file provides general information about the project.
- `rules`: This folder contains the rules for configuring Snort.
- `scripts`: This folder contains a script for installing and configuring Snort on Linux and MacOS.

## Description

1. **Helm Chart**: The Helm chart in the `helm` folder allows you to install Snort in DaemonSet mode in a Kubernetes cluster. This allows Snort to run on each node of the cluster, providing cluster-wide network monitoring.

2. **Scripts**: The `scripts` folder contains a script that facilitates the installation and configuration of Snort on Linux and MacOS systems.

3. **Integration with Wazuh**: This repository also contains the necessary configurations for integrating Snort with Wazuh, an open-source security tool for intrusion detection, endpoint security, and compliance monitoring.

For more information on using these resources, please refer to the specific instructions in each folder.