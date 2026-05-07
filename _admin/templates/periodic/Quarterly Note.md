---
created: <% tp.date.now("YYYY-MM-DD") %>
type: quarterly
tags:
  - type/quarterly
---

# <% tp.date.now("YYYY [Q]Q") %>

## Objectives
1. [ ] 
2. [ ] 
3. [ ] 

## Projects and Goals

```dataview
TABLE WITHOUT ID file.link AS "Item", status, deadline FROM "1-Projects" OR "Goals"
WHERE status = "active" OR status = "planned" SORT deadline ASC
```

## Review

Achievements:

What didn't work:

Next quarter:
