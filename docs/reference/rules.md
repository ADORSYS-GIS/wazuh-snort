# Rules Reference

This repository ships Snort rules in `rules/`. The same rule set is used by the
install scripts (macOS downloads it as `snort3-community.rules`) and by the Helm
chart / Docker image.

## Files

| File | Contents |
| :--- | :------- |
| `rules/snort3.rules` | The Snort rule file (a Snort 3 / `sid-msg` style rule set of community rules). |
| `rules/sid-msg.map` | A mapping of Snort SIDs to human-readable messages and references. |

## `rules/snort3.rules`

A collection of signature rules used to detect known malicious traffic. Each rule
follows the standard Snort rule syntax:

```
alert tcp $HOME_NET any -> $EXTERNAL_NET any \
  (msg:"MALWARE-CNC Win.Trojan.Danabot outbound connection"; ...; sid:46967; rev:1;)
```

Typical rule elements include:

- **Action** — `alert` (detection-oriented; this repo's rules are primarily `alert`
  rules, so the default posture is NIDS).
- **Protocol** — `tcp`, `udp`, `icmp`, `ip`.
- **Source / destination** — addresses and ports, often using the `$HOME_NET` and
  `$EXTERNAL_NET` variables.
- **Options** — `msg`, `content`, `flow`, `pcre`, `reference`, `metadata`
  (including `metadata:policy ... ips/alert` hints), `classtype`, `sid`, and `rev`.

Rules cover a broad range of threat categories, including:

- Malware command-and-control (CNC) beacons and connections
- Backdoors, trojans, and downloaders
- Web application and server exploits (e.g. Apache Log4j RCE, Exchange, Confluence)
- Operating-system exploits and SCADA/ICS protocol abuse
- Policy and indicator-of-compromise (IOC) detections

## `rules/sid-msg.map`

A companion file that maps each rule `sid` to a short description and reference
links, e.g.:

```
46967 || MALWARE-CNC Win.Trojan.Danabot outbound connection || url,www.virustotal.com/...
```

The `sid-msg.map` format is:

```
<sid> || <message> || <reference[,reference...]>
```

This is useful for correlating alert SIDs to friendly descriptions and for tooling
that consumes Snort signature metadata.

## Configuration and usage

### Standalone endpoints

- **Linux:** the install script downloads the Snort **community rules** from
  snort.org and appends `include $RULE_PATH/community.rules` to
  `/etc/snort/snort.conf`. The repo's `snort3.rules` is primarily consumed by the
  Snort 3 deployments (macOS / container).
- **macOS:** the install script downloads `rules/snort3.rules` to
  `/usr/local/etc/rules/snort3-community.rules` and runs Snort with
  `-R snort3-community.rules`.

### Kubernetes / container

The Helm chart and Docker image run Snort with the rules file mounted at
`/usr/local/etc/snort/snort3.rules`:

```sh
snort -c /usr/local/etc/snort/custom-fast-path.lua -R /usr/local/etc/snort/snort3.rules -l /var/log/snort/$NODE_NAME -i eth0
```

### Customizing rules

To add your own signatures, append rules to the local rules file used by your
deployment (e.g. `/etc/snort/rules/local.rules` on Linux,
`/usr/local/etc/rules/local.rules` on macOS, or the `local.rules` shipped under
`scripts/windows/` for Windows). Remember that rules in this repo are `alert`
rules by default — change the action to `drop`/`reject` only if you have configured
Snort inline (NIPS mode).

## Related documentation

- [Architecture overview](../architecture/overview.md)
- [Installation & Setup](../operations/installation.md)
