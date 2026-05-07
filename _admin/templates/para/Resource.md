---
created: <% tp.date.now("YYYY-MM-DD") %>
type: resource
tags:
  - type/resource
archived: false
source: human
---

# <% tp.file.title %>

## Notes

```dataview
LIST FROM ""
WHERE contains(tag, this.file.link)
SORT file.mtime DESC
```

## Clips

```dataview
TABLE WITHOUT ID file.link AS "Clip", url AS "Source"
FROM ""
WHERE contains(tag, this.file.link) AND type = "clip"
SORT file.ctime DESC
```
