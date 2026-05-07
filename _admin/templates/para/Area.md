---
created: <% tp.date.now("YYYY-MM-DD") %>
type: area
tags:
  - type/area
archived: false
source: human
---

# <% tp.file.title %>

**Standard:** 

## Projects

```dataview
TABLE WITHOUT ID file.link AS "Project", status, deadline
FROM "1-Projects"
WHERE contains(area, this.file.link) AND status = "active"
SORT deadline ASC
```

## Notes

```dataview
LIST FROM ""
WHERE contains(tag, this.file.link)
SORT file.mtime DESC
LIMIT 20
```

## Goals

```dataview
LIST FROM "Goals"
WHERE contains(area, this.file.link)
```
