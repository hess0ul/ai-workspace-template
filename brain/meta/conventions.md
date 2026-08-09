---
type: index
description: "Single source of truth for brain conventions — naming, register v2, frontmatter, links, post-action protocol. Read before any write inside brain/."
tags: [meta, conventions]
status: current
modified: 2026-08-01
---

# Brain conventions

Single source of truth. Every write inside `brain/` (human or agent) follows this file.
Auto-loaded rules: `.claude/rules/brain-format.md` (operational summary of this file).

## Table of contents

- [Naming](#naming)
- [Area layout](#area-layout)
- [Register v2 (revised caveman)](#register-v2--revised-caveman-2026-benchmarks)
- [Closed vocabulary](#closed-vocabulary)
- [Frontmatter](#frontmatter)
- [Links](#links)
- [Post-action protocol](#post-action-protocol)
- [Global journal](#global-journal)
- [Consolidation](#consolidation)

## Naming

- **kebab-case ASCII everywhere**: `reverse-proxy.md`, never `Reverse Proxy.md`.
- **Filename = search key**: descriptive, greppable (`dns-adguard.md`, never `note2.md`, `misc.md`, `utils.md`).
- **Reserved names**: `index.md` (hub of every folder) · `log.md` (append-only episodic) · `state.md` (active worksite handoff) · `CLAUDE.md` (area rules). `README.md` is banned inside `brain/` (one single hub convention).
- Procedural notes named with a verb (`add-service.md`, `deploy-container.md`); semantic notes as nouns (`gitlab.md`, `ip-plan.md`).

## Area layout

```text
brain/<area>/
├── CLAUDE.md         # hard area imperatives (lazily loaded)
├── index.md          # routing hub ≤150 lines: "path — what — when to open"
├── log.md            # append-only, 1 dated line per change
├── state.md          # if a worksite is active: done / remaining / open questions
├── decisions/        # ADRs: index.md + yyyy-mm-dd-<slug>.md
├── backlog/          # index.md + one note per open topic
├── procedures/       # agent-executable how-tos
└── <domain>/         # index.md + atomic notes
```

- Flat by default; subfolder only when an entity spawns several files.
- **One single hop**: `index.md` → note. Never `index → hub → sub-hub → note` (causes partial reads).
- Atomic note ~300-1200 tokens; hub < 500 lines; TOC at the top if > 100 lines. If a file cannot be read in full, it is two files.
- Typed memory: semantic = notes (edited in place) · episodic = `log.md` (append-only) · procedural = `procedures/`.

## Register v2 — revised caveman (2026 benchmarks)

Refs: Telegraph English (arXiv 2605.04426), Notation Matters (arXiv 2605.29676), Claude tokenizer benchmarks. Realistic saving ~40-45%. Lossless on identifiers/decisions/relations; knowingly lossy on prose nuance.

1. **Telegraphic**: articles, copulas, weak connectors removed. Fragments separated by `.` `·` `;`.
2. **One line = one atomic fact** (hard rule). Every line is independently addressable — that is the free semantic index.
3. **Absolute verbatim** in code fences: commands, paths, IPs/MACs, identifiers, versions, config values, proper nouns. Never paraphrased, never compressed.
4. **No emojis** (they cost 1-3 tokens vs 1 for a word) → `WARN:` `FAIL:` `OK:` `TODO:` `CRIT:`.
5. Allowed symbols: `→` (leads to/so) `=` `!=` `&` `<` `>` `<=` `>=` `@` `~` `x` (times) `w/` `w/o`. **Max 3 consecutive symbols per line.**
6. Enumerations of ≥3 homogeneous items → markdown table. Deep hierarchies (configs, trees) → YAML block.
7. Abbreviations: only those in the [closed vocabulary](#closed-vocabulary). Never an ad-hoc ambiguous abbreviation.
8. Frontmatter carries the structured data (ip, id, status) → the body never repeats it. Bold only on load-bearing values.
9. Test before cutting a word: "does removing it lose information, or only fluidity?" Fluidity → cut. Information → keep.
10. Fatal anti-pattern: the summary. A summary loses information; register v2 says everything, minus the editorial fat.

Example:

> Prose: "Vaultwarden runs in LXC container 101 (10.0.20.12:8000) with self-signed HTTPS. The community-script update fails with cargo not found; the service is not in active use yet, migration from the cloud offering is planned."
>
> v2: `LXC 101 @ 10.0.20.12:8000` · HTTPS **self-signed**. WARN: community-script update FAIL (`cargo not found`, Rust compile) → not in active use. Cloud migration planned → official Docker image.

## Closed vocabulary

Status markers (start of line or fragment):

| Marker | Meaning |
|---|---|
| `OK:` | works / validated |
| `FAIL:` | fails / broken |
| `WARN:` | gotcha, caution |
| `CRIT:` | critical, blocking |
| `TODO:` | to do |
| `WIP:` | in progress |
| `DEPR:` | deprecated / replaced |
| `DECIDE:` | decision made (link ADR if major) |

Allowed abbreviations:

| Abbr. | Meaning | Abbr. | Meaning |
|---|---|---|---|
| cfg | configuration | svc | service |
| env | environment | db | database |
| auth | authentication | net | network |
| fw | firewall | rp | reverse proxy |
| ctn | container | vm | virtual machine |
| repo | git repository | dep | dependency |
| ctx | context | doc | documentation |
| prod | production | dev | development |
| upd | update | param | parameter |

Extending the vocabulary: add the row here (MR if structural), never an undeclared local abbreviation.

## Frontmatter

```yaml
---
type: note | index | decision | procedure | log | state    # required
description: "GitLab CE, LXC 115 — open for config/state"  # discovery string: what + when to open
tags: [homelab, service]
status: current | superseded
superseded_by: services/gitlab-v2.md                       # only if superseded
modified: 2026-08-01
# + domain fields (services: ip, container-id, ports, vlan, subdomain, access)
---
```

- `type` required, the rest as relevant. `description` written in third person: what it is + when to open it.
- **Supersede, never delete**: an obsolete note becomes `status: superseded` + `superseded_by:`; its replacement links back. Actual deletion = explicit decision during consolidation.

## Links

- **Standard relative Markdown links**: `[gitlab](../services/gitlab.md)` — clickable on GitLab/GitHub, script-checkable. No wikilinks.
- Breadcrumb on the last line of every note: `↑ [homelab](../index.md)`.
- One link = one hop. A note referenced from an index must be readable alone (self-contained: restate its subject, never "as seen above").

## Post-action protocol

**"An unrecorded change is a lost change."** After EVERY modification (brain, docs or code), in the same pass:

1. Update the affected **note(s)**.
2. Propagate the touched **`index.md`**.
3. Add **1 dated line** to the area `log.md`: `- 2026-08-01 — <past-tense verb> <what>. Notes: <paths>.`
4. Update the active worksite's **`state.md`**: done / remaining / open questions.
5. During a deployment session: every executed command captured **immediately** in the runbook step (`docs/<app>/runbook/`), never reconstructed afterwards.

Success criterion: an AI with zero context, given the files, knows exactly where things stand and what to do next.

## Global journal

`brain/journal/<yyyy-mm>.md` — append-only, 1 entry per work session:

```markdown
## 2026-08-01 — <short session title>
Done: <telegraphic summary>.
Files: `brain/homelab/services/gitlab.md`, `docs/gitlab/runbook/v1/02-config.md`.
Keywords: gitlab, container, runner.
Remaining: TODO: <next step>.
```

Greppable ("when/where did we touch X"). `journal/index.md` lists the months.

## Consolidation

Monthly ritual, or when an area `log.md` grows past ~100 lines since the last pass (agent `brain-curator`):

1. Merge near-duplicates; mark `superseded` what must be.
2. Fold durable facts from `log.md`/journal into semantic notes.
3. Repair indexes (every note referenced, no orphans).
4. `brain.sh audit` + link-check → zero errors.
5. Recap journal entry.

↑ [meta](index.md) · [brain](../index.md)
