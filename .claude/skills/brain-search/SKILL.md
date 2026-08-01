---
name: brain-search
description: Fast search and orientation inside the workspace brain. Use whenever you need to locate a note, find where a piece of information lives, know which areas exist, or dig through memory before answering/writing — instead of fumbling with multiple Glob/Grep calls. Bounded retriever (output never proportional to brain size, hence scale-safe) - map mode (areas → hub), ranked search (title + description + tags + headings + content, top 20 + snippet), aggregation (gather), hygiene audit. Companion of the brain skill (which governs detailed reading/writing).
---

# Brain Search — bounded retriever

One script (`scripts/brain.sh`) whose output is **always a bounded slice** (never the whole brain),
hence **scale-safe**. Recomputed on the fly (always fresh):

```bash
bash .claude/skills/brain-search/scripts/brain.sh map            # orientation
bash .claude/skills/brain-search/scripts/brain.sh find <term>    # ranked search
bash .claude/skills/brain-search/scripts/brain.sh recent [N]     # notes modified in the last N days
bash .claude/skills/brain-search/scripts/brain.sh gather <term>  # aggregates the body of the top 5 notes
bash .claude/skills/brain-search/scripts/brain.sh audit          # hygiene
```

## `map` — orient yourself (constant size)

Areas → note count → `index.md` hub, + subfolders by volume. Run at the start of any broad task to know
which areas exist and where to enter, without opening anything.

## `find <term>` — the core (better than grep)

Merges **title + `description:` + tags + headings + content**, scores, returns the **top 20** with:
path · title · `[type·status]` · `{tags}` · snippet · `*hub*` for indexes.
- `<term>` = case-insensitive regex (e.g. `reverse.proxy`, `vault|secret`).
- The canonical note ranks first (filename/title/description bonus; `superseded` malus), output capped at 20.

## `recent [N]` — what's new

Notes modified in the last N days (default 14), newest first, capped at 40. For "catch me up"
or after a `/compact` (cross-check with `brain/journal/`).

## `gather <term>` — aggregate to reason

Concatenates the body (frontmatter stripped, 60 lines/note max) of the **5 most relevant notes** into
one block. Bounded by construction.

## `audit` — hygiene

Note folders without an `index.md` hub + notes without `type:` in the frontmatter. Run before every
merge touching `brain/` and during consolidation.

## Usage

1. Orient → `map`. Locate → `find`. Then **open** the note(s) with Read.
2. Exotic full-text need not covered → complement with a raw Grep.
3. Default root: the workspace's `brain/` (override: `BRAIN_ROOT` env var).

You **search** with brain-search; you **read/write** per the `brain` skill.
