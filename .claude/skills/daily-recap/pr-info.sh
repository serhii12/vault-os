#!/usr/bin/env bash
# Fetch PR title + diff size for enrichment in daily-recap timelines.
# Usage: pr-info.sh <owner/repo> <pr_number> [<owner/repo> <pr_number> ...]
# Output: one line per PR: "owner/repo#<pr> | <title> | +<additions>/-<deletions>"

set -euo pipefail

if [ $# -lt 2 ] || [ $(( $# % 2 )) -ne 0 ]; then
  echo "Usage: $0 <owner/repo> <pr_number> [<owner/repo> <pr_number> ...]" >&2
  exit 1
fi

while [ $# -ge 2 ]; do
  repo="$1"
  pr="$2"
  shift 2
  if out=$(gh pr view "$pr" --repo "$repo" --json title,additions,deletions 2>/dev/null); then
    title=$(echo "$out" | jq -r '.title')
    adds=$(echo "$out" | jq -r '.additions')
    dels=$(echo "$out" | jq -r '.deletions')
    printf "%s#%s | %s | +%s/-%s\n" "$repo" "$pr" "$title" "$adds" "$dels"
  else
    printf "%s#%s | (unavailable)\n" "$repo" "$pr"
  fi
done
