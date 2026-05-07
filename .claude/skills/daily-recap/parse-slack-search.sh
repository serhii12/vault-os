#!/usr/bin/env bash
# parse-slack-search.sh — extract a compact (Time | Channel | Text) listing
# from a saved Slack MCP search result file (the JSON array form that the MCP
# server writes when its inline output exceeds the token limit).
#
# Usage: parse-slack-search.sh <path-to-saved-json>
# Output: one block per result with Time, Channel, From, and Text (truncated
# to 400 chars). Designed for the daily-recap skill so we don't write inline
# python/awk parsers each run.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <saved-slack-search-json>" >&2
  exit 1
fi

FILE="$1"
if [[ ! -f "$FILE" ]]; then
  echo "file not found: $FILE" >&2
  exit 1
fi

python3 - "$FILE" <<'PY'
import json, re, sys

path = sys.argv[1]
with open(path) as f:
    raw = f.read().strip()

# The MCP wrapper saves the result as a JSON array of {type, text} blocks.
# The inner `text` is itself a JSON string with `results` / `pagination_info`.
data = json.loads(raw)
if isinstance(data, list):
    text_blob = "".join(b.get("text", "") for b in data if isinstance(b, dict))
elif isinstance(data, dict):
    text_blob = data.get("text", "")
else:
    text_blob = str(data)

try:
    inner = json.loads(text_blob)
    results = inner.get("results", "")
    pagination = inner.get("pagination_info", "")
except json.JSONDecodeError:
    results = text_blob
    pagination = ""

blocks = re.split(r'### Result \d+ of \d+', results)
for block in blocks[1:]:
    chan_m = re.search(r'Channel:\s*([^\n]+)', block)
    time_m = re.search(r'Time:\s*([^\n]+)', block)
    from_m = re.search(r'From:\s*([^\n]+)', block)
    text_m = re.search(r'Text:\s*\n([\s\S]*?)(?=\nContext (?:before|after):|\nPermalink:|\n---|\Z)', block)

    time_s = time_m.group(1).strip() if time_m else "?"
    chan_s = chan_m.group(1).strip() if chan_m else "?"
    from_s = from_m.group(1).strip() if from_m else "?"
    text_s = text_m.group(1).strip() if text_m else ""
    if len(text_s) > 400:
        text_s = text_s[:400] + "…"
    text_s = text_s.replace("\n", " ⏎ ")

    print(f"{time_s} | {chan_s}")
    print(f"  from: {from_s}")
    if text_s:
        print(f"  text: {text_s}")
    print()

if pagination:
    print(f"-- {pagination.strip()}")
PY
