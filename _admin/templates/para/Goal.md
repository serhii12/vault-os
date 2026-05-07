---
created: <% tp.date.now("YYYY-MM-DD") %>
type: goal
tags:
  - type/goal
status: active
target-date: 
area: 
archived: false
source: human
---

# <% tp.file.title %>

**Success looks like:** 

## Projects

```dataview
TABLE WITHOUT ID file.link AS "Project", status, deadline
FROM "1-Projects"
WHERE contains(goal, this.file.link)
SORT deadline ASC
```

## Milestones

| Milestone | Date | Done |
|---|---|---|
| | | |

## Log
- <% tp.date.now("YYYY-MM-DD") %> — Created
