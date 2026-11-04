# Building and Packaging Snort 3

This repository automates building and packaging **Snort 3** into `.deb` packages
for the `amd64` and `arm64` architectures using GitHub Actions, so you do not have
to build Snort from source manually.

## How the build actually works

There are two distinct build paths in this repository, and they are easy to
confuse:

### 1. The full dependency build lives in the `Dockerfile`

The complete compilation of Snort 3 **and all of its dependencies** is defined in
the `Dockerfile` (used to build the container image that the Helm chart deploys).
It builds, in order:

- `libdaq` (`3.0.15`)
- `libdnet` (`1.14`)
- `flex` (`2.6.4`)
- `hwloc` (`2.5.0`)
- `LuaJIT` (`2.1.0-beta3`)
- `pcre` (`8.45`)
- `zlib` (`1.2.13`)
- **Snort 3** (`3.2.2.0`)

Each component is compiled from source and installed under `/usr/local`, and the
Snort rules are copied into `/usr/local/etc/snort`.

### 2. `scripts/linux/snort3.sh` is a partial helper

`scripts/linux/snort3.sh` is a **helper script that currently only builds
`libdaq`** and then stops. It does **not** build `libdnet`, `flex`, `hwloc`,
`pcre`, `zlib`, or Snort 3 itself. The script ends with an explicit note:

> `# Remaining build steps omitted for brevity in helper script`

So the full dependency compilation described above lives in the `Dockerfile`, not
in `snort3.sh`.

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
   `snort3-packages-amd64.zip` and `snort3-packages-arm64.zip`, and attaches them to
   a GitHub Release for the triggering tag/ref.

> **Note:** because `snort3.sh` currently only produces the `libdaq` package, the
> `.deb` artifacts from this workflow reflect that partial build. The complete
> Snort 3 build is defined in the `Dockerfile` (used for the container image).

## How to trigger a build

- **Push to `main`** - builds and packages automatically, then publishes the `.deb`
  bundles to a GitHub Release for that ref.
- **Open a pull request against `main`** - builds and packages, producing artifacts
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
