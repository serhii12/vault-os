---
name: add-module
description: Scaffold a new vault module (like Books, Goals, Recipes) with a top-level folder, AGENTS.md, and Templater template.
argument-hint: "<module-name>"
---

# Add Module

Create a new vault module - a top-level folder with its own AGENTS.md and Templater template, like the existing Books, Goals, People, Recipes, and Content modules.

## Arguments

`$ARGUMENTS` may contain the module name. If not provided, ask.

## Step 1: Gather info

Ask the user in one message:

1. **Module name** (if not in arguments) - becomes the folder name
2. **One-line description** - what is this module for?
3. **Properties** - frontmatter fields specific to this module (e.g. Books has `author, status, rating, genre, format`). Ask for field names and any default values.
4. **Statuses** (optional) - if entries have a lifecycle, what are the stages? (e.g. Books: `to-read -> reading -> read`)
5. **Body sections** - what sections should new entries have? (e.g. Books has "Why Read This, Reading Log, Key Takeaways, Notes, Rating")
6. **Dataview queries** (optional) - should entries show related projects, people, tasks, or other linked content?
7. **Agent rules** - how should the agent interact with this module? Default: "Read for context. Don't create or modify entries without being asked."

Skip questions the user has already answered.

## Step 2: Confirm

Show the user exactly what will be created:

1. **Folder:** `<Module Name>/`
2. **AGENTS.md** - show the full draft
3. **Template:** `_admin/templates/para/<Module Name>.md` - show the full draft
4. **Dashboard:** `<Module Name>/<Module Name> Dashboard.md` - show the draft
5. **Registrations:** changes to `CLAUDE.md` and `Dashboard/Dashboard Home.md`

Wait for the user to confirm or request changes.

## Step 3: Create

### 3a. Create the folder

Create `<Module Name>/` at the vault root.

### 3b. Create AGENTS.md

Write `<Module Name>/AGENTS.md` following the existing pattern. Structure:

```markdown
# <Module Name>

<One-line description.>

**Statuses:** `status-a` -> `status-b` -> `status-c`
**Properties:** <list of key frontmatter fields and their meaning>

<Any additional notes about how the module works - integrations, special behaviors, etc. Keep it brief.>

**Agent rules:** <How the agent should interact with this module.>

**Templates:** `_admin/templates/para/<Module Name>.md`
```

Rules for writing AGENTS.md:
- Match the tone of existing ones: terse, factual, no fluff
- Only include **Statuses** if the module has a status workflow
- Only include **Properties** if there are non-obvious fields worth documenting
- **Agent rules** should always include "Don't create or modify entries without being asked" unless the user says otherwise
- Always end with the **Templates** line pointing to the template path

### 3c. Create the Templater template

Write to `_admin/templates/para/<Module Name>.md` (or `_admin/templates/<subfolder>/` if the user prefers a different location).

Template structure:

```markdown
---
created: <% tp.date.now("YYYY-MM-DD") %>
type: <module-name-lowercase>
tags:
  - type/<module-name-lowercase>
<custom properties with defaults or empty values>
archived: false
source: human
---

# <% tp.file.title %>

<body sections as specified by the user>
```

Rules for templates:
- `created`, `type`, `tags`, `archived`, `source` are always present
- Custom properties go between `tags` and `archived`
- Status fields get their default value (usually the first status in the workflow)
- Empty properties use blank value (no quotes, just empty)
- Boolean properties default to `false`
- Body uses `##` headings for sections
- Dataview queries use the standard format from existing templates (match `FROM`, `WHERE`, `SORT` patterns)
- Use `<% tp.file.title %>` for the note title
- Use `<% tp.date.now("YYYY-MM-DD") %>` for dates

### 3d. Create the module dashboard

Create `<Module Name>/<Module Name> Dashboard.md` with Dataview queries that list all entries in the module. Follow the pattern of existing dashboards (e.g. Books Dashboard, Recipes Dashboard).

Basic structure:

```markdown
# <Module Name>

## All <Module Name>

\```dataview
TABLE WITHOUT ID file.link AS "<Entry Type>", status
FROM "<Module Name>"
WHERE type = "<module-name-lowercase>" AND !contains(file.name, "AGENTS") AND !contains(file.name, "Dashboard")
SORT file.mtime DESC
\```
```

Add additional filtered views if the module has statuses (e.g. "Active", "Completed" sections).

### 3e. Register the module

**`CLAUDE.md`** - Add the new module to the folder map in the `## What` code block. Insert it alphabetically among the standalone modules (after the PARA folders, before `_admin` and `_agent`). Follow the existing format:

```
<Module Name>/    → <One-line description>
```

**`Dashboard/Dashboard Home.md`** - Add a link to the module dashboard on the bottom navigation line (line 45). Follow the existing format:

```
[[<Module Name>/<Module Name> Dashboard|<Module Name>]]
```

Append it after the last module link, before the Agent KB link.

## Step 4: Log

Append to `_agent/log.md`:

```
## [YYYY-MM-DD] module | Added <Module Name>
- Created `<Module Name>/AGENTS.md`
- Created `<Module Name>/<Module Name> Dashboard.md`
- Created `_admin/templates/para/<Module Name>.md`
- Registered in `CLAUDE.md` and `Dashboard/Dashboard Home.md`
- Properties: <list>
- Statuses: <workflow or "none">
```
