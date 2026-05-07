---
name: today
description: Start the day with a structured review and plan. Pulls calendar, email, tasks, recent messages, daily notes, and vault context, then synthesizes a core theme, top priorities, quick wins, and meeting audit, and finally generates an interactive HTML dashboard. Use when the user says "start my day", "today", "/today", "daily review", "morning review", "plan the day", or asks for a daily dashboard.
---

# Today — Daily Review & Planning

Run the full morning review and produce an interactive HTML dashboard. The user starts their day on this output, so it must be complete and decisive — not exploratory.

## Conventions

- **Daily notes**: `Journal/daily/YYYY-MM-DD.md`.
- **Context files**: `_agent/context/IDENTITY.md`, `_agent/context/USER.md`, `_agent/context/SOUL.md`, `_agent/context/AGENTS.md`.
- **Dashboard output**: `_agent/outputs/today.html` (overwrite each run; directory already exists).
- **Date**: today, in the user's local TZ. Get the day name with `date +%A`.
- **Tag any file you create** with `source: agent` in frontmatter.

## Prerequisites (MCP servers)

The user has these connected:

- **Google Calendar** (`mcp__*Google_Calendar__*`) — required.
- **Gmail** (`mcp__*Gmail__*`) — required.
- **Slack** — required for Step 1.5. The exact tool name varies by client. At session start, scan available tools for one matching `mcp__*[Ss]lack*` (e.g., `search_messages`, `read_channel`). If none is loaded, skip Step 1.5 and tell the user once to expose the Slack MCP — do not silently proceed without it.

These are optional / may not be present:

- **Google Tasks** — preferred for the task system. If no Google Tasks MCP is loaded, fall back to **Obsidian Tasks** (see below), then to free-text TODO scanning. Tell the user once that Google Tasks would give richer data. Do not silently skip.
- **Granola** (`mcp__*Granola__*`) — optional, for meeting notes from yesterday.

Do **not** use Linear here.

## Task source priority

The vault has the Obsidian **Tasks plugin** installed. Tasks across markdown files use this syntax:

- `- [ ] Task text 📅 2026-05-06` — due date
- `- [ ] Task text ⏳ 2026-05-06` — scheduled
- `- [ ] Task text 🛫 2026-05-06` — start date
- `- [x] Done ✅ 2026-05-06` — completed
- Priorities: `⏫` high, `🔼` med-high, `🔽` low, `⏬` lowest
- Recurring: `🔁 every week`

Order of precedence for Step 1 task discovery:

1. **Google Tasks MCP** if loaded — primary.
2. **Obsidian Tasks markdown** — grep for open `- [ ]` items with `📅` dates and bucket by date. Skip `_agent/`, `4-Archive/`, `.obsidian/`, `.claude/`. Example:
   ```bash
   grep -rn "^- \[ \].*📅" --include="*.md" \
     1-Projects 2-Areas 3-Resources Inbox Journal Goals Content People Books Recipes 2>/dev/null
   ```
3. **Free-text TODOs** in the past 7 daily notes — last resort.

## Workflow

Run steps 1, 1.5, and 3 in parallel where possible. Steps 4 onward depend on prior context.

### Step 1 — Calendar + Email + Tasks (parallel)

Run these concurrently:

1. **Google Calendar** — list events for today + next 3 days.
2. **Gmail** — search threads with `newer_than:1d` for unread/important threads. Look for: requests, commitments, time-sensitive items.
3. **Tasks** — pull from the highest-priority source available (see "Task source priority" above) and bucket them:
   - **Overdue** (dueDate < today) — flag prominently
   - **Due today** (dueDate == today)
   - **Due this week** (today < dueDate ≤ today+7)
   - **Quick wins** — low-effort tasks (short titles; verbs like "send", "reply", "update", "confirm", "ping"; or tagged `#quick` / `quick` priority `🔽`)
   - **No due date** (floating)

**Sparse data handling**: If Calendar is empty today, lean on vault patterns + overdue tasks + context files. If the task source returns few results, also scan the past 7 daily notes for informal task mentions (`TODO`, `I need to…`, `follow up on…`).

### Step 1.5 — Recent messages (Slack, last 24h)

Use whichever Slack search/read tool is available in the session (see Prerequisites for how to find it). Query for the last 24h of DMs and channels the user is active in. Look for: commitments made, plans confirmed, requests from others, follow-ups needed.

If no Slack tool is loaded, skip and note in the synthesis output.

### Step 2 — Review recent daily notes

Read the past 7 daily notes from `Journal/daily/`:

```bash
ls Journal/daily/ | sort -r | head -7
```

Read each. Look for: recurring themes, unfinished threads, commitments made, energy patterns, "I need to…" / "TODO" / "follow up on…" mentions.

**Sparse-data handling**: If fewer than 3 daily notes exist in the last 7 days, expand to 14 days. If still sparse, note it explicitly in the synthesis and rely more on calendar + context files.

### Step 3 — Load context files

Read in parallel: `_agent/context/IDENTITY.md`, `_agent/context/USER.md`, `_agent/context/SOUL.md`. If the user's recent notes name an active project, also read its folder under `1-Projects/`. Read `_admin/CONNECTIONS.md` if the day's priorities touch database/integration work.

### Step 4 — Detect hard constraints

Check whether today has unusual structure that overrides normal ranking:

- Solo parenting / partner travel changing childcare?
- Travel day or transit compressing the work window?
- Recording / content day requiring energy management?
- Special events (launches, deadlines, investor meetings)?
- Back-to-back meetings with no gaps?

Pull signals from calendar event titles/locations and any explicit notes in today's daily-note (if it exists). **Flag constraints prominently** — they override priority ranking in Step 7.

### Step 5 — Preliminary priorities

Synthesize so far:
- 2–3 most pressing items from calendar + tasks + recent notes
- Dominant themes from the past week
- Active tensions or open questions from context files

These guide vault exploration in Step 6 — don't lock them in yet.

### Step 6 — Deep vault exploration

Use the vault to enrich and challenge the preliminary priorities. Use `Grep` and `Read` directly:

1. **Active themes** — Count Obsidian inline `#tag` frequency across active folders and compare with today's preliminary priorities. Disconnect = signal.
   ```bash
   grep -rho "#[a-zA-Z][a-zA-Z0-9/_-]*" --include="*.md" \
     Journal/daily/ 1-Projects/ 2-Areas/ 2>/dev/null \
     | sort | uniq -c | sort -rn | head -15
   ```
2. **Priority-informed search** — For each top priority, `Grep` across `1-Projects/`, `2-Areas/`, `3-Resources/`, `Journal/` for the topic. Read 2–3 most relevant matches.
3. **Backlinks (2–3 hops)** — For key notes surfaced, follow `[[wikilinks]]` (including aliased `[[note|alias]]`) outward. Use `grep -rl --include="*.md" "\[\[<note-name>\(\]\]\||\)"` or simpler: `grep -rl "\[\[<note-name>" --include="*.md"`.
4. **Orphans / forgotten notes** — Quick scan of `Inbox/` and recently modified notes outside the agent's own outputs:
   ```bash
   find Inbox 1-Projects 2-Areas 3-Resources Journal -name '*.md' -mtime -14 2>/dev/null
   ```
   Skip `_agent/`, `4-Archive/`, `.obsidian/`, `.claude/`. Filter to notes with no `source:` frontmatter (i.e., human-authored).
5. **Surface contradictions** — Does a recent daily note express doubt about a priority? Does a context-file open question suggest a different focus? Has thinking on a key topic shifted?

The goal is illumination, not exhaustive cross-referencing. Stop when you have signal.

### Step 7 — Synthesize

Produce, in order:

**Core Theme** — single phrase or sentence capturing what today should be about.

**Top 2 Priorities** — the two most important things. Rank by:
- Blocks others if not done
- Has a hard deadline
- Compounds negatively if delayed
- Directly advances current goals from context files

For each, include the **vault context**: related thinking found, connections, questions raised.

**Quick Wins (5)** — tasks completable in <15 min that unblock someone, clear mental overhead, or prevent small things from becoming big.

**Meeting Audit** — flag meetings that should be:
- **Cancelled** — no agenda, input not essential, could be async
- **Converted to async** — replaceable by doc/video/thread
- **Shortened** — padded time

For each flagged meeting, suggest the specific action and the artifact that would replace it.

### Step 8 — Generate the dashboard

Generate `_agent/outputs/today.html` from the template at `assets/dashboard-template.html`. See [`references/dashboard-spec.md`](references/dashboard-spec.md) for placeholder names and data shape. Steps:

1. Ensure the output directory exists: `mkdir -p _agent/outputs`.
2. Read `assets/dashboard-template.html`.
3. Replace placeholders with synthesized data (date, theme, priorities, schedule, tasks, upcoming events, alerts).
4. Write to `_agent/outputs/today.html` (overwrite).
5. Print the absolute file path so the user can open it.

The dashboard is **the deliverable**. The text synthesis precedes it; the HTML is what the user lives in.

## Output to chat (before the dashboard)

Format with clear headers in this order:

```
## Core Theme
<one phrase>

## Hard Constraints
<bulleted, only if present>

## Top 2 Priorities
1. <priority> — <vault context>
2. <priority> — <vault context>

## Quick Wins
- ...

## Meeting Audit
- <meeting> → cancel / async / shorten — <reason>

## Dashboard
Generated at: _agent/outputs/today.html
```

Then mention any sparse-data caveats from Step 2.

## Style

- Direct, actionable, terse. Match Noa's voice (see `_agent/context/SOUL.md`).
- No hedging. If signal is weak, say so once; don't over-qualify every line.
- Action-phrased bullets, no trailing punctuation.
