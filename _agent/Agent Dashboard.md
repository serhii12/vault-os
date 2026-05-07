# Agent KB

## Topics

```dataview
TABLE WITHOUT ID file.link AS "Topic", article-count, source-count, coverage, updated
FROM "_agent/wiki"
WHERE type = "index"
SORT updated DESC
```

## Recent Articles

```dataview
TABLE WITHOUT ID file.link AS "Article", topic, status, updated
FROM "_agent/wiki"
WHERE type = "wiki-article"
SORT updated DESC
LIMIT 20
```

## Outputs

```dataview
TABLE WITHOUT ID file.link AS "Output", topic, created
FROM "_agent/outputs"
WHERE source = "agent"
SORT created DESC
LIMIT 10
```

## Graduated

```dataview
TABLE WITHOUT ID file.link AS "Note", file.folder AS "Location", topic
FROM "1-Projects" OR "2-Areas" OR "3-Resources"
WHERE source = "agent-reviewed"
SORT created DESC
```
