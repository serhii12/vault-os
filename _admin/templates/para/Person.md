---
created: <% tp.date.now("YYYY-MM-DD") %>
type: person
tags:
  - type/person
company: 
title: 
location: 
phone: 
email: 
birthday: 
relationship: 
last-checkin: 
areas: 
archived: false
source: human
---

# <% tp.file.title %>

## Notes

## Gift Ideas
- 

## Meetings

```dataview
LIST FROM ""
WHERE type = "meeting" AND contains(people, this.file.link)
SORT file.ctime DESC
```

## Tasks

```tasks
description includes <% tp.file.title %>
not done
short mode
```

## Projects

```dataview
LIST FROM "1-Projects"
WHERE contains(people, this.file.link)
```
