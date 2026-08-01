# AI Workspace Template

> A batteries-included workspace for **AI-assisted production** — a knowledge base your agents can actually navigate, human docs that stay reproducible, and professional git discipline baked in from day one.

**🇫🇷 [Version française](README.fr.md)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-ready-blueviolet)](https://code.claude.com)
[![AGENTS.md](https://img.shields.io/badge/AGENTS.md-compatible-blue)](https://agents.md)
[![gitleaks](https://img.shields.io/badge/secrets-gitleaks%20guarded-green)](https://github.com/gitleaks/gitleaks)

Most "second brain" setups are built for humans and choke AI agents with context; most AI setups are prompt folders with no memory discipline. This template is the middle path, distilled from what actually converges across the ecosystem (Anthropic's context-engineering guidance, Cline Memory Bank, Agent OS, the Karpathy LLM-wiki pattern) and from published benchmarks on token-efficient notation — not vibes.

## The three pillars

```
your-workspace/
├── CLAUDE.md            # thin router (imports AGENTS.md) — the always-loaded map
├── AGENTS.md            # canonical agent guide (Linux Foundation standard)
├── .claude/             # rules (path-scoped), skills, subagents, hooks
├── brain/               # 🧠 KNOWLEDGE — dense, AI-first, machine-readable register
├── docs/                # 📖 HUMAN DOCS — how-it-works + versioned runbooks
└── code/                # 🏭 PRODUCTION — your projects
```

| Pillar | Answers | Register |
|---|---|---|
| `brain/` | *"What is true right now, and why?"* | Telegraphic v2, 1 line = 1 fact |
| `docs/` | *"How do I understand / reproduce this?"* | Pedagogical prose + numbered runbooks |
| `code/` | *"Where does the work live?"* | Whatever the project needs |

One source of truth per fact: state lives in the brain, steps live in runbooks, and they link to each other instead of duplicating.

## What you get

- **A brain agents can walk** — three-tier progressive disclosure (master index → area hub → atomic note), one hop max, kebab-case filenames as search keys. No vector DB: the filesystem *is* the retrieval index.
- **Register v2** — a benchmark-revised telegraphic note format (~40-45% token savings): one line = one fact, absolute verbatim for identifiers/commands in code fences, status markers (`OK:` `FAIL:` `WARN:` `CRIT:`) instead of emojis (which cost *more* tokens), a closed vocabulary so compression never becomes ambiguity.
- **A bounded retriever** (`brain.sh`) — `map`, ranked `find`, `recent`, `gather`, `audit`. Output is capped by construction, so it stays cheap at 100 notes or 10,000.
- **The post-action protocol** — after every change: note → index → area log → worksite `state.md`. Success criterion: *an AI with zero context, given the files, knows exactly where things stand and what to do next.* A Stop hook enforces the habit.
- **Versioned runbooks** — every deployment command captured live into `docs/<app>/runbook/v1/`; a major architecture change opens `v2/` and supersedes (never deletes) the old one.
- **Professional git discipline** — protected `main`, conventional commits, branch + `--no-ff` merge for everything except routine brain appends. Works solo; scales to merge requests the day you add a remote.
- **Security by default** — gitleaks pre-commit hook (blocking, tested), deny-listed secret file reads for agents, vault-pointer convention (`vault kv get ...`) so secrets never enter notes or runbooks.
- **Claude Code native, portable by design** — skills (`brain`, `brain-search`, `runbook`), three subagents (`brain-librarian`, `brain-curator`, `doc-writer`), path-scoped rules; other tools read the same `AGENTS.md`.

## Quick start

```bash
# 1. Get the template
git clone <this-repo> my-workspace && cd my-workspace
rm -rf .git && git init -b main

# 2. Make the hooks yours
git config core.hooksPath .githooks
# install gitleaks: winget install Gitleaks.Gitleaks | brew install gitleaks

# 3. First commit
git add -A && git commit -m "chore: scaffold workspace from ai-workspace-template"

# 4. Open it with your agent (e.g. Claude Code) and say:
#    "Read AGENTS.md and brain/meta/conventions.md, then create my first area: <topic>."
```

First session checklist: create your first area (the `brain` skill scaffolds it), delete `brain/example/` once you've seen the format, start your journal with `brain/journal/<yyyy-mm>.md`.

## How it works

### Progressive disclosure — pay only for what you read

```
brain/index.md          ~1 line per area          } always cheap
  └── <area>/index.md   "path — what — when"      } loaded on entry
        └── note.md     300-1200 tokens, atomic   } loaded on demand
```

An agent answering *"what's the IP of service X?"* reads 3 small files, not your life's work. Files below the entry point cost **zero** until opened — which is why splitting beats compressing.

### The memory loop

```
     ┌──────────── work happens ────────────┐
     ▼                                      │
  capture (note, v2) ──► index ──► log ──► state.md ──► journal
     ▲                                      │
     └──── consolidation ritual (monthly) ◄─┘
```

Semantic memory = notes (edited in place, superseded never deleted). Episodic = append-only logs + journal (grep `brain/journal/` to find *when* something changed). Procedural = `procedures/` + skills. The `brain-curator` agent periodically folds episodic into semantic so the brain doesn't rot.

### Cold-resume guarantee

Everything is designed around one test: open a fresh session with zero context, point it at a worksite, and it must be able to state what was done and what remains — from `state.md`, the journal and the logs alone. If that test fails, the post-action protocol was skipped.

## Conventions at a glance

| Rule | Value |
|---|---|
| File naming | `kebab-case` ASCII, filename = grep key |
| Reserved names | `index.md` (hub) · `log.md` · `state.md` · `CLAUDE.md` |
| Note size | ~300-1200 tokens; hub < 500 lines; TOC if > 100 |
| Links | Relative Markdown, one hop, breadcrumb at the bottom |
| Frontmatter | `type` (required), `description`, `tags`, `status`, `modified` |
| Obsolescence | `status: superseded` + `superseded_by:` — never delete |
| Commits | Conventional (`feat:` `fix:` `docs:` `brain:` `chore:`) |
| Secrets | Vault pointers only; gitleaks blocks the rest |

Full detail: [`brain/meta/conventions.md`](brain/meta/conventions.md) — the single source of truth.

## Multi-device sync (optional)

Designed for **Git + Syncthing coexistence**: version on your forge (GitLab/GitHub), sync the working tree with Syncthing, and keep them from fighting — `.stignore-shared` (versioned) excludes `.git` from sync; each device's `.stignore` is just `#include .stignore-shared`. Commits happen on one machine; other devices consume files or clone from the forge.

## Design sources

The choices here are documented decisions, not habits:

- **Anthropic** — [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), [multi-agent system lessons](https://www.anthropic.com/engineering/multi-agent-research-system), [skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) → thin router + lazy corpus, one-hop references, subagents return paths not payloads.
- **Chroma — [Context Rot](https://www.trychroma.com/research/context-rot)** → duplicates and stale notes are measurable distractors; hence supersede + consolidation ritual.
- **Telegraph English ([arXiv 2605.04426](https://arxiv.org/abs/2605.04426))** → structured telegraphic compression beats deletion-based compression; fine-grained facts are where loss happens → verbatim rule.
- **Tokenizer benchmarks** → emojis cost 1-3 tokens vs 1 for a word → the no-emoji marker set.
- **[AGENTS.md](https://agents.md)** (Linux Foundation), **[Cline Memory Bank](https://docs.cline.bot/best-practices/memory-bank)**, **[Agent OS](https://buildermethods.com/agent-os)**, **Karpathy's LLM-wiki pattern** → the pillar split, the index discipline, the inbox.

## FAQ

**Why not a vector database / RAG?**
At personal-workspace scale, descriptive filenames + ranked grep (`brain.sh find`) retrieve better than embeddings, cost nothing to maintain, and stay fully inspectable. Add semantic search later if you outgrow it.

**Why is the brain so terse? It's hard to read.**
The brain is for agents; *you* read `docs/`. That's the whole point of the split — each audience gets its own register, and no fact is stored twice.

**Does this only work with Claude Code?**
The skills/hooks/subagents are Claude Code native, but the workspace contract lives in `AGENTS.md` (cross-vendor standard) and plain Markdown — Codex CLI, Cursor, Gemini CLI & co read it fine.

**Where do secrets go?**
In your secret manager (HashiCorp Vault, Infisical, …). The repo only ever contains *pointers* (`vault kv get -field=token kv/app/name`). gitleaks blocks accidents at commit time.

## License

[MIT](LICENSE) — take it, adapt it, make it yours.
