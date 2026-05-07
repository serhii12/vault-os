# Admin

Templates, attachments, vault configuration, and connection documentation.

**Connection Map:** Read `CONNECTIONS.md` in this folder for the full relation diagram showing how tasks, notes, projects, tags, people, goals, and content link together. This is essential before creating files that need to connect to other parts of the vault.

**Structure:**

- `CONNECTIONS.md` — Relation diagram and frontmatter property reference
- `templates/notes/` — Note, Web Clip, Meeting Note, Voice Note, Journal Entry, Focus Session, Habit Tracker, Weekly Review Checklist, Task
- `templates/periodic/` — Daily, Weekly, Monthly, Quarterly, Yearly note templates
- `templates/para/` — Project, Area, Resource, Person, Book, Recipe, Goal
- `templates/content/` — Content Idea
- `attachments/` — Images and files referenced by notes

**Key connection properties used across templates:**

- `project:` — direct relation to a project (tasks, notes)
- `pulls:` — reference material pulled into a project (notes only)
- `tag:` — PARA organizer (areas, resources, entities)
- `people:` — person relation (tasks, notes, projects)
- `goal:` — goal relation (projects)
- `area:` — area relation (projects, goals)
- `content:` — content piece relation (tasks, notes)

**Agent rules:** Read `CONNECTIONS.md` before creating files that need to link to other vault content. You may create or improve templates when asked.
