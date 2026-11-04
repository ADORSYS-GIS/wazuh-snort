# Building and Packaging Snort 3

This repository automates building and packaging **Snort 3** into `.deb` packages for
the `amd64` and `arm64` architectures using GitHub Actions, so you do not have to
build Snort from source manually.

## How it works

The build logic lives in `scripts/linux/snort3.sh`, which compiles Snort 3 and its
dependencies from source. It builds, in order:

- `libdaq` (`3.0.15`)
- `libdnet` (`1.14`)
- `flex` (`2.6.4`)
- `hwloc` (`2.5.0`)
- `pcre` (`8.45`)
- `zlib` (`1.2.13`)
- **Snort 3** (`3.2.2.0`)

Each component is built and wrapped into a `.deb` package using `checkinstall`
(e.g. `libdaq_<ver>-1_amd64.deb`). The script resolves the correct Go toolchain
(`go1.22.4.linux-amd64.tar.gz` or `go1.22.4.linux-arm64.tar.gz`) based on the
architecture.

## Workflow: `package-snort.yml`

The workflow `.github/workflows/package-snort.yml` ("Build and Package Snort 3"):

1. **Triggers** on a push to `main` or on a pull request against `main`.
2. Runs a `build` job across a matrix of `amd64` and `arm64` (using QEMU + Docker
   Buildx for cross-architecture builds).
3. For each architecture, runs `scripts/linux/snort3.sh` and collects the resulting
   `.deb` files into `/work/packages/<arch>`.
4. Uploads them as workflow artifacts named `snort3-packages-amd64` and
   `snort3-packages-arm64`.
5. A `deploy` job (after `build`) downloads both artifact sets, zips each into
   `snort3-packages-amd64.zip` and `snort3-packages-arm64.zip`, and attaches them to a
   GitHub Release for the triggering tag/ref.

## How to trigger a build

- **Push to `main`** — builds and packages automatically, then publishes the `.deb`
  bundles to a GitHub Release for that ref.
- **Open a pull request against `main`** — builds and packages, producing artifacts
  (available from the workflow run's "Artifacts" section) without publishing a
  release.

## Retrieving the packages

- **From a GitHub Release:** download `snort3-packages-amd64.zip` and/or
  `snort3-packages-arm64.zip` attached to the release.
- **From a workflow run:** open the run's Artifacts and download
  `snort3-packages-<arch>`.

Unzip the archive to get the `.deb` packages, then install with:

```bash
sudo dpkg -i ./path/to/<package>.deb
```

## Related workflow: `snort-build.yml`

A separate workflow, `.github/workflows/snort-build.yml` ("Build Snort3 Docker Multi
Arch"), builds the container image (`Dockerfile`) for `linux/amd64`, `linux/arm64`,
and `linux/arm/v7`, and pushes it to the GitHub Container Registry as `:latest`. This
image is what the Helm chart (and its DaemonSet) uses to run Snort on cluster nodes.

## Related documentation

- [CI/CD overview](ci.md)
- [Kubernetes deployment](../operations/kubernetes.md)
