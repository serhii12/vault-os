# My Year

## Active Goals

```dataview
TABLE WITHOUT ID file.link AS "Goal", status, target-date, area
FROM "Goals"
WHERE type = "goal" AND status = "active"
SORT target-date ASC
```

## Active Projects

```dataview
TABLE WITHOUT ID file.link AS "Project", status, deadline, area
FROM "1-Projects"
WHERE status = "active" AND !contains(file.name, "AGENTS")
SORT deadline ASC
```

## Achieved

```dataview
TABLE WITHOUT ID file.link AS "Goal", target-date
FROM "Goals"
WHERE type = "goal" AND status = "achieved"
SORT target-date DESC
```

## Completed

```dataview
TABLE WITHOUT ID file.link AS "Project", deadline
FROM "1-Projects"
WHERE status = "done" AND !contains(file.name, "AGENTS")
SORT deadline DESC
```
