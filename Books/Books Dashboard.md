# Books

## Reading

```dataview
TABLE WITHOUT ID file.link AS "Book", author, date-started
FROM "Books"
WHERE type = "book" AND status = "reading"
SORT date-started DESC
```

## To Read

```dataview
TABLE WITHOUT ID file.link AS "Book", author, genre
FROM "Books"
WHERE type = "book" AND status = "to-read"
SORT file.ctime DESC
```

## Read

```dataview
TABLE WITHOUT ID file.link AS "Book", author, rating, date-finished
FROM "Books"
WHERE type = "book" AND status = "read"
SORT date-finished DESC
```
