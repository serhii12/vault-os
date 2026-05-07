# Vault OS

A PARA-based Obsidian vault with a built-in AI agent layer for personal productivity.

Capture, organize, and act on the things in your life — with an agent (Noa) that lives inside the vault and helps you plan, review, and connect ideas.

## What's inside

- **PARA structure** — Projects, Areas, Resources, Archive
- **Periodic notes** — daily / weekly / monthly / quarterly / yearly
- **Personal CRM, books, recipes, goals, content pipeline**
- **Dashboards** powered by Dataview
- **Agent workspace** at `_agent/` for AI-driven workflows
- **Claude Code skills** for repeatable agent tasks (e.g. `/today` for daily review)

## Quick start

1. Clone this repo and open the folder as a vault in Obsidian.
2. **Settings → Community Plugins → Turn off Safe Mode**.
3. Install these plugins: Templater, Dataview, Tasks, Calendar, QuickAdd, Kanban, Excalidraw, Homepage, Linter, Minimal Theme, Style Settings, Hider.
4. Set the template folder to `_admin/templates`.
5. Open `Dashboard/Dashboard Home.md` and pin it as your homepage.
6. (Optional) Open this directory in Claude Code and run `Run bootstrap` to personalize the agent.

For a more guided walkthrough, see [`START HERE.md`](START%20HERE.md) and [`BOOTSTRAP.md`](BOOTSTRAP.md).

## Structure

| Folder | Purpose |
|---|---|
| `Inbox/` | Quick capture — process later |
| `1-Projects/` | Active work with goals and deadlines |
| `2-Areas/` | Ongoing responsibilities |
| `3-Resources/` | Interests and reference material |
| `4-Archive/` | Inactive items |
| `Journal/` | Daily, weekly, monthly, quarterly, yearly notes |
| `People/` | Personal CRM |
| `Books/` | Reading tracker |
| `Recipes/` | Recipes and meal planning |
| `Goals/` | Goal tracking with milestones |
| `Content/` | Creator pipeline (idea → published) |
| `Dashboard/` | Dataview views and philosophy docs |
| `_admin/` | Templates, attachments, connection docs |
| `_agent/` | Agent workspace (context, knowledge base, outputs) |

## The agent layer

The vault ships with an AI agent (default: **Noa**) that operates via [Claude Code](https://claude.com/claude-code). The agent's identity, tone, and operating rules live in `_agent/context/`:

| File | Role |
|---|---|
| `IDENTITY.md` | Agent name and self-concept |
| `USER.md` | Who you are |
| `SOUL.md` | Tone and boundaries |
| `AGENTS.md` | Operating workflows |
| `tagging.md` | Frontmatter tagging rules |

Each major folder also has its own `AGENTS.md` describing how the agent should behave when working there.

### Skills

Reusable agent workflows live in `.claude/skills/`. Highlights:

- **`today`** — daily review and planning. Pulls calendar, email, tasks, and recent messages, then synthesizes a core theme + top priorities + quick wins + meeting audit, and renders an interactive HTML dashboard at `_agent/outputs/today.html`.
- **`close-day`** — end-of-day processing. Reads today's daily note, surfaces vault connections (tags, backlinks, orphans), detects confidence shifts and contradictions, and suggests filing locations and context-file updates.
- **`daily-recap`** — chronological end-of-day timeline from Slack, GitHub, calendar, meeting notes, and Claude Code sessions.
- **`ingest-meeting`** — file Granola meetings into the LLM Wiki. Reads new notes from `Granola/` (synced by the obsidian-granola-sync plugin), drafts a wiki summary, updates attendee CRM pages, surfaces topic connections and contradictions, drops action items into project notes, and logs the ingest with `granola_id` for dedup.
- **`add-module`** — scaffolds a new vault module (folder + `AGENTS.md` + Templater template).

## Conventions

- Every agent-created file is tagged with `source: agent` in its frontmatter.
- The agent writes only inside `_agent/` unless explicitly asked otherwise.
- `Dashboard/` markdown pages auto-update via Dataview — agents do not write there.
- Daily notes follow `Journal/daily/YYYY-MM-DD.md`.

## Plugins

Required: **Templater, Dataview, Tasks, Calendar, QuickAdd**.
Recommended: **Kanban, Excalidraw, Homepage, Linter, Minimal Theme, Style Settings, Hider**.

See [`Plugin Setup Guide.md`](Plugin%20Setup%20Guide.md) for details.

## License

MIT. Use, fork, and adapt freely.
