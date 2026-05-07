---
name: ingest-meeting
description: Ingest Granola meeting notes (synced into Granola/ by the obsidian-granola-sync plugin) into the LLM Wiki — writes a wiki summary, updates attendee CRM pages, surfaces topic connections and contradictions, drops action items into the right project notes, and logs the ingest with the granola_id so re-runs skip already-processed meetings. Use when the user says "ingest meetings", "/ingest-meeting", "process Granola", "ingest yesterday's meeting", or asks to file new meeting notes into the wiki.
---

# Ingest Meeting — Granola → LLM Wiki

Implements Step 1 (Ingest) of `_agent/context/knowledge-base-workflow.md` for Granola meeting notes. The Granola sync plugin writes the raw layer; this skill compiles it into the wiki.

## Conventions

- **Source folder**: `Granola/` (plugin default). Read-only — see `Granola/AGENTS.md`.
- **Wiki destination**: `_agent/wiki/meetings/`.
- **Person CRM**: `People/<Name>.md` (existing module). Wiki-layer summaries optional under `_agent/wiki/people/`.
- **Log**: append to `_agent/log.md` in the parseable `## [YYYY-MM-DD] op | title` format with `granola_id` for dedup.
- **Tag every agent-created file** with `source: agent` per `_agent/context/tagging.md`.

## Workflow

### Step 0 — Find new meetings

```bash
grep -rl "^type: note$" Granola/ --include="*.md" 2>/dev/null
```

For each candidate, extract its `granola_id` from frontmatter and check whether it's already logged:

```bash
grep -q "granola_id: <id>" _agent/log.md && echo skip || echo ingest
```

Already-ingested → skip. Default scope: just process the unlogged ones. If the user passes a date or count, narrow accordingly (`--since 2026-05-01`, `--last 3`).

### Step 1 — Read each new meeting

Read frontmatter (`granola_id`, `title`, `created`, `attendees`, optional `folders`) and body sections:

- `## Private Notes` — user's typed notes (high signal for intent)
- `## Enhanced Notes` — Granola's processed output (decisions, action items, key topics)
- Optional inline transcript

If `## Enhanced Notes` is missing (very short meeting or sync error), use Private Notes only and flag low-coverage in the log entry.

### Step 2 — Extract structured data

From the body, identify:

1. **Topics discussed** — 2–4 main subjects (project names, problem areas, decisions)
2. **Decisions made** — explicit decisions, with rationale if captured
3. **Action items** — `- [ ]`-style or "X will do Y by Z"; capture owner and due date
4. **Open questions** — unresolved items
5. **Key insights / quotes** — content worth preserving as standalone wiki articles

For each topic, check `_agent/wiki/index.md` — does it already have a wiki folder? If yes, plan an update; if no and the topic recurs (count mentions across past 30 days of `Granola/` files), propose creating it.

### Step 3 — Surface connections (mandatory)

Before drafting writes, search the existing vault:

1. **Backlinks for each attendee** — `grep -rl "\[\[<Name>" --include="*.md"` → has the user been talking with them about adjacent topics?
2. **Topic search** — for each main topic, grep across `1-Projects/`, `2-Areas/`, `_agent/wiki/`, `Journal/daily/`. Read 1–2 most relevant matches per topic.
3. **Recent daily notes** — past 7 days for the same topics; surface "you mentioned this in yesterday's note as well."
4. **Contradictions** — does this meeting conflict with `_agent/wiki/<topic>/`? With a recent daily note? Flag it.
5. **Recurrence** — `grep -l "<topic>" Granola/*.md` → "this is the 3rd meeting on `<topic>` in 2 weeks; consider creating `_agent/wiki/<topic>/_index.md` if it doesn't exist."

### Step 4 — Draft writes (do NOT write yet)

Build a single confirmation block listing every proposed write, grouped by destination:

```
## Proposed writes for "<Meeting title>" (granola_id: <id>)

### Wiki summary (new)
_agent/wiki/meetings/<YYYY-MM-DD>-<slug>.md
  — sections: Attendees · Topics · Decisions · Action items · Open questions
  — links back to: [[Granola/<title>]]

### People (CRM updates)
People/<Name1>.md
  — append to "Recent interactions": <date> — <one-line>
  — owed: <action items they own>
People/<Name2>.md  (NEW — confirm scaffold?)
  — create from _admin/templates/para/Person.md

### Topics
_agent/wiki/<topic>/_index.md
  — append to "Sources": [[meetings/<slug>]]
  — flag contradiction with [[<existing-article>]]: <one-line>

### Action items → tasks
1-Projects/<project>/<file>.md
  — append: - [ ] <task> 📅 2026-05-12 (assigned: <Name>)
Journal/daily/2026-05-06.md
  — append to Tasks: - [ ] <task> 📅 2026-05-08

### Index + Log
_agent/wiki/index.md  — bump meetings topic counts
_agent/log.md          — ## [<date>] ingest | Granola: <title> (granola_id: <id>)
```

### Step 5 — Confirm and apply

Print the block above and ask **once**:

> Apply all proposed writes? `y` = all · `n` = abort · `s` = let me select

On `s`, walk each destination and ask y/n. On `y`, apply atomically:

1. Create the wiki summary with frontmatter (`source: agent · type: wiki-article · topic: meetings · granola: <id>`).
2. Append to existing files (people, topic indexes, project notes, daily notes).
3. Create new files (e.g., `People/<NewName>.md` from template) only when explicitly confirmed.
4. Update `_agent/wiki/index.md` last so counts reflect the writes.
5. Append to `_agent/log.md` last:

   ```
   ## [2026-05-06] ingest | Granola: Q2 planning sync (granola_id: abc123)
   - source: Granola/2026-05-06 - Q2 planning sync.md
   - wiki: _agent/wiki/meetings/2026-05-06-q2-planning-sync.md
   - touched: People/Alex, People/Sam, _agent/wiki/projects/q2-roadmap, 1-Projects/Q2-Roadmap.md
   - actions: 3 task(s) filed
   - granola_id: abc123
   ```

   The `granola_id` line is the dedup key — Step 0 of the next run greps for it.

### Step 6 — Report

After writing, print a one-screen summary:

```
Ingested 2 meetings.
- Q2 planning sync (45m, 4 attendees) → 3 tasks, 2 topic updates, 1 contradiction flagged
- 1:1 with Alex (30m) → 1 task, 1 open question filed

Look at: _agent/wiki/meetings/2026-05-06-q2-planning-sync.md (contradiction with [[product-strategy]])
```

## Style + safety

- **Never modify files in `Granola/`** — see `Granola/AGENTS.md`.
- **Never write to `People/`, `1-Projects/`, or `Journal/daily/` without confirmation** — those are human territory.
- **Skip empty sections** in the wiki summary rather than padding with "None".
- **Cite the source** in every wiki article: link back to `[[Granola/<file>]]`.
- **Flag low-coverage ingests** in the log so the user knows which meetings have thin content.

## Fallback when the plugin isn't running

If `Granola/` is empty but the user wants to ingest a meeting that already happened, use the **Granola MCP** (`mcp__*Granola*`) directly:

1. `mcp__*Granola*list_meetings` for the target date.
2. `mcp__*Granola*get_meeting_transcript` for the chosen one.
3. Synthesize a `Granola/<date> - <title>.md` file matching the plugin's schema (frontmatter + Private Notes + Enhanced Notes) so subsequent runs find it normally.
4. Continue from Step 2.

## When to skip

- File has `type: transcript` — only ingest the matching `type: note`. Transcripts get linked from the wiki summary but aren't ingested separately.
- Meeting < 5 minutes with no Enhanced Notes — log as `skipped: thin content` and move on.
- `granola_id` already in `_agent/log.md` — skip silently unless the user passes `--reingest`.
