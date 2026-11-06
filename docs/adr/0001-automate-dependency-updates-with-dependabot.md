# ADR-0001: Automate Dependency Updates with Dependabot

> We introduce GitHub Dependabot configuration across all tracked package ecosystems (Docker base images and GitHub Actions workflows) to automate dependency updates with pull request limits and cool-down buffers.

## Metadata

| Field             | Value                                              |
| :---------------- | :------------------------------------------------- |
| **Document ID**   | ADR-0001                                           |
| **Status**        | `Accepted`                                         |
| **Date**          | 2026-11-06                                         |
| **Deciders**      | Wazuh maintainers                                  |
| **Governs**       | `.github/dependabot.yml`                           |
| **Amends**        | N/A                                                |
| **Amended by**    | N/A                                                |
| **Supersedes**    | N/A                                                |
| **Superseded by** | N/A                                                |

## Context

The `wazuh-snort` repository maintains Snort NIDS rules, integration scripts, and container assets for network intrusion detection within the Wazuh SIEM ecosystem. Dependencies are present in two primary areas:
1. **Docker base images (docker)**: Dependencies specified in `Dockerfile` defining builder runtimes and runtime container environments.
2. **CI/CD Actions (github-actions)**: GitHub Actions referenced across workflows in `.github/workflows/` (`ci.yml`, `helm-publish.yml`, `package-snort.yml`, `snort-build.yml`).

Previously, container base images and CI action dependencies were updated manually or ad-hoc. This introduces operational and security risks:
- Outdated Docker base images may harbor known vulnerabilities (CVEs) and miss critical upstream security patches.
- Outdated GitHub Actions may rely on deprecated Node.js runner runtimes, eventually causing CI pipelines to fail.
- Infrequent large batch updates carry higher regression risk than incremental, continuous version bumps.

Under Epic ADORSYS-GIS/wazuh#2354, all actively maintained repositories in the ADORSYS-GIS organization are standardized on automated dependency maintenance using Dependabot, modeled after `wazuh-cert-oauth2`.

The deciding forces are:
- Minimize exposure to upstream container and CI action vulnerabilities.
- Automate routine maintenance without overwhelming maintainer review capacity.
- Provide predictable update schedules and cool-down buffers to maintain stable builds.
- Maintain organizational compliance across all Wazuh SIEM components.

## Decision

We will configure GitHub Dependabot in `.github/dependabot.yml` to track both `docker` and `github-actions`:

1. **Ecosystem Configuration**:
   - `docker`: Scans root `/` directory on a `daily` schedule at `08:00` UTC.
   - `github-actions`: Scans `.github/workflows` on a `weekly` schedule at `08:00` UTC.

2. **Workload and Throttling Limits**:
   - `open-pull-requests-limit: 10`: Restricts active open pull requests per ecosystem to prevent review congestion.
   - `cooldown.default-days: 7`: Implements a 7-day cool-down buffer before opening non-critical update PRs, allowing upstream patches to stabilize.

## Options considered

| Option                                              | Verdict  | Why (one line)                                                                    |
| :-------------------------------------------------- | :------- | :-------------------------------------------------------------------------------- |
| Manual dependency updates (status quo)              | Rejected | Infrequent updates accumulate debt and delay critical security patches.           |
| Renovate bot                                        | Rejected | Requires additional third-party app permissions and configuration overhead.       |
| GitHub Dependabot with org convention               | Adopted  | Native GitHub feature, zero external credentials, matches org-wide Wazuh standard.|

## Consequences

**Not part of this decision:** Automatic merging of dependency PRs. All Dependabot PRs must still pass automated CI checks and receive human review before merging.

### Impact

**Benefits**

- Base image vulnerabilities and outdated actions are remediated continuously.
- Smaller, incremental version bumps reduce blast radius and upgrade complexity.
- Weekly scheduling for GitHub Actions avoids daily workflow noise.
- Cool-down buffers prevent churn from rapid upstream patch releases.

**Costs**

- Maintainers will periodically review and merge Dependabot pull requests.
- CI runner usage increases due to automated checks on Dependabot PR branches.

**Risks**

- Upstream breaking changes in minor or patch releases (mitigated by existing test pipelines and human review requirement).

### Done when

- [x] `.github/dependabot.yml` exists with valid configuration for `docker` and `github-actions`.
- [x] Schedule, PR limits, and cool-down parameters conform to the organizational convention.
- [x] ADR-0001 is documented and registered in `docs/adr/README.md`.

### Revisit when

- Team review capacity requires adjusting `open-pull-requests-limit` or schedule intervals.
- Additional package ecosystems or sub-directories are introduced.

## Rollback

To roll back, remove or revert `.github/dependabot.yml`. Dependabot will cease opening new PRs.

## Evidence

| Claim                                                                 | Where                                                          |
| :-------------------------------------------------------------------- | :------------------------------------------------------------- |
| Organization reference convention                                     | `ADORSYS-GIS/wazuh-cert-oauth2/.github/dependabot.yml`         |
| Sub-issue scope definition                                            | `ADORSYS-GIS/wazuh-snort#37`                                   |
| Organization epic tracking                                            | `ADORSYS-GIS/wazuh#2354`                                       |

## References

- [GitHub Dependabot Configuration Options](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file)
- [ADR template](https://github.com/ADORSYS-GIS/wazuh/blob/main/docs/adr/template.md)
- [ADR writing guide](https://github.com/ADORSYS-GIS/wazuh/blob/main/docs/adr/GUIDE.md)

## Solution implementation

| Kind   | Tracking                                                                                   | Status | What it covers                                 |
| :----- | :----------------------------------------------------------------------------------------- | :----- | :--------------------------------------------- |
| Issue  | [ADORSYS-GIS/wazuh-snort#37](https://github.com/ADORSYS-GIS/wazuh-snort/issues/37)         | Open   | Add dependabot configuration to wazuh-snort    |
| PR     | [ADORSYS-GIS/wazuh-snort#38](https://github.com/ADORSYS-GIS/wazuh-snort/pull/38)           | Open   | Adds .github/dependabot.yml and ADR-0001       |
