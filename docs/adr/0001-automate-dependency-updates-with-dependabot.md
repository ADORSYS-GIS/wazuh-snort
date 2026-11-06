# ADR-0001: Automate Dependency Updates with Dependabot

- Status: Accepted
- Date: 2026-11-06
- Authors: @chojuninengu
- Deciders: Wazuh Security Operations Team
- Consulted: @t-desmond
- Informed: Wazuh Security Operations Team
- Relations:
  - Implements: [ADORSYS-GIS/wazuh-snort#37](https://github.com/ADORSYS-GIS/wazuh-snort/issues/37)
  - Part of: [ADORSYS-GIS/wazuh#2354](https://github.com/ADORSYS-GIS/wazuh/issues/2354)

## Context

The `wazuh-snort` repository maintains Snort NIDS rules, integration scripts, and a Docker container for network intrusion detection within the Wazuh SIEM ecosystem. Dependencies include:
1. Docker base images in `Dockerfile`.
2. Third-party GitHub Actions steps used across CI workflows in `.github/workflows/`.

Without automated tracking, base images and CI actions accumulate security vulnerabilities and technical debt. Automated dependency updates are necessary to ensure timely patching, maintain audit compliance, and align with organization security baselines.

## Decision

Enable and configure GitHub Dependabot for `wazuh-snort` via `.github/dependabot.yml` tracking both Docker and GitHub Actions ecosystems.

Configuration standard (aligned with organizational baseline established in `wazuh-cert-oauth2`):
- Ecosystems:
  - `docker` (daily at 08:00 UTC)
  - `github-actions` (weekly on Mondays at 08:00 UTC)
- Open pull requests limit: 10
- Cooldown period: 7 days

## Options Considered

### Option 1: GitHub Dependabot (Selected)
- Native GitHub integration with zero external infrastructure requirements.
- Native support for Dockerfiles and GitHub Actions.
- Predictable scheduling and cooldown controls.

### Option 2: Renovate Bot
- Rich feature set but introduces unnecessary operational overhead and third-party app permissions.

### Option 3: Manual Version Bumping
- High operational overhead and prone to delayed security remediation.

## Consequences

### Positive
- Automatic pull requests for base image CVE patches and CI action updates.
- Standardized review cadence matching other Wazuh repositories.
- Reduced manual maintenance overhead.

### Negative / Trade-offs
- Increased PR volume requiring CI verification and code reviews.
- Mitigated by rate limits (`open-pull-requests-limit: 10`) and cooldown periods (`default-days: 7`).

## Rollout / Rollback Plan

- Rollout: Merge `.github/dependabot.yml` into `main`. Dependabot will automatically activate and open update PRs according to schedule.
- Rollback: Revert the commit introducing `.github/dependabot.yml`.
