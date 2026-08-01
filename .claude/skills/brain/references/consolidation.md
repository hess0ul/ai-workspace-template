# Consolidation — anti-drift ritual

Raw accumulation degrades retrieval (duplicates are measurable distractors; unmarked stale notes are
worse than missing ones). Consolidation is a **scheduled operation**, not a side effect.

## Triggers

- Monthly (default), or
- an area `log.md` > ~100 lines since the last pass, or
- `brain.sh audit` reports folders without hub / notes without type.

## Pass (agent `brain-curator`, branch `brain/<area>-consolidation` if structural)

1. **Duplicates**: `brain.sh find` on hot topics → merge near-duplicates (one canonical note, the other `superseded`).
2. **Stale**: notes contradicted by reality → `status: superseded` + `superseded_by:`, or in-place fix if simple drift.
3. **Episodic → semantic folding**: durable facts from `log.md` and the journal folded into the affected notes; the log keeps the raw history (append-only, never rewritten).
4. **Indexes**: every note referenced by its hub, no orphans, descriptions up to date.
5. **Hygiene**: `brain.sh audit` + link-check → zero errors.
6. **Actual deletion** (rare): only here, deliberately, with an explicit log line.
7. **Journal**: recap entry for the pass.

## Expected output

Short report: merged / superseded / fixed notes, repaired indexes, remaining errors. Return = paths + summary, never full contents.
