---
created: <% tp.date.now("YYYY-MM-DD") %>
type: project
status: planned
deadline: 
area: 
goal: 
people: 
tags:
  - type/project
archived: false
source: human
---

# <% tp.file.title %>

**Goal:** 
**Deadline:** 

## Tasks
- [ ] 

## Notes

```dataview
LIST FROM ""
WHERE contains(project, this.file.link)
SORT file.mtime DESC
```

## Reference

```dataview
LIST FROM ""
WHERE contains(pulls, this.file.link)
SORT file.mtime DESC
```

## Log
- <% tp.date.now("YYYY-MM-DD") %> — Created
