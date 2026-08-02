#!/usr/bin/env bash
# link-check — verifies that every RELATIVE Markdown link points to an existing file.
# Ignores: URLs (http/https/mailto), absolute paths, pure anchors (#...), inline code,
# fenced blocks, and template placeholders (<entity>.md).
# Output: list of broken links, exit 1 if any.
set -uo pipefail

fail=0
while IFS= read -r -d '' f; do
  dir=$(dirname "$f")
  links=$(awk 'BEGIN{fence=0} /^(```|~~~)/{fence=!fence; next} !fence{print}' "$f" \
    | sed -E 's/`[^`]*`//g' \
    | grep -oE '\]\([^)#][^)]*\)' \
    | sed -E 's/^\]\(//; s/\)$//; s/#.*$//') || true
  while IFS= read -r l; do
    [ -z "$l" ] && continue
    case "$l" in http://*|https://*|mailto:*|/*) continue ;; esac
    case "$l" in *"<"*|*">"*) continue ;; esac # template placeholders (<entity>.md)
    if [ ! -e "$dir/$l" ]; then
      echo "BROKEN: $f -> $l"
      fail=1
    fi
  done <<< "$links"
done < <({ find brain docs .claude -type f -name '*.md' -print0 2>/dev/null; printf '%s\0' CLAUDE.md AGENTS.md code/index.md; })

[ "$fail" -eq 0 ] && echo "OK: no broken relative link."
exit "$fail"
