---
name: close-day
description: End-of-day processing ritual. Reads today's daily note, surfaces vault connections (tags, backlinks, orphans), detects confidence shifts and contradictions, extracts action items / ideas / commitments / questions, and suggests filing locations and context-file updates. Use when the user says "close the day", "/close-day", "wrap up", "end of day", "eod", or asks to process today's note.
---

# Close Day — End-of-Day Processing

A ~5-minute ritual that turns today's free-form daily note into filed tasks, surfaced connections, and updated context. **Don't summarize the day** — file what matters and surface what's worth revisiting.

## Conventions

- **Today's note**: `Journal/daily/YYYY-MM-DD.md` (use `date +%F` for the date).
- **Context files**: `_agent/context/*.md`.
- **Output**: chat only — no file written. Suggestions await user confirmation before any vault edits.
- **Tone**: concise. Match Noa's voice in `_agent/context/SOUL.md`.

## Workflow

### Step 1 — Read today's note

Read `Journal/daily/$(date +%F).md`. Parse: free-form writing, meeting notes, ideas, commitments, tasks, people referenced, claims with confidence ("I think…", "definitely…", "maybe…").

If the file is missing, tell the user and stop.

### Step 1.5 — Vault connection discovery

Run these in parallel:

1. **Active themes** — count Obsidian `#tags` across active folders to see what's been on your mind:
   ```bash
   grep -rho "#[a-zA-Z][a-zA-Z0-9/_-]*" --include="*.md" \
     Journal/daily/ 1-Projects/ 2-Areas/ 2>/dev/null \
     | sort | uniq -c | sort -rn | head -15
   ```
2. **Topic search** — for each major topic in today's note (3 max), grep across `1-Projects/`, `2-Areas/`, `3-Resources/`, `Journal/`, `_agent/wiki/`. Read the 2 most relevant matches per topic.
3. **Backlinks** — for notes referenced today (people, projects, concepts), find what else links to them:
   ```bash
   grep -rl --include="*.md" "\[\[<note-name>" 2>/dev/null
   ```
4. **Orphans** — recently modified human-authored notes that may relate to today's themes:
   ```bash
   find Inbox 1-Projects 2-Areas 3-Resources Journal -name '*.md' -mtime -14 2>/dev/null
   ```
   Filter to those without `source: agent` frontmatter.
5. **Recurrence count** — for each major topic, count how many of the last 14 daily notes mention it. Surface anything that recurs ≥3 times: "This is the 3rd time `<topic>` has come up in the past two weeks." Suggests the topic might warrant its own context file or project.
   ```bash
   ls Journal/daily/*.md 2>/dev/null | sort -r | head -14 \
     | xargs grep -l -i "<topic>" 2>/dev/null | wc -l
   ```

### Step 1.6 — Confidence marker detection

For each topic in today's note that has a corresponding context file (e.g., `_agent/context/<topic>.md` or `1-Projects/<project>/`), compare today's language to existing markers:

- "Yesterday you sounded **questioning** on X — today you wrote about it as **settled**. Update the marker?"
- "You wrote confidently about Y today, but the context file still flags it as **hypothesis**."

Only flag genuine shifts. Skip anything ambiguous.

**No per-topic context files yet?** The vault currently has only the core context files (`IDENTITY.md`, `USER.md`, `SOUL.md`, `AGENTS.md`) — no per-topic stance files. Skip this step until topic context files exist. If a topic surfaced in the recurrence count (≥3 mentions in 2 weeks), suggest creating one:
> *"`<topic>` has come up 3× in 14 days. Want to create `_agent/context/<topic>.md` with sections for Confidence markers, Open Questions, and Recent shifts?"*

### Step 1.7 — Contradiction surfacing

For strong claims in today's note, grep for earlier mentions of the same topic:

```bash
grep -rn "<key phrase>" --include="*.md" Journal/ 1-Projects/ 2-Areas/ _agent/ 2>/dev/null
```

Flag genuine conflicts only:
- "On `<date>` you wrote `<X>`. Today you wrote `<Y>`. These don't agree — worth reconciling?"
- "Today resolved the open question from `<earlier date>` about `<topic>`."

### Step 2 — Extract & categorize

Pull from today's note into four buckets:

- **Action items** — tasks, commitments, deadlines mentioned ("I'll send…", "follow up with…", "by Friday…")
- **Ideas & insights** — original thinking worth preserving (observations, project ideas, perspective shifts)
- **People & commitments** — follow-ups owed, meetings to schedule, messages to send
- **Questions raised** — things to investigate, decisions pending, uncertainties

### Step 3 — Suggest filing locations

Render a table mapping each extracted item to where it should live:

| Item | Type | Suggested location | Action |
|---|---|---|---|
| `<short description>` | Action | Google Tasks **or** today's daily note | Google Tasks: create with due date · Obsidian: append `- [ ] <task> 📅 YYYY-MM-DD` |
| `<short description>` | Insight | `_agent/context/<file>.md` § "Recent shifts" | Append bullet |
| `<short description>` | Idea | Related project note (or `Content/ideas.md` if it exists) | Append to running log |
| `<short description>` | Person follow-up | `People/<name>.md` | Add to "Owed" section |

**Task filing rule**: prefer Google Tasks for items with hard external deadlines or that need to leave the vault. Prefer Obsidian Tasks (`- [ ] … 📅`) for vault-internal work that lives alongside the project. Default to Obsidian Tasks if unsure.

**Verify targets exist** before suggesting them (`ls People/<name>.md`, `ls Content/ideas.md`, etc.). If a target doesn't exist, suggest **creating** it instead of writing to a missing path.

### Step 4 — Suggest backlinks

First, list which `[[wikilinks]]` are **already** in today's note so you don't re-suggest them:

```bash
grep -oE "\[\[[^]]+\]\]" "Journal/daily/$(date +%F).md" 2>/dev/null | sort -u
```

Then identify terms in today's note that **should** link but don't yet:

- People mentioned → `People/<name>.md` if it exists
- Projects mentioned → `1-Projects/<project>/`
- Concepts → `_agent/wiki/<concept>.md` or relevant context file

Verify each target exists before suggesting (`ls` or quick `Read`). Skip terms already linked. Present as:

> Consider adding these backlinks: `[[Person Name]]`, `[[Project Name]]`, `[[Concept]]`

### Step 5 — Context file updates

For each candidate update, ask explicitly:

> Update `_agent/context/<file>.md` § "What's shifted recently" with: "<one-line change>"? (y/n)

Possible target sections:
- **What's shifted recently** — new beliefs or perspective changes
- **Constraints** — newly discovered limits
- **Open Questions** — questions resolved or raised
- **Confidence markers** — promotions/demotions

Apply only on confirmation. Stamp updated files with current date.

**No matching context file?** If a candidate update has no home (e.g., you flagged a shift on a topic that has no `<topic>.md`), offer to **create** the file instead:
> *"No context file exists for `<topic>`. Want me to scaffold `_agent/context/<topic>.md` with the standard sections and add this entry?"*

### Step 6 — Carry forward + quick wrap

**Carry forward** — what should be top of mind tomorrow:
- Unfinished priorities
- Commitments due soon
- Momentum to maintain

**Quick wrap** — if the daily-note's Quick Wrap section is empty, draft answers from the day's content:
1. Did I explore anything new today?
2. What did I actually move forward?
3. What bottleneck became obvious?
4. One thing to carry into tomorrow?

Offer to append the drafted Quick Wrap to today's note (with confirmation, per `Journal/AGENTS.md` rules).

## Output format

Use these section headers in this order. Keep total output under one screen.

```
## Today's Extraction
**Action items** — bullets
**Ideas** — bullets
**People** — bullets
**Questions** — bullets

## Vault Connections
- Confidence shifts (only if any)
- Contradictions (only if any)
- Recurring themes (only if signal)

## Filing Suggestions
| table |

## Backlinks to Add
- [[…]] · [[…]] · [[…]]

## Context File Updates
- Update `<path>` § <section>: "<change>" — apply? (y/n)

## Carry Forward
- bullets

## Quick Wrap (draft, if needed)
1. …  2. …  3. …  4. …
```

## Rules

- **Don't write anywhere without confirmation.** Daily notes, context files, and People/ entries all require user approval per their `AGENTS.md` files.
- **Skip empty sections** in the output rather than printing "none".
- **Stop at signal.** If a category is empty, leave it out. Don't pad.
- **No summary of the day.** This isn't a recap — it's a filing pass.
