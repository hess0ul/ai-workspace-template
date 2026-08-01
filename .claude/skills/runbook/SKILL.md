---
name: runbook
description: Write and maintain the human documentation in docs/ — how-it-works (pedagogy, diagrams) and versioned runbooks (numbered commands reproducible to the letter). Use during any deployment, installation or service migration, when the user asks to document an app, or when a command was just executed successfully and must be captured. Every executed command is written immediately into the runbook step — never reconstructed afterwards.
---

# Runbook — human documentation (docs/)

`docs/` serves two human needs: **understanding** (`how-it-works/`) and **exact reproduction**
(`runbook/`). Current state (IPs, versions, config) lives in `brain/` — docs links to it, no duplication.

## Per-app layout

```
docs/<app>/
├── index.md            # what the app is + section links
├── how-it-works/
│   ├── index.md
│   ├── overview.md     # role, architecture, mermaid diagram
│   └── <component>.md  # one file per component
└── runbook/
    ├── index.md        # current version + version table + prerequisites
    ├── changelog.md    # 1 dated line per evolution
    └── v1/             # 01-<slug>.md, 02-<slug>.md…
```

New app → create the skeleton + row in `docs/index.md`.

## How-it-works — writing rules

- Audience: a human discovering the system. Clear prose, defined terms, the **why** before the how.
- `overview.md`: role of the service, place in the infrastructure, mermaid diagram of the flow.
- One component = one file. Callouts `> [!note]` / `> [!warning]` for gotchas.

## Runbook — writing rules

- One step = one file `NN-<slug>.md` (template: `brain/meta/templates/runbook-step.md`).
- Each block: **goal (1 line) → exact command (fence) → expected output (fence)**. A human must be able to replay without thinking.
- **Live capture**: during a deployment, every successfully executed command is written immediately into the current step. A command that failed then got fixed → only the good version stays; a notable failure becomes a `> [!warning]`.
- **Secrets**: never in clear text — `export X=$(vault kv get -field=<field> kv/<path>)`.
- Frontmatter: `type: runbook, app, version, step, last-tested: <date>, status`.

## Versioning

- **Major** (architecture change: VM→container, adopting Terraform/Ansible, another reverse proxy…) → create `v<N+1>/`; the old version stays (`status: superseded` on its files, cross-links in both indexes).
- **Minor** (fixed command, added step) → edit in place + 1 line in `changelog.md`.
- `runbook/index.md` declares the **current version** + version table (version | period | reason for the change).
- The service's brain note points at the current version: `Runbook: docs/<app>/runbook/ (current: v<N>)`.

## After any docs write

Usual post-action protocol: `docs/index.md` propagated if new app, service brain note updated
(pointer, state), area log line, journal entry at session end.
