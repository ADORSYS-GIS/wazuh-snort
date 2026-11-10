# ADR-0002: Enable Secret Scanning and Gitleaks in CI

> We enable GitHub native Secret scanning and Push protection on this public repository and add a Gitleaks job that scans the full git history to CI through the shared adorsys-ci-cd-templates workflow.

## Metadata

| Field             | Value                               |
| :---------------- | :---------------------------------- |
| **Document ID**   | ADR-0002                            |
| **Status**        | `Accepted`                          |
| **Date**          | 2026-11-10                          |
| **Deciders**      | Wazuh maintainers                   |
| **Governs**       | `.github/workflows/secret-scan.yml` |
| **Amends**        | N/A                                 |
| **Amended by**    | N/A                                 |
| **Supersedes**    | N/A                                 |
| **Superseded by** | N/A                                 |

## Context

The `wazuh-snort` repository is public and maintains Snort NIDS rules, integration scripts, and container assets for network intrusion detection within the Wazuh ecosystem. Any credential committed to it is exposed to the internet immediately. Audit requirement SSDLC-DEV-04 requires secrets scanning on repositories and pipelines, and GAP-WZ-SEC-02 (a plaintext cluster key committed in another Wazuh repository) shows the consequence of scanning being off.

The repository has no dedicated SAST workflow, so the Gitleaks scan is added as its own `secret-scan` workflow rather than extending the path-filtered `ci.yml`, so it runs on every push and pull request to the default branch.

The deciding forces are:

- Block secrets before they reach Git using GitHub native tooling, which is free on public repositories.
- Scan the full commit history, not only the diff of a push or pull request, so secrets that were committed and later removed are still detected.
- Run the scan on every push and pull request, independent of the path-filtered CI workflow.
- Reuse the shared secret scanning workflow instead of maintaining a repository-local copy.

## Decision

1. Enable GitHub Secret scanning and Push protection in the repository security settings, free on public repositories.
2. Add a `.github/workflows/secret-scan.yml` workflow that calls the shared `adorsys-ci-cd-templates/.github/workflows/secret-scan.yml` workflow, pinned to a commit SHA, scanning the full git history (`--log-opts=--all`) on push and pull request to `main`.
3. Pass `NOTIFY_WEBHOOK_URL` to route findings to the alerting channel. Results always remain available in the `gitleaks-report` SARIF artifact and the Gitleaks step log.

## Options considered

| Option                                                             | Verdict  | Why (one line)                                                           |
| :----------------------------------------------------------------- | :------- | :----------------------------------------------------------------------- |
| GitHub native Secret scanning and Push protection only, no CI scan | Rejected | Misses secrets already in history and non-provider patterns.             |
| Add the scan as a job in the path-filtered `ci.yml`                | Rejected | The scan would not run on changes outside the filtered paths.            |
| Repository-local Gitleaks workflow                                 | Rejected | Duplicates the shared workflow and drifts from other Wazuh repositories. |
| Dedicated shared-Gitleaks workflow (adopted)                       | Adopted  | Scans every push and pull request, consistent across Wazuh repositories. |

## Consequences

**Not part of this decision:** Secret scanning on private repositories (requires GitHub Advanced Security), rewriting history for historical findings, and local pre-commit hooks (this repository has no pre-commit setup). Existing findings are triaged separately.

### Impact

**Benefits**

- Credentials are blocked at push time by native Push protection.
- Full history is scanned on every push and pull request, so removed secrets are still found.
- The scan is not gated by the path filters of the existing CI workflow.
- Scanning is consistent across Wazuh repositories through the shared workflow.

**Costs**

- A historical finding fails the scan on the protected `main` branch until it is triaged or the history is cleaned.

### Done when

- [ ] Secret scanning and Push protection enabled in the repository security settings (requires repository admin).
- [x] `secret-scan` workflow present in `.github/workflows/secret-scan.yml`, pinned to a commit SHA of the shared workflow.
- [x] ADR-0002 is documented and indexed in `docs/adr/README.md`.

### Revisit when

- The shared `secret-scan.yml` workflow changes.
- The organization gains GitHub Advanced Security, enabling native scanning on private repositories.

## Rollback

Disable Secret scanning and Push protection in the repository security settings and remove `.github/workflows/secret-scan.yml`.

## Evidence

| Claim                                                       | Where                                                                           |
| :---------------------------------------------------------- | :------------------------------------------------------------------------------ |
| Shared secret scanning workflow                             | `ADORSYS-GIS/adorsys-ci-cd-templates/.github/workflows/secret-scan.yml`         |
| Audit requirement and risk reference                        | Epic [ADORSYS-GIS/wazuh#2376](https://github.com/ADORSYS-GIS/wazuh/issues/2376) |
| The workflow calls the shared scan on push and pull request | `.github/workflows/secret-scan.yml` in this repo                                |

## References

- [GitHub Secret scanning documentation](https://docs.github.com/en/code-security/secret-scanning)
- [adorsys-ci-cd-templates](https://github.com/ADORSYS-GIS/adorsys-ci-cd-templates)
- [ADR template](https://github.com/ADORSYS-GIS/wazuh/blob/main/docs/adr/template.md)
- [ADR writing guide](https://github.com/ADORSYS-GIS/wazuh/blob/main/docs/adr/GUIDE.md)

## Solution implementation

| Kind  | Tracking                                                                                                 | Status            | What it covers                                   |
| :---- | :------------------------------------------------------------------------------------------------------- | :---------------- | :----------------------------------------------- |
| Epic  | [ADORSYS-GIS/wazuh#2376](https://github.com/ADORSYS-GIS/wazuh/issues/2376)                               | Open              | Enable secret scanning across Wazuh repositories |
| Issue | [ADORSYS-GIS/wazuh-snort#39](https://github.com/ADORSYS-GIS/wazuh-snort/issues/39)                       | Open              | Child issue for this decision                    |
| PR    | [ADORSYS-GIS/adorsys-ci-cd-templates#76](https://github.com/ADORSYS-GIS/adorsys-ci-cd-templates/pull/76) | Merged 2026-11-09 | Adds the shared `secret-scan.yml` workflow       |
| PR    | [ADORSYS-GIS/wazuh-snort#52](https://github.com/ADORSYS-GIS/wazuh-snort/pull/52)                         | Open              | Adds the `secret-scan` workflow and ADR-0002     |
