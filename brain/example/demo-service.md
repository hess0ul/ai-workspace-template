---
type: note
description: "Demo service note — register v2 in action. Open to see the target note format."
tags: [example, service]
status: current
modified: 2026-08-01
ip: 10.0.20.12
container-id: 101
ports: [8000]
access: internal
---

# Demo service

Role: password manager, self-hosted. Version **1.32.1**.
`LXC 101 @ 10.0.20.12:8000` · HTTPS **self-signed** (frontmatter carries the structured fields — the body never repeats them).
OK: reachable from LAN · backups nightly → NAS.
WARN: community-script update FAIL (`cargo not found`, Rust compile) → pinned to current version.
DECIDE: migrate to official Docker image next maintenance window.
Runbook: `docs/demo-service/runbook/` (current: v1).

↑ [example](index.md)
