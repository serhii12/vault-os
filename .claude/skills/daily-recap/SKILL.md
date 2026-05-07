---
name: daily-recap
description: Reconstruct a chronological timeline of a working day from external activity — Slack, GitHub, calendar, meeting notes (Granola), and Claude Code sessions. Produces a markdown file with stand-up block, timeline, and stats. Use when the user says "recap", "/daily-recap", "what did I do today", "yesterday recap", or asks for a retrospective of a day's work.
argument-hint: "[YYYY-MM-DD] (defaults to today)"
---

# Daily Recap — Retrospective Timeline

Reconstructs **what happened** during a working day from external sources. Pairs with `close-day` (which processes the user's own daily-note writing).

## Date

Use the argument if provided, otherwise today.

```bash
TARGET_DATE="${ARG:-$(date +%F)}"
DAY_NAME=$(date -d "$TARGET_DATE" +%A)   # macOS: date -j -f "%Y-%m-%d" "$TARGET_DATE" +%A
```

Never guess the day-of-week — always compute it.

## Conventions

- **Vault root**: operate from CWD. The skill auto-detects the Claude project directory matching the current path.
- **Output**: `_agent/outputs/recaps/<YYYY-MM-DD> - <DayOfWeek> - Recap.md`. The directory `_agent/outputs/` exists; create `recaps/` on first run.
- **Timezone**: defaults to the user's local TZ from the shell. Override with `TZ` env var. The "working day" boundary defaults to 03:00 local time on the target date through 03:00 local time the next day, capturing late-night sessions.

## Prerequisites

Required:

- **Google Calendar** MCP — for events.
- **`gh` CLI** authenticated — for GitHub events / PR enrichment. Skip GitHub steps if `gh auth status` fails.

Optional (skill degrades gracefully if absent):

- **Slack** MCP — at session start, scan available tools for `mcp__*[Ss]lack*` (e.g., `search_messages`, `read_channel`). If none, skip Slack steps and note in output.
- **Granola** MCP (`mcp__*Granola*`) — for meeting notes / actual durations.
- **Claude Code session logs** at `~/.claude/projects/<slugified-vault-path>/*.jsonl` — used for "what was worked on" attribution.

## Step 1 — Gather data (parallel)

Run these concurrently:

1. **Slack messages from me** — search `from:me on:<date>`, sorted ascending, paginate. Also search `from:me on:<next-date>` and keep only messages before 03:00 local time.
2. **Slack messages to me** — search `to:me on:<date>` (same logic).
3. **Calendar events** — list events for `<date>` in the local TZ.
4. **GitHub activity** — `.claude/skills/daily-recap/github-events.sh <date>`. The script honors `TZ`, `EXCLUDE_REPOS` (comma-separated), and `WORKDAY_START_HOUR` env vars. Output:
   ```
   HH:MM | EventType | repo | action=... | ref=... | pr=... | title=... | commits=[...]
   ```
5. **Granola meetings** — `mcp__*Granola*list_meetings` for the target date. Use Granola times when both calendar and Granola exist (Granola has actual durations).
6. **Claude Code sessions** — `.claude/skills/daily-recap/claude-sessions.sh <date>` for session summaries; add `--prompts` for substantive user prompts. The script auto-derives the project scope from `$PWD`.

### Slack timestamp accuracy

Slack search results return opaque message IDs, not real timestamps. To get accurate times:

1. Collect the unique channel/DM IDs that had activity from the search results.
2. For each active channel, use `slack_read_channel` (or equivalent) with `oldest`/`latest` set to the target date's Unix-timestamp range.
3. Use those timestamps as the source of truth.

## Step 2 — Enrich GitHub

For each unique PR number found, batch-fetch titles and diff sizes:

```bash
.claude/skills/daily-recap/pr-info.sh <owner/repo> <pr> [<owner/repo> <pr> ...]
```

Output: `owner/repo#<pr> | <title> | +<additions>/-<deletions>`. Use diff size to estimate review time (small <100 ≈ 5 min, medium 100–500 ≈ 15 min, large >500 ≈ 30 min). Batch into one invocation to avoid per-call permission prompts.

## Step 3 — Build the timeline

Combine sources into one chronological timeline. For each entry:

- **Time** (local TZ)
- **Source** (Slack channel/DM, Calendar, GitHub repo, Granola, Claude project)
- **What happened** — concise

Group related Slack messages into thread-level entries (one entry per thread, not per message). Merge corroborating signals (a GitHub push + Claude session for the same project = one entry).

For Claude Code sessions, one entry per distinct working window:

- Time range (from first/last substantive prompt in the window)
- Project (short name, not the slug)
- What was worked on (summarized from prompts, not a prompt-by-prompt dump)

### Scope: work, not personal chatter

Filter out personal/social content even if it flowed through Slack/calendar (after-hours plans, restaurant logistics, etc.). Keep "company event happened" at calendar-level only. Mixed work+personal threads → summarize the work portion only.

## Step 4 — Summary

End with a **Summary** section. Stats first, then takeaways.

### Stats

Each stat on its own line; bulleted detail beneath where applicable:

- **PRs Merged** — count + bullets (repo, PR number, title)
- **PRs Opened** — count + bullets
- **PRs Reviewed** — count + bullets
- **Commits** — count, e.g., "6 commits across 2 repos" (excluding `EXCLUDE_REPOS`)
- **Meetings** — count + total duration + bulleted list (time, title)
- **Code Review** — estimated minutes from PR diff sizes (~5/15/30 by size)
- **Slack** — channels/DMs active in
- **Lunch** — detect 30–60 min activity gap typically 12:00–13:30; show range or "No obvious lunch break"
- **Focus Time** — blocks of 30+ min with no Slack and no meetings, **work-hours only** (infer end-of-workday from activity pattern; fall back to 18:00 if no signal). **Exclude lunch**. Sum and list specific blocks. If a block overlaps a Claude session, annotate the project worked on.
- **Longest Focus Block** — the single longest uninterrupted focus block.
- **Evening Work** (optional, informational) — substantive post-dinner work in one line; **not** counted as Focus Time.
- **Claude Sessions** — count of distinct sessions with substantive activity + projects touched.

### Takeaways

2–3 sentences covering key discussions/decisions and main themes of the day.

## Step 5 — Stand-Up Block

Generate a stand-up-ready block in `Daily Notes/`-style format. **Place it first** in the output file (before Timeline and Summary) — it's the most-referenced part.

- **Yesterday** = accomplishments from the previous working day (target date − 1). If target is Monday, label as **Friday** instead. To fill: read prior recap at `_agent/outputs/recaps/<prev>.md`; otherwise leave a single empty bullet.
- **Today** = accomplishments on the target date itself, drawn from this recap's takeaways + key timeline threads.

Format:

```
# Stand Up
**Yesterday**
- <terse bullet>

**Today**
- <terse bullet>
```

Rules:

- Terse, action-phrased, no trailing punctuation. Match the style of any existing stand-ups in the vault.
- 1 to ~10 bullets. Group related work where natural ("Reviews — A, B, C"); don't force compression if the day had distinct threads.
- **PR / TASK references must include a short subject**, not just IDs. `PR#8343 rocket-engine expression library` ✓ — `PR#8343` ✗.
- No meeting-by-meeting detail or Slack chatter — anything that wouldn't belong in a standup gets dropped.

## Step 6 — Save

Write to `_agent/outputs/recaps/<YYYY-MM-DD> - <DayOfWeek> - Recap.md` (e.g., `2026-05-06 - Wednesday - Recap.md`). Create `_agent/outputs/recaps/` if missing.

If the file exists, read it first, merge in new entries, and preserve any manual edits. Don't duplicate.

Tag the file with `source: agent` in frontmatter per `_agent/AGENTS.md`.

## Output format

Markdown with `###` for time blocks, `---` between sections, **bold** for channel/repo names. Order in the file:

1. `# <YYYY-MM-DD> - <DayOfWeek> - Recap` header
2. `# Stand Up` block
3. `## Timeline` (Morning / Lunch / Afternoon / Evening)
4. `## Summary` (Stats + Takeaways)

## Caveats

- **Claude session file span ≠ working window.** A session file can stretch across hours while real activity is clustered. Use `--prompts` timestamps for the truth.
- **Cross-day sessions** are handled by the working-day window (03:00 → 03:00 next day).
- **Sibling project dirs** like `claude-b`, `claude-investigate` are ephemeral scratch workspaces — name them by what was worked on (from prompts), not the dir name.
