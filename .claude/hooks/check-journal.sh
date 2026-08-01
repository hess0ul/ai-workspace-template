#!/usr/bin/env bash
# Stop hook — post-action protocol reminder.
# If content files (brain/docs/code) are modified but no trace (journal, log.md, state.md)
# has moved, block the stop ONCE with a reminder.
set -uo pipefail

INPUT="$(cat 2>/dev/null || true)"
# Anti-loop: if a Stop hook already blocked this turn, let it pass.
printf '%s' "$INPUT" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

cd "$(dirname "$0")/../.." || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

CHANGED="$(git status --porcelain 2>/dev/null | awk '{print $2}')"
[ -z "$CHANGED" ] && exit 0

CONTENT="$(printf '%s\n' "$CHANGED" | grep -E '^(brain|docs|code)/' | grep -vE '(journal/|log\.md$|state\.md$)' || true)"
[ -z "$CONTENT" ] && exit 0

TRACE="$(printf '%s\n' "$CHANGED" | grep -E '(journal/|log\.md$|state\.md$)' || true)"
[ -n "$TRACE" ] && exit 0

cat <<'EOF'
{"decision": "block", "reason": "Post-action protocol not applied: files under brain/docs/code were modified but neither the journal (brain/journal/<month>.md), nor an area log.md, nor a state.md moved. Before closing: 1 dated line in the touched area's log.md, a journal entry (Done/Files/Keywords/Remaining), and the worksite's state.md if active. If the changes are purely cosmetic, journal one line anyway."}
EOF
exit 0
