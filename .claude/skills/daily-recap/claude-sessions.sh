#!/usr/bin/env bash
# Extract Claude Code session activity for a given working day.
#
# Working day window: 03:00 local TZ on target date through 03:00 local TZ
# next day. Late-night sessions belong to the same working day.
#
# Usage: claude-sessions.sh <YYYY-MM-DD> [--prompts|--summary]
#   --summary (default): one line per session with start/end/event-count
#   --prompts: substantive user prompts across sessions, chronological
#
# Project scope:
#   By default, scans Claude project directories whose slug matches the
#   current working directory ($PWD). The slug is the absolute path with
#   slashes replaced by hyphens, e.g. /Users/me/vault → -Users-me-vault.
#   This makes the script portable across users and machines without edits.
#
# Env overrides:
#   PROJECT_SLUG  — pin to a specific project slug (skips $PWD detection)
#   PROJECTS_DIR  — root of Claude project logs (default: ~/.claude/projects)
#   TZ            — timezone for the working-day window (default: system)
#   WORKDAY_START — hour (0-23) where the working day starts (default: 3)
#   EXCLUDE_PROJECTS — comma-separated slugs to skip
#
# Timestamps in jsonl files are UTC. We compute the working-day window in
# UTC by converting from the configured local TZ, then filter accordingly.
# Output timestamps are raw UTC; the caller converts to local for display.

set -uo pipefail

DATE="${1:-}"
MODE="${2:---summary}"

if [ -z "$DATE" ]; then
  echo "usage: $(basename "$0") <YYYY-MM-DD> [--prompts|--summary]" >&2
  exit 1
fi

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/.claude/projects}"
WORKDAY_START="${WORKDAY_START:-3}"
EXCLUDE_PROJECTS="${EXCLUDE_PROJECTS:-}"

# Derive the project slug from $PWD unless one was provided.
if [ -z "${PROJECT_SLUG:-}" ]; then
  PROJECT_SLUG="$(printf '%s' "$PWD" | tr '/' '-')"
fi

# Compute working-day boundaries in UTC. Use python for cross-platform date math.
read -r WD_START_UTC WD_END_UTC <<EOF
$(python3 - <<PY
import os
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo
tz = ZoneInfo(os.environ.get("TZ") or "UTC")
hour = int(os.environ.get("WORKDAY_START", "3"))
target = datetime.strptime("${DATE}", "%Y-%m-%d").replace(tzinfo=tz)
start = target.replace(hour=hour, minute=0, second=0, microsecond=0)
end = start + timedelta(days=1)
print(start.astimezone(ZoneInfo("UTC")).strftime("%Y-%m-%dT%H:%M:%S"),
      end.astimezone(ZoneInfo("UTC")).strftime("%Y-%m-%dT%H:%M:%S"))
PY
)
EOF

NEXT_DATE=$(python3 -c "from datetime import date,timedelta; print((date.fromisoformat('${DATE}')+timedelta(days=1)).isoformat())")

# Helper: extract timestamps in the working-day window from a session file.
filter_timestamps() {
  local f="$1"
  grep -o '"timestamp":"[^"]*"' "$f" 2>/dev/null \
    | sed 's/"timestamp":"//;s/"$//' \
    | grep -E "^(${DATE}|${NEXT_DATE})T" \
    | awk -v start="$WD_START_UTC" -v end="$WD_END_UTC" '$0 >= start && $0 < end'
}

summarize_session() {
  local f="$1" proj="$2"
  local sid; sid=$(basename "$f" .jsonl)
  local timestamps count first_ts last_ts size
  timestamps=$(filter_timestamps "$f")
  count=$(printf '%s' "$timestamps" | grep -c . 2>/dev/null) || true
  [ "${count:-0}" -eq 0 ] && return 0
  first_ts=$(printf '%s\n' "$timestamps" | head -1)
  last_ts=$(printf '%s\n' "$timestamps" | tail -1)
  size=$(du -k "$f" | cut -f1)
  echo "${first_ts}|${last_ts}|${count}|${size}KB|${proj}|${sid}"
}

extract_prompts() {
  local f="$1" proj="$2"
  local sid; sid=$(basename "$f" .jsonl)
  jq -r --arg wd_start "$WD_START_UTC" --arg wd_end "$WD_END_UTC" \
        --arg proj "$proj" --arg sid "$sid" '
    select(.type == "user" and .message.role == "user")
    | select(.timestamp >= $wd_start and .timestamp < $wd_end)
    | (if (.message.content | type) == "string" then .message.content
       elif (.message.content | type) == "array" and (.message.content[0].type // "") == "text" then .message.content[0].text
       else null end) as $text
    | select($text != null)
    | select($text | test("^<(command-name|command-message|prompt|local-command-caveat|bash-input|bash-stdout|bash-stderr|system-reminder)") | not)
    | "\(.timestamp)|\($proj)|\($sid)|\($text | gsub("\n"; " ") | .[0:250])"
  ' "$f" 2>/dev/null || true
}

# Iterate matching project dirs. The default slug is exact-match for $PWD,
# but we also include sibling scratch dirs that start with the same slug
# (e.g. -Users-me-vault-scratch, -Users-me-vault-investigate).
for dir in "$PROJECTS_DIR"/${PROJECT_SLUG}*/; do
  [ -d "$dir" ] || continue
  proj=$(basename "$dir")
  case ",${EXCLUDE_PROJECTS}," in
    *",${proj},"*) continue ;;
  esac
  for f in "$dir"*.jsonl; do
    [ -f "$f" ] || continue
    if [ "$MODE" = "--prompts" ]; then
      grep -qE "\"timestamp\":\"(${DATE}|${NEXT_DATE})T" "$f" 2>/dev/null || continue
      extract_prompts "$f" "$proj"
    else
      summarize_session "$f" "$proj"
    fi
  done
done | sort
