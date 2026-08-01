@AGENTS.md

## Claude Code specifics

- Workspace skills: `brain` (read/write knowledge), `brain-search` (bounded retriever `brain.sh`), `runbook` (docs how-it-works + runbooks).
- Subagents: `brain-librarian` (find a fact, read-only), `brain-curator` (consolidation), `doc-writer` (produce docs/).
- After a `/compact`: replay the bootstrap (worksite `state.md` → area index → targeted notes). Memory lives in the files, not in the conversation.
- Ending a turn with modifications: the Stop hook reminds you to journal — check the post-action protocol + journal entry before closing.
