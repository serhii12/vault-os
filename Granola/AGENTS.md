---
source: agent
type: agents
topic: granola
created: 2026-05-06
updated: 2026-05-06
---

# Granola — Agent Rules

This folder is owned by the **obsidian-granola-sync** plugin. Files here are written and updated by the plugin from the Granola API. Treat them as the **raw layer** of the LLM Wiki pattern — immutable from the agent's perspective.

## Rules

- **Never modify files in this folder.** The plugin will overwrite them on the next sync. If you need to add commentary, do it in `_agent/wiki/meetings/<slug>.md`.
- **Never delete files in this folder.** The plugin tracks state via `granola_id`; deleting confuses it.
- **Read freely.** This is your source of truth for meeting notes, transcripts, and attendees.

## File schema (from the plugin)

Notes (`type: note`):

```yaml
granola_id: <stable id, primary key for dedup>
title: <meeting title>
type: note
created: <ISO timestamp>
updated: <ISO timestamp>
attendees: [Name1, Name2]
transcript: "[[Transcripts/...md]]"   # optional
folders: [granola folder paths]        # optional
```

Body sections:

- `## Private Notes` — your typed notes during the meeting
- `## Enhanced Notes` — Granola's processed output (decisions, key points, action items)
- Optional inline transcript

Transcripts (`type: transcript`) live in a sibling folder per plugin config.

## Where things go after ingestion

The `ingest-meeting` skill reads these files and produces:

- Wiki summary → `_agent/wiki/meetings/<YYYY-MM-DD>-<slug>.md`
- Attendee CRM updates → `People/<Name>.md`
- Topic / project page updates → `_agent/wiki/<topic>/` or `1-Projects/<project>/`
- Action items → Obsidian Tasks (`- [ ] … 📅 date`) appended to relevant project notes or today's daily note
- Index update → `_agent/wiki/index.md`
- Log entry → `_agent/log.md` with the `granola_id` so re-runs skip already-ingested files
