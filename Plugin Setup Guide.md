# Plugins

## Required

| Plugin             | Purpose                                                                        |
| ------------------ | ------------------------------------------------------------------------------ |
| **Templater**      | Dynamic templates. Set folder: `_admin/templates`. Enable trigger on new file. |
| **Dataview**       | Query vault like a database. Enable JS queries in settings.                    |
| **Tasks**          | Track `- [ ]` checkboxes across vault with dates, priorities, recurrence.      |
| **Calendar**       | Month view sidebar. Click dates to create daily notes.                         |
| **Periodic Notes** | Daily/weekly/monthly/quarterly/yearly notes from templates.                    |

## Recommended

| Plugin | Purpose |
|---|---|
| **QuickAdd** | Capture tasks/notes with a keystroke. |
| **Homepage** | Set Dashboard Home as startup page. |
| **Kanban** | Visual boards for project and content pipelines. |
| **Linter** | Auto-format on save. Consistent frontmatter. |
| **Omnisearch** | Smarter vault-wide search. |
| **Obsidian Git** | Auto-backup to GitHub. |
| **Minimal Theme** | Clean theme by kepano. |
| **Granola Sync** | Sync Granola meeting notes into the vault. Pairs with the `ingest-meeting` agent skill. |

## Granola Sync configuration

After enabling **Granola Sync** in Community Plugins:

1. Settings → Granola Sync → **Sync notes**: on.
2. **Destination**: a specific folder, set it to `Granola`.
3. **Sync transcripts**: optional. If on, point at `Granola/Transcripts` (subfolder).
4. **Periodic sync**: every 15 min is a sensible default.

The `ingest-meeting` skill watches `Granola/` and dedupes by `granola_id` from frontmatter. Don't edit files in that folder — the plugin overwrites on next sync. See `Granola/AGENTS.md`.

## Settings

- Default new note location: `Inbox`
- Default attachment location: `_admin/attachments`
- Use wikilinks: On
- New link format: Shortest path

## Core Plugins to Enable

Backlinks · Outgoing Links · Tags · Page Preview · Bookmarks · Quick Switcher · Graph View · Word Count · Properties View
