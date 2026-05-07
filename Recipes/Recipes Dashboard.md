# Recipes

```dataview
TABLE WITHOUT ID file.link AS "Recipe", cuisine, course, total-time AS "Time", servings
FROM "Recipes"
WHERE type = "recipe" AND inbox != true AND !contains(file.name, "AGENTS")
SORT file.name ASC
```

## Favorites

```dataview
TABLE WITHOUT ID file.link AS "Recipe", cuisine, total-time AS "Time"
FROM "Recipes"
WHERE type = "recipe" AND favorite = true
```

## Quick (≤ 45 min)

```dataview
TABLE WITHOUT ID file.link AS "Recipe", cuisine, total-time AS "Time"
FROM "Recipes"
WHERE type = "recipe" AND total-time <= 45 AND inbox != true
SORT total-time ASC
```

## Inbox

```dataview
LIST FROM "Recipes"
WHERE type = "recipe" AND inbox = true
SORT file.ctime DESC
```
