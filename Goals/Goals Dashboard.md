# Goals

## Active

```dataview
TABLE WITHOUT ID file.link AS "Goal", status, target-date, area
FROM "Goals"
WHERE type = "goal" AND status = "active"
SORT target-date ASC
```

## Dream

```dataview
TABLE WITHOUT ID file.link AS "Goal", area
FROM "Goals"
WHERE type = "goal" AND status = "dream"
SORT file.name ASC
```

## Achieved

```dataview
TABLE WITHOUT ID file.link AS "Goal", target-date, area
FROM "Goals"
WHERE type = "goal" AND status = "achieved"
SORT target-date DESC
```
