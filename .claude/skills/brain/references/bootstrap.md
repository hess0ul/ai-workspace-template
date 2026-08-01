# Bootstrap & /compact survival

Why a protocol instead of "read everything": the brain is built for **progressive disclosure** —
a light index routes you, links let you descend on demand. Breadth first (hubs), depth only as needed.

## Protocol (fresh session)

1. **Frame**: which area? If ambiguous, ask rather than guess. Identify what the task actually requires knowing.
2. **Orient**: `brain.sh map` (overview) or `brain.sh find <term>` (direct locate).
3. **`state.md` first** if a worksite is ongoing — it is the handoff surface (done / remaining / questions).
4. **Area hub** `index.md`, then the area **CLAUDE.md** if present (rules before any write).
5. **Targeted descent**: only the notes the task touches. Follow an outgoing link only when necessary.
6. **Working set**: track loaded notes / notes still to open. Minimum viable load: hub + state + 1-3 notes.

## Recovery after /compact

Memory lives in the files, not in the conversation.

1. **Detect**: you no longer hold the precise content of a note you were working with.
2. **Rehydrate**: replay protocol steps 2→5 for the affected area. Cross-check `brain.sh recent` and `brain/journal/` to see what moved.
3. **Resume the working set**: reopen exactly the task's notes. Any decision made must be in a note or an ADR — if it isn't, capture was missed → fix immediately.
4. **Check coherence** before writing: re-read the target note + its hub so you neither duplicate nor contradict.

> Corollary: **capture as you go**, not at the end. A decision kept "in your head" is the only thing a compaction can destroy.

## If the area does not exist yet

No hub to read → area-creation mode (SKILL.md § Creating a new area). Bootstrap **by writing** the skeleton, then feed it through the session.
