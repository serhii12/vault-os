#!/usr/bin/env bash
# Filter the current user's GitHub events for a target working day.
#
# Working day: target date 03:00 local TZ through 03:00 local TZ next day,
# capturing late-night activity. Override the local TZ with $TZ.
#
# Env overrides:
#   TZ              — timezone (default: system)
#   WORKDAY_START   — hour 0-23 the working day starts (default: 3)
#   EXCLUDE_REPOS   — comma-separated owner/repo names to skip (e.g. "me/notes,me/scratch")
#
# Output: HH:MM | EventType | repo | action=... | ref=... | pr=... | title=... | commits=[...]

set -uo pipefail

TARGET_DATE="${1:-$(date +%F)}"

TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

if ! gh auth status >/dev/null 2>&1; then
  echo "gh not authenticated — skipping GitHub events" >&2
  exit 0
fi

gh api "/users/$(gh api /user --jq .login)/events" --paginate > "$TMPFILE" 2>/dev/null

python3 - "$TARGET_DATE" "$TMPFILE" <<'PY'
import json, os, sys
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

target = sys.argv[1]
with open(sys.argv[2]) as f:
    data = f.read()

# gh --paginate concatenates multiple JSON arrays; handle that.
events = []
decoder = json.JSONDecoder()
idx = 0
while idx < len(data):
    rest = data[idx:].lstrip()
    if not rest:
        break
    idx = len(data) - len(rest)
    obj, end = decoder.raw_decode(data[idx:])
    events.extend(obj)
    idx += end

tz = ZoneInfo(os.environ.get("TZ") or "UTC")
hour = int(os.environ.get("WORKDAY_START", "3"))
exclude = {r.strip() for r in os.environ.get("EXCLUDE_REPOS", "").split(",") if r.strip()}

start_local = datetime.strptime(target, "%Y-%m-%d").replace(hour=hour, tzinfo=tz)
end_local = start_local + timedelta(days=1)

for e in events:
    t = datetime.fromisoformat(e['created_at'].replace('Z', '+00:00'))
    local = t.astimezone(tz)
    if not (start_local <= local < end_local):
        continue
    repo = e['repo']['name']
    if repo in exclude:
        continue
    payload = e.get('payload', {})
    action = payload.get('action', '')
    ref = payload.get('ref', '')
    pr = payload.get('pull_request', {}) or {}
    pr_num = pr.get('number', '')
    pr_title = pr.get('title', '')
    commits = [c['message'].split('\n')[0] for c in payload.get('commits', [])]
    print(f"{local.strftime('%H:%M')} | {e['type']} | {repo} | action={action} | ref={ref} | pr={pr_num} | title={pr_title} | commits={commits}")
PY
