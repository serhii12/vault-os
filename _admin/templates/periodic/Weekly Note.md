---
created: <% tp.date.now("YYYY-MM-DD") %>
type: weekly
tags:
  - type/weekly
---

# Week of <% tp.date.now("MMMM D, YYYY") %>

## Clear

```tasks
no due date
not done
path does not include _admin
path does not include 4-Archive
short mode
limit 20
```

```tasks
due before <% tp.date.now("YYYY-MM-DD") %>
not done
short mode
limit 20
```

```dataview
LIST FROM "Inbox" SORT file.ctime DESC
```

## Reflect

What went well?

What needs attention?

## Plan

1. [ ] 
2. [ ] 
3. [ ] 
