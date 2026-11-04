# wazuh-snort Documentation

The `wazuh-snort` repository contains resources for installing and configuring Snort,
as well as integrating it with Wazuh to improve network security monitoring and threat
detection. It provides a Helm chart, installation and configuration scripts for Linux,
macOS, and Windows, and Snort rules.

## SDLC map

| Phase | Folder | Contents |
| :---- | :----- | :------- |
| Architecture | [`architecture/`](architecture/overview.md) | Architecture overview of Snort + Wazuh integration |
| Operations | [`operations/`](operations/installation.md) | Installation, Kubernetes deployment, runbooks |
| Development | [`development/`](development/ci.md) | CI/CD, build & packaging |
| Reference | [`reference/`](reference/rules.md) | Cross-cutting reference (rules) |
| Decisions | [`adr/`](adr/README.md) | Architecture Decision Records index |

> Only folders that exist are listed. `testing/` will be added when test documentation
> is produced; `adr/` currently holds an index stub because no ADRs have been recorded
> yet.

## Quick links

| Link | Description |
| :--- | :---------- |
| [Architecture overview](architecture/overview.md) | How Snort integrates with the Wazuh agent and the event flow |
| [Installation & Setup](operations/installation.md) | Install/uninstall on Linux, macOS, Windows |
| [Kubernetes deployment](operations/kubernetes.md) | Deploying Snort via the Helm DaemonSet chart |
| [Building & packaging Snort 3](development/build-and-package.md) | Building `.deb` packages via GitHub Actions |
| [CI/CD overview](development/ci.md) | The GitHub Actions workflows and what they do |
| [Rules reference](reference/rules.md) | The Snort rules and configuration |
| [ADR index](adr/README.md) | Architecture Decision Records (none recorded yet) |
