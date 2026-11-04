# CI/CD Overview

This repository uses GitHub Actions for continuous integration, packaging, and
release. The workflows live in `.github/workflows/`.

## Workflows

### `ci.yml` - CI (tests, changelog, releases)

The main CI workflow. It **triggers** on:

- pushes to `main` or to tags matching `v*`,
- pull requests against `main`,
- restricted to changes in `scripts/**`, `.github/**`, `Dockerfile`, or `rules/**`.

It defines three jobs:

1. **`update-changelog-and-checksums`** - regenerates `checksums.sha256` from every
   file under `scripts/` and regenerates `CHANGELOG.md` with
   [git-cliff](https://github.com/orhun/git-cliff) (`cliff.toml`), then commits both
   with `[skip ci]`.
2. **`test`** - runs on a matrix of `ubuntu-latest` and `macos-latest`. It installs
   the Wazuh agent (from the `adorsys-gis/wazuh-agent` repo) and runs the platform
   Snort install script (`scripts/linux/install.sh` or `scripts/macos/install.sh`).
   The pytest suite in `scripts/tests/test.py` is executed **only on Ubuntu**
   (the test step is gated by `if: matrix.os == 'ubuntu-latest'`); the macOS job
   installs Snort but skips the pytest run.
3. **`release`** - runs only for tags matching `v*`. Uses git-cliff to generate
   release notes, determines whether the tag is a prerelease (`*rc*`), and creates a
   GitHub Release (with the generated notes) attaching `checksums.sha256`.

### `package-snort.yml` - Build and Package Snort 3

Builds Snort 3 `.deb` packages for `amd64` and `arm64` and publishes them as GitHub
Release assets. See [Building and packaging Snort 3](build-and-package.md).

### `snort-build.yml` - Build Snort3 Docker Multi Arch

Builds and pushes the Snort container image (`Dockerfile`) for `linux/amd64`,
`linux/arm64`, and `linux/arm/v7` to GitHub Container Registry (`ghcr.io`) tagged
`latest`. It triggers on pull requests against `main` that modify the `Dockerfile`.

### `helm-publish.yml` - Helm Chart Publish

Lints the Helm chart and, on pushes to the `develop` branch, packages and publishes
the `snort-ips` chart to a ChartMuseum repository configured via repository secrets
(`HELM_URL`, `HELM_USER`, `HELM_PASS`). It checks whether the chart version already
exists in the repository before publishing to avoid duplicates.

> **Note:** this workflow's path filter is `charts/**/Chart.yaml`, but the chart in
> this repository lives at `helm/Chart.yaml` (not `charts/**`). Because of this
> mismatch, changes to the Helm chart will **not** trigger the workflow. The filter
> should be updated to `helm/**/Chart.yaml` (or `helm/Chart.yaml`).

## Test suite

The Linux/macOS tests in `scripts/tests/test.py` use
[pytest](https://docs.pytest.org) with
[Testinfra](https://testinfra.readthedocs.io) and assert that Snort is installed, the
config file exists, and the default interface is present in the Debian config. See
[`scripts/tests/README.md`](../../scripts/tests/README.md) for the full description.

## Related documentation

- [Building and packaging Snort 3](build-and-package.md)
- [Architecture overview](../architecture/overview.md)
