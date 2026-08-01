# AI Workspace — agent guide

Personal AI-assisted production workspace. Three pillars:

| Pillar | Role | Entry point |
|---|---|---|
| `brain/` | Knowledge, dense AI-first register (v2) | `brain/index.md` |
| `docs/` | Human documentation: how-it-works + versioned runbooks | `docs/index.md` |
| `code/` | Production projects | `code/index.md` |

Meta: brain conventions live in `brain/meta/conventions.md` (single source of truth). Per-pillar rules in `.claude/rules/`.

## Hard rules (all pillars)

1. **Post-action protocol** — after every change: update the note(s) → propagate the touched `index.md` → add 1 dated line to the area `log.md` → update the active worksite's `state.md` (done / remaining / open questions). An AI with zero context must be able to resume from the files alone.
2. **Journal** — every work session = 1 entry in `brain/journal/<yyyy-mm>.md` (Done / Files / Keywords / Remaining).
3. **Naming** — kebab-case ASCII everywhere, no accents. Reserved names: `index.md` (hub), `log.md`, `state.md`, `CLAUDE.md`. `README.md` is banned inside `brain/`.
4. **Links** — standard relative Markdown links, one single hop index → note, breadcrumb on the last line. No wikilinks.
5. **Supersede, never delete** — obsolete = `status: superseded` + `superseded_by:`.
6. **Brain register** — v2 telegraphic (see conventions): 1 line = 1 fact, verbatim in code fences, `OK:/FAIL:/WARN:/CRIT:/TODO:` markers, no emojis.
7. **Brain vs docs** — brain = what is true now; docs = how to reproduce/understand. Runbook steps live ONLY in `docs/<app>/runbook/`; during a deployment, every command is captured there immediately.
8. **Professional git** — never commit directly to `main`, except routine `brain/` writes (appending notes/log/journal/state; conventional commit `brain(<area>): ...`). Everything else: branch (`feat/ fix/ docs/ brain/ chore/`) + `--no-ff` merge (merge request once a remote exists). Structural brain changes = branch too.
9. **Security** — no secret ever enters the repo (.env, keys, tokens, passwords), not in notes, not in runbooks. Secrets = vault pointers (e.g. `vault kv get -field=x kv/...`). See `.claude/rules/security.md`.

## Starting a task

1. Knowledge task → `bash .claude/skills/brain-search/scripts/brain.sh map` then `find <term>`; open the area `index.md`, then only the notes you need. Ongoing worksite → read its `state.md` first.
2. Writing to brain → re-read `brain/meta/conventions.md` if not already in context.
3. Subagents: artifacts written to disk, return = path + summary ≤1-2k tokens; one writer per file.
