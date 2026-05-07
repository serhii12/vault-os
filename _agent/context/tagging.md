# Tagging Schema

## Source Tags (MANDATORY on every file you create)

| Value | Meaning |
|---|---|
| `source: human` | Created by the user (default if field absent) |
| `source: agent` | Created by you |
| `source: agent-reviewed` | Your work, reviewed and approved by user |
| `source: external` | Clipped from web or imported |

## Frontmatter Template

```yaml
---
source: agent
type: wiki-article | research | output | raw | index
topic: topic-name
created: YYYY-MM-DD
updated: YYYY-MM-DD
status: draft | complete | superseded
summary: One-line description
related: []
---
```

## Filtering (how the human excludes agent content)
- Graph view: `-path:_agent`
- Search: `-path:_agent`
- Dataview: `WHERE source != "agent"`
