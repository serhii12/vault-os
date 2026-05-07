# People

```dataview
TABLE WITHOUT ID file.link AS "Name", company, relationship, last-checkin AS "Last Check-in"
FROM "People"
WHERE type = "person"
SORT file.name ASC
```

## Birthdays

```dataview
TABLE WITHOUT ID file.link AS "Name", birthday, relationship
FROM "People"
WHERE type = "person" AND birthday != null
SORT birthday ASC
```
