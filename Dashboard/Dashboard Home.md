# Dashboard

## Today

```tasks
not done
due before tomorrow
short mode
limit 15
```

## Inbox

```dataview
LIST
FROM "Inbox"
WHERE !contains(file.name, "AGENTS")
SORT file.ctime DESC
LIMIT 10
```

## Active Projects

```dataview
TABLE WITHOUT ID file.link AS "Project", status, deadline, area
FROM "1-Projects"
WHERE status = "active" AND !contains(file.name, "AGENTS")
SORT deadline ASC
```

## Recent Notes

```dataview
TABLE WITHOUT ID file.link AS "Note", file.folder AS "In", file.mtime AS "Updated"
FROM "1-Projects" OR "2-Areas" OR "3-Resources" OR "Inbox"
WHERE !contains(file.name, "AGENTS") AND !contains(file.name, ".gitkeep")
SORT file.mtime DESC
LIMIT 10
```

---

[[Dashboard/My Day|My Day]]  ·  [[Dashboard/My Week|My Week]]  ·  [[Dashboard/My Year|My Year]]  ·  [[Dashboard/GTD Workflow|GTD]]  ·  [[Dashboard/PARA Philosophy|PARA]]

[[People/People Dashboard|People]]  ·  [[Books/Books Dashboard|Books]]  ·  [[Recipes/Recipes Dashboard|Recipes]]  ·  [[Goals/Goals Dashboard|Goals]]  ·  [[Content/Content Dashboard|Content]]  ·  [[_agent/Agent Dashboard|Agent KB]]
