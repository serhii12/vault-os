# My Week

## Clear

```tasks
due before today
not done
short mode
```

```tasks
no due date
not done
path does not include _admin
path does not include 4-Archive
path does not include _agent
short mode
limit 20
```

```dataview
LIST FROM "Inbox"
WHERE !contains(file.name, "AGENTS")
SORT file.ctime DESC
```

## Review

```dataview
TABLE WITHOUT ID file.link AS "Project", status, deadline
FROM "1-Projects"
WHERE (status = "active" OR status = "planned") AND !contains(file.name, "AGENTS")
SORT deadline ASC
```

## Plan

```tasks
due after yesterday
due before in 8 days
not done
sort by due
short mode
```

```tasks
is recurring
not done
short mode
```
