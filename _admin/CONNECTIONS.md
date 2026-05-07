# Connections

## How Things Link

Pages use YAML frontmatter with `"[[wikilinks]]"` — queried by Dataview.
Tasks are checkboxes (`- [ ]`) inside pages with emoji metadata — queried by Tasks plugin.

```
GOALS → (goal:) → PROJECTS → (project:) → NOTES
                      ↕                      ↕
                   (area:)              (tag: / people:)
                      ↕                      ↕
                    TAGS                  PEOPLE
```

Tasks live inside project pages and daily notes as checkboxes.

## Frontmatter Properties

| From | Property | To | Meaning |
|---|---|---|---|
| Note | `project:` | Project | Note is part of this project |
| Note | `pulls:` | Project | Note is reference for this project |
| Note | `tag:` | Tag | Note belongs to this area/resource |
| Note | `people:` | Person | Note involves this person |
| Note | `content:` | Content | Research for this content |
| Project | `area:` | Tag | Project belongs to this area |
| Project | `goal:` | Goal | Project serves this goal |
| Project | `people:` | Person | Person involved |
| Goal | `area:` | Tag | Goal belongs to this area |

## Task Syntax

```markdown
- [ ] Task name 📅 2026-04-15 ⏫ 🔁 every week
```

📅 due · 🛫 start · ⏳ scheduled · ⏫ highest · 🔼 high · 🔽 low · ⏬ lowest · 🔁 recurrence

## Querying

Tasks plugin:
```tasks
due today
not done
short mode
```

Dataview (pages):
```dataview
LIST FROM "" WHERE contains(project, [[Project Name]])
```

Frontmatter links use `"[[Link]]"` (quoted). Dataview WHERE uses `[[Link]]` (unquoted).
