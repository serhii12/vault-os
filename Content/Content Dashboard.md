# Content

## Ideas

```dataview
TABLE WITHOUT ID file.link AS "Idea", content-type, platform
FROM "Content"
WHERE type = "content" AND status = "idea"
SORT file.ctime DESC
```

## In Progress

```dataview
TABLE WITHOUT ID file.link AS "Content", content-type, platform, status
FROM "Content"
WHERE type = "content" AND (status = "drafting" OR status = "editing" OR status = "planned")
SORT file.mtime DESC
```

## Published

```dataview
TABLE WITHOUT ID file.link AS "Content", content-type, platform, publish-date
FROM "Content"
WHERE type = "content" AND status = "published"
SORT publish-date DESC
LIMIT 20
```
