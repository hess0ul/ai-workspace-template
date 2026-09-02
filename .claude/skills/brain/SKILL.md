---
name: brain
description: Read and write the workspace brain (durable external memory, single AI-optimized register v2). Use at session start to load context from brain/ (especially after a /compact), to capture any established or changed fact (note + index + log + state), to create a new area, or whenever the user mentions the brain, persistent memory, notes, knowledge, or not losing information. Goal - maximum information for minimum tokens; an AI with zero context must be able to resume from the files alone.
---

# Brain — the workspace's external memory (single register v2)

The brain (`brain/`) is your source of truth: you **read** it to boot, you **write** it so nothing is
lost — even after a `/compact`. One single dense machine-first register; human pedagogy lives in
`docs/` (see the `runbook` skill).

> Golden rule: **an unrecorded change is a lost change.**

Full conventions (naming, register v2, frontmatter, closed vocabulary):
`brain/meta/conventions.md` — single source of truth; re-read it before writing if not in context.

## 🟢 Bootstrap — read / rebuild context

At the start of any topic, and again after a `/compact`. Don't read everything; walk the graph:

1. **Orient**: `bash .claude/skills/brain-search/scripts/brain.sh map` (or `find <term>`).
2. **Ongoing worksite?** → read its `state.md` first (done / remaining / questions).
3. **Area hub**: `brain/<area>/index.md` — the map. Don't proceed without it.
4. **Rules**: `brain/<area>/CLAUDE.md` if present.
5. **Targeted descent**: open only the notes the task touches (one hop from the index). No pre-loading.
6. **Track the working set**: which notes are loaded, which remain to open.

Detail (working set, post-compact recovery): [references/bootstrap.md](references/bootstrap.md).

## 🔵 Capture — write (post-action protocol)

As soon as a fact is established or changes, in the same pass:

1. **Place it**: existing note? new note? new area? (templates: `brain/meta/templates/`)
2. **Write** in register v2: 1 line = 1 fact; verbatim in code fences; `OK:/FAIL:/WARN:/CRIT:/TODO:`; no emojis; frontmatter `type` + `description` + `status`.
3. **Propagate**: folder `index.md` → affected `docs/` pages (how-it-works + runbook; a catch-up too big for now → debt in `state.md`) → area `log.md` (1 dated line) → worksite `state.md`.
4. **Journal**: at session end, entry in `brain/journal/<yyyy-mm>.md` (Done / Files / Keywords / Remaining).
5. **Tests**: survival (would a fresh session recover the fact + its why?), docs parity (a changed fact that a `docs/` page describes → that page updated?). When in doubt: document rather than omit.

Obsolete → `status: superseded` + `superseded_by:`. Never silent deletion.

## Creating a new area

1. `brain/<area>/` + `index.md` (hub, "Note | What | When to open" table).
2. Empty dated `log.md`. `CLAUDE.md` only if the area has its own imperatives.
3. Subfolders get an `index.md` the moment they are born. Row added to `brain/index.md` (master index).
4. `state.md` if the area starts with an active worksite.

## Consolidation (ritual)

Monthly, or when an area `log.md` > ~100 lines: `brain-curator` agent — merge near-duplicates,
supersede, fold the log into notes, repair indexes, `brain.sh audit` + link-check.
Detail: [references/consolidation.md](references/consolidation.md).

## Self-review before closing

- [ ] Every new/changed fact written in its note + index propagated + log line added.
- [ ] `docs/` pages affected by the change updated — or the catch-up recorded as debt.
- [ ] Worksite `state.md` up to date (done / remaining / questions).
- [ ] Journal entry written.
- [ ] Register v2 respected (1 line = 1 fact, verbatim, no emojis).
- [ ] Survival test: a fresh session rebuilds context from the files alone.
