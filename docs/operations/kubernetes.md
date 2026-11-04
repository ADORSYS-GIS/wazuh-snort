# Deploying Snort on Kubernetes (Helm chart)

The Helm chart in `helm/` deploys Snort as a **DaemonSet**, running a Snort
container on **every node** of a Kubernetes cluster so the whole cluster's network
traffic is monitored.

## Prerequisites

- A Kubernetes cluster (any CNCF-conformant distribution).
- `kubectl` configured to talk to the cluster.
- [Helm](https://helm.sh) v3 installed.
- The Snort container image available to the cluster. The chart defaults to
  `ghcr.io/adorsys-gis/wazuh-snort:latest`; if the image is private, provide an
  `imagePullSecret`.
- A default StorageClass (or set `persistence.storageClassName`) so the
  `ReadWriteMany` PersistentVolumeClaim can bind.
- The node network interface used by Snort. The DaemonSet mounts the host's
  `/sys/class/net` and captures on `eth0` by default.

## Install

From the repository root, install the chart:

```bash
helm install snort-ips ./helm
```

The release name (`snort-ips`) is arbitrary; the chart `name` is `snort-ips` and the
chart version is `0.1.1`.

Check the DaemonSet:

```bash
kubectl get daemonsets
kubectl get pods -o wide
```

Because it is a DaemonSet, one Pod runs per node:

```bash
kubectl get pods -l app.kubernetes.io/name=snort-ips
```

## How it monitors cluster nodes

The chart renders these resources (see `helm/templates/`):

- **DaemonSet** (`daemonset.yaml`) — runs one Snort container per node. The main
  container runs:

  ```sh
  snort -c /usr/local/etc/snort/custom-fast-path.lua \
        -R /usr/local/etc/snort/snort3.rules \
        -l /var/log/snort/$NODE_NAME \
        -i eth0
  ```

  - `NODE_NAME` is injected from `spec.nodeName`, so each Pod writes its alerts into a
    per-node subdirectory of the shared volume.
  - An **init container** (`busybox`) creates `/var/log/snort/$NODE_NAME` and sets
    ownership for each node before Snort starts.
  - The container is granted the `NET_ADMIN` capability (via
    `values.securityContext.capabilities`) so it can manage packet capture.
  - The host's `/sys/class/net` is mounted read-only at `/host-interfaces` so Snort
    can discover node interfaces.

- **ConfigMap** (`snortconfig.yaml`) — supplies `custom-fast-path.lua`, a minimal
  Snort 3 Lua config that loads the defaults and enables **JSON alert output**
  (`alert_json`) to `/var/log/snort/$NODE_NAME`. This keeps a per-node alert stream
  on the shared volume.

- **PersistentVolumeClaim** (`pvc.yaml`) — a `ReadWriteMany` volume (default `1Gi`)
  mounted at `/var/log/snort` to store alerts from every node. Set
  `values.externalPvcName` to use an existing PVC instead of creating one.

- **ServiceAccount** (`serviceaccount.yaml`) — created when
  `values.serviceAccount.create` is `true` (the default).

## Configuration values

Key `helm/values.yaml` settings:

| Value | Default | Description |
| :---- | :------ | :---------- |
| `image.repository` | `ghcr.io/adorsys-gis/wazuh-snort` | Snort container image |
| `image.tag` | `latest` | Image tag |
| `imagePullSecrets` | `[]` | Pull secrets for a private registry |
| `replicaCount` | `1` | (informational; a DaemonSet ignores this) |
| `persistence.enabled` | `true` | Create the PVC |
| `persistence.size` | `1Gi` | PVC requested size |
| `persistence.storageClassName` | (empty) | StorageClass for the PVC |
| `externalPvcName` | `""` | Use an existing PVC instead of creating one |
| `securityContext.capabilities` | `[NET_ADMIN]` | Container capabilities |
| `nodeSelector` / `affinity` / `tolerations` | `{}` / `{}` / `[]` | Scheduling constraints |
| `resources` | `{}` | CPU/memory requests and limits |
| `volumes` / `volumeMounts` | `[]` | Additional volumes/mounts |

For example, to use a custom StorageClass and resource limits:

```bash
helm install snort-ips ./helm \
  --set persistence.storageClassName=my-fast-sc \
  --set resources.requests.memory=256Mi \
  --set resources.limits.memory=512Mi
```

## Integrating with Wazuh

The per-node alert JSON files on the shared PVC can be collected by a Wazuh agent
running on the cluster (for example a Wazuh agent DaemonSet) by adding a `<localfile>`
entry per node, or by mounting the same volume into the agent and pointing
`log_format snort-full` at the per-node files. The JSON output uses Snort 3 fields
(`timestamp`, `src_addr`, `dst_addr`, `proto`, `action`, `msg`, `priority`,
`class`, `sid`), which map naturally onto Wazuh's `snort-full` decoder.

## Related documentation

- [Architecture overview](../architecture/overview.md)
- [Installation & Setup](installation.md)
