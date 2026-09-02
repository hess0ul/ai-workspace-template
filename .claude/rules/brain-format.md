---
paths: ["brain/**"]
---

# Brain format (operational summary — full detail: brain/meta/conventions.md)

- Register v2: telegraphic, **1 line = 1 atomic fact**, verbatim in code fences (commands, IPs, versions, identifiers — never paraphrased), markers `OK: FAIL: WARN: CRIT: TODO: WIP: DEPR: DECIDE:`, **no emojis**, max 3 consecutive symbols/line, closed-vocabulary abbreviations only.
- Note ~300-1200 tokens, self-contained (restates its subject). Hub < 500 lines, TOC if > 100. A file unreadable in full = two files.
- Frontmatter: `type` required + `description` (what + when to open) + `status: current|superseded`. Domain fields in frontmatter, not in the body.
- Relative Markdown links, max one hop from an index, breadcrumb `↑ [parent](index.md)` on the last line.
- `index.md` = hub of every folder (never `README.md`). Table "Note | What | When to open".
- Every write triggers the post-action protocol: note → index → affected `docs/` pages → area `log.md` (1 dated line) → `state.md` if a worksite is active.
- Deep hierarchies → YAML block; enumerations of ≥3 items → markdown table.
- Obsolete → `status: superseded` + `superseded_by:`. Never silent deletion.
