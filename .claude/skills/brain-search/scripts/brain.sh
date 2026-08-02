#!/usr/bin/env bash
# brain-search — bounded retriever for the workspace brain (never a firehose).
# Output is always bounded by the query/structure, NOT by brain size → scale-safe.
#
# Usage:
#   brain.sh map                 overview: areas → note count → hub (+ subfolders). Default.
#   brain.sh find <term>         RANKED search (title+description+tags+headings+content) → top 20 + snippet
#   brain.sh recent [N]          notes modified in the last N days (default 14), newest first
#   brain.sh gather <term>       AGGREGATES the body of the 5 most relevant notes → ready-to-reason block
#   brain.sh audit               hygiene: note folders without an index.md hub, notes without type:
#   (root override: BRAIN_ROOT env var, otherwise resolved from the script location)
set -uo pipefail

default_root() {
  local here; here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local ws="$here/../../../.."
  [ -d "$ws/brain" ] && { printf '%s' "$(cd "$ws/brain" && pwd)"; return; }
  [ -d "./brain" ] && { printf '%s' "$(cd ./brain && pwd)"; return; }
  printf './brain'
}
ROOT="${BRAIN_ROOT:-$(default_root)}"
[ -d "$ROOT" ] || { echo "Brain not found: $ROOT" >&2; exit 1; }
cd "$ROOT" || exit 1
CMD="${1:-map}"
QUERY="${2:-}"

EXCLUDES=(-not -path './.git/*' -not -path '*/scratch/*')

list_md() { find . -type f -name '*.md' "${EXCLUDES[@]}" -print0 | sort -z; }

fmt_line() { # rel title type status tags -> "- rel — title [type·status]  {tags}"
  local rel="$1" title="$2" type="$3" status="$4" tags="$5" sfx="" line
  [ -n "$type" ] && sfx="$type"
  [ -n "$status" ] && sfx="${sfx:+$sfx·}$status"
  line="- $rel — $title"
  [ -n "$sfx" ] && line="$line [$sfx]"
  [ -n "$tags" ] && line="$line  {$tags}"
  printf '%s' "$line"
}

meta_of() { # $1=file -> "title\037type\037status\037tags"
  awk '
    NR==1 && $0=="---"{fm=1; next}
    fm==1 && $0=="---"{fm=2; next}
    fm==1{
      if($0~/^type:/){t=$0;sub(/^type:[ \t]*/,"",t)}
      else if($0~/^status:/){s=$0;sub(/^status:[ \t]*/,"",s)}
      else if($0~/^tags:/){g=$0;sub(/^tags:[ \t]*/,"",g)}
      next
    }
    title=="" && $0~/^#[ \t]+/{title=$0; sub(/^#[ \t]+/,"",title)}
    fm==2 && title!=""{exit}
    END{ gsub(/[][]/,"",g); sub(/^ /,"",g); sub(/ $/,"",g); print title "\037" t "\037" s "\037" g }
  ' "$1"
}

rank_records() { # uses $1=lowercased query -> sorted "score\037rel\037title\037type\037status\037tags\037snip"
  local q="$1"
  list_md | xargs -0 awk -v q="$q" '
    function flush(){ if(seen && m>0)
      printf "%d\037%s\037%s\037%s\037%s\037%s\037%s\n", m+b, rel, title, type, status, tags, snip }
    FNR==1{
      flush()
      rel=FILENAME; sub(/^\.\//,"",rel)
      fm=0; type=""; status=""; tags=""; title=""; m=0; b=0; snip=""; seen=1
      base=rel; sub(/.*\//,"",base); sub(/\.md$/,"",base)
      if(tolower(base) ~ q) m+=120; else if(tolower(rel) ~ q) m+=25
      if(tolower(base)=="index") b+=10
      if($0=="---"){fm=1; next}
    }
    fm==1 && $0=="---"{fm=2; next}
    fm==1{
      if($0 ~ /^type:/){type=$0; sub(/^type:[ \t]*/,"",type); if(type ~ /index/) b+=20}
      else if($0 ~ /^status:/){status=$0; sub(/^status:[ \t]*/,"",status); if(status ~ /superseded/) b-=30}
      else if($0 ~ /^tags:/){tags=$0; sub(/^tags:[ \t]*/,"",tags); if(tolower(tags) ~ q) m+=55}
      else if($0 ~ /^description:/){d=$0; sub(/^description:[ \t]*/,"",d); if(tolower(d) ~ q){m+=70; if(snip==""){snip=d; gsub(/^["'\''  ]+|["'\''  ]+$/,"",snip)}}}
      next
    }
    title=="" && $0 ~ /^#[ \t]+/{title=$0; sub(/^#[ \t]+/,"",title); if(tolower(title) ~ q) m+=80}
    /^#{1,6}[ \t]/{ if(tolower($0) ~ q) m+=15 }
    { if(tolower($0) ~ q){ m+=3; if(snip==""){snip=$0; gsub(/^[ \t>*-]+/,"",snip)} } }
    END{flush()}
  ' | sort -t$'\037' -k1,1 -rn
}

cmd_map() {
  declare -A acount scount
  while IFS= read -r -d '' f; do
    rel=${f#./}; IFS='/' read -ra seg <<<"$rel"
    if [ "${#seg[@]}" -ge 2 ]; then area="${seg[0]}"; else area="(root)"; fi
    acount["$area"]=$(( ${acount["$area"]:-0}+1 ))
    [ "${#seg[@]}" -ge 3 ] && { sub="${seg[0]}/${seg[1]}"; scount["$sub"]=$(( ${scount["$sub"]:-0}+1 )); }
  done < <(list_md)
  local total=0 k; for k in "${!acount[@]}"; do total=$(( total + acount["$k"] )); done
  printf '# Brain — %d notes, %d areas (root: %s)\n' "$total" "${#acount[@]}" "$ROOT"
  for k in "${!acount[@]}"; do printf '%d\t%s\n' "${acount[$k]}" "$k"; done | sort -rn \
  | while IFS=$'\t' read -r cnt area; do
      hub=""; [ -f "$area/index.md" ] && hub=" · hub: $area/index.md"
      printf '\n## %s/ — %d notes%s\n' "$area" "$cnt" "$hub"
      for s in "${!scount[@]}"; do case "$s" in "$area"/*) printf '%d\t%s\n' "${scount[$s]}" "$s";; esac; done \
      | sort -rn | while IFS=$'\t' read -r scnt sname; do printf '  - %s/ (%d)\n' "${sname#*/}" "$scnt"; done
    done
  printf '\n-> area detail: open its index.md. Search: brain.sh find <term>.\n'
}

cmd_find() {
  [ -n "$QUERY" ] || { echo "usage: brain.sh find <term>" >&2; return 1; }
  local hits; hits=$(rank_records "$(printf '%s' "$QUERY" | tr 'A-Z' 'a-z')")
  local matched; matched=$(printf '%s' "$hits" | grep -c . || true)
  printf '# find "%s" — %s note(s)\n\n' "$QUERY" "${matched:-0}"
  [ -z "$hits" ] && { echo "(no result — try a broader term, or a raw full-text grep)"; return; }
  printf '%s\n' "$hits" | head -20 | awk -F'\037' '{
    role=""; if($4 ~ /index/) role=" *hub*"
    meta=$4; if($5!="") meta=(meta!=""? meta"·"$5 : $5)
    gsub(/[][]/,"",$6); sub(/^ +/,"",$6); sub(/ +$/,"",$6)
    line="- " $2 " — " $3
    if(meta!="") line=line " [" meta "]"
    if($6!="") line=line "  {" $6 "}"
    print line role
    sn=$7; if(length(sn)>110) sn=substr(sn,1,110) "…"; if(sn!="") print "  -> " sn
  }'
  [ "${matched:-0}" -gt 20 ] && printf '\n… (top 20 shown; refine the term if needed)\n'
  return 0
}

cmd_recent() {
  local days="${QUERY:-14}" n=0
  printf '# recent — notes modified (<= %s d), newest first\n\n' "$days"
  while IFS=$'\t' read -r _epoch date rel; do
    [ "$n" -ge 40 ] && { printf '\n… (40 newest shown)\n'; break; }
    rel=${rel#./}
    IFS=$'\037' read -r title type status tags < <(meta_of "$rel")
    [ -z "$title" ] && title="${rel##*/}"
    printf '%s  (%s)\n' "$(fmt_line "$rel" "$title" "$type" "$status" "$tags")" "$date"
    n=$((n+1))
  done < <(find . -type f -name '*.md' "${EXCLUDES[@]}" -mtime -"$days" \
            -printf '%T@\t%TY-%Tm-%Td\t%p\n' 2>/dev/null | sort -rn)
  [ "$n" -eq 0 ] && printf '(no note modified in the period)\n'
  printf '\n— %d note(s) within <= %s d\n' "$n" "$days"
  return 0
}

cmd_gather() {
  [ -n "$QUERY" ] || { echo "usage: brain.sh gather <term>" >&2; return 1; }
  local recs; recs=$(rank_records "$(printf '%s' "$QUERY" | tr 'A-Z' 'a-z')")
  [ -z "$recs" ] && { echo "(no relevant note to aggregate)"; return; }
  printf '# gather "%s" — body of the 5 most relevant notes\n' "$QUERY"
  printf '%s\n' "$recs" | head -5 | awk -F'\037' '{print $2}' | while IFS= read -r rel; do
    [ -f "$rel" ] || continue
    printf '\n---\n## %s\n\n' "$rel"
    awk 'NR==1&&$0=="---"{fm=1;next} fm==1&&$0=="---"{fm=2;next} fm==1{next} {print}' "$rel" | sed '/^$/N;/^\n$/D' | head -60
  done
  printf '\n---\n(body truncated at 60 lines/note; open the note for full detail)\n'
}

cmd_audit() {
  printf '# audit — brain hygiene\n\n'; local n=0
  printf '## Note folders without an index.md hub\n'
  while IFS= read -r -d '' d; do
    d=${d#./}; case "$d" in .git*|*scratch*) continue;; esac
    if compgen -G "$d/*.md" >/dev/null 2>&1; then
      [ -f "$d/index.md" ] && continue
      printf -- '- %s/  (no index.md)\n' "$d"; n=$((n+1))
    fi
  done < <(find . -mindepth 1 -type d -not -path '*/.*' -print0 | sort -z)
  [ "$n" -eq 0 ] && printf 'OK: every note folder has a hub.\n'
  printf '\n## Notes without a frontmatter type:\n'; local m=0
  while IFS= read -r -d '' f; do
    case "$f" in */CLAUDE.md|./CLAUDE.md) continue ;; esac # rules file, not a note
    head -1 "$f" | grep -q '^---$' || { printf -- '- %s (no frontmatter)\n' "${f#./}"; m=$((m+1)); continue; }
    awk 'NR==1&&$0=="---"{fm=1;next} fm==1&&$0=="---"{exit 1} fm==1&&/^type:/{found=1} END{exit found?0:1}' "$f" \
      || { printf -- '- %s (no type:)\n' "${f#./}"; m=$((m+1)); }
  done < <(list_md)
  [ "$m" -eq 0 ] && printf 'OK: every note has a type.\n'
  printf '\n— %d folder(s) without hub · %d note(s) without type\n' "$n" "$m"
  # Strict mode (CI): BRAIN_AUDIT_STRICT=1 → exit 1 if any issue.
  if [ "${BRAIN_AUDIT_STRICT:-0}" = "1" ] && [ $((n + m)) -gt 0 ]; then return 1; fi
  return 0
}

case "$CMD" in
  map)    cmd_map ;;
  find)   cmd_find ;;
  recent) cmd_recent ;;
  gather) cmd_gather ;;
  audit)  cmd_audit ;;
  *) echo "commands: map | find <term> | recent [N] | gather <term> | audit" >&2; exit 2 ;;
esac
