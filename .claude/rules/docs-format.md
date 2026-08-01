---
paths: ["docs/**"]
---

# Docs format (human documentation)

- Per-app layout: `docs/<app>/{index.md, how-it-works/, runbook/}` (+ `troubleshooting/`, `operations/`… as needed).
- **how-it-works/**: clear pedagogical prose (human audience), `overview.md` with a mermaid diagram, one file per component. Define terms, explain the why. Callouts `> [!note]` / `> [!warning]`.
- **runbook/**: exact reproduction. `index.md` (current version + version table + prerequisites), `changelog.md` (1 dated line per evolution), `v1/` with numbered steps `01-<slug>.md`, `02-<slug>.md`… Each step: goal (1 line) → exact command in a fence → expected output. Template: `brain/meta/templates/runbook-step.md`.
- **Versioning**: major architecture change (VM→container, adopting Terraform/Ansible, new reverse proxy…) → new `v<N+1>/`, the old one becomes `status: superseded` (kept). Minor change → edit in place + line in `changelog.md`.
- **Live capture**: during a deployment, every executed command is written immediately into the current step, never reconstructed afterwards.
- **No duplication with brain/**: current state (IPs, versions, config) lives in the service's brain note; docs link to it. Steps live only here.
- **Secrets**: never in clear text — `export TOKEN=$(vault kv get -field=token kv/<path>)`.
- Runbook frontmatter: `type: runbook, app, version, step, last-tested: <date>, status`.
