# Knowledge Base Workflow

Karpathy-style LLM Wiki: raw sources -> compiled wiki -> Q&A -> outputs filed back.

Two global files you must keep current:

- `_agent/wiki/index.md` -- master catalog of all topics. Read first, update after every operation.
- `_agent/log.md` -- append-only activity record. Log every operation.

## Step 1: Ingest

When given a source (URL, document, paste, conversation):

1. Identify the topic. Check `wiki/index.md` -- does this topic exist?
2. Save the source to `_agent/raw/[topic]/author-title.md`
   - Frontmatter: `source: agent, type: raw, topic: [name], created: YYYY-MM-DD`
3. Read the source. Discuss key takeaways with the user if in conversation.
4. Write a wiki article summarizing the source in `_agent/wiki/[topic]/`
   - Frontmatter per `tagging.md` schema. Type: `wiki-article`.
   - Link back to the raw source.
   - Cross-link to related articles with `[[wikilinks]]`.
5. Update the topic's `_index.md`:
   - Add the article to the articles table
   - Update `source-count`, `article-count`, `coverage`, `updated`
   - Note any new open questions
6. **Update existing articles across the wiki.** This is the core compounding mechanism. Scan for articles in OTHER topics where this new information adds context, strengthens, contradicts, or extends what's there. Update those articles directly. A single source may touch 5-15 existing pages. Update their topic `_index.md` files too.
7. Update `wiki/index.md` -- refresh the topic's row (summary, counts, date).
8. Append to `_agent/log.md`: `## [YYYY-MM-DD] ingest | Source Title` (list all articles touched)

If the topic is new:
- Create `_agent/wiki/[topic]/` folder
- Create `_agent/wiki/[topic]/_index.md` with the standard template
- Add the topic row to `wiki/index.md`
- Log as both `compile` (new topic) and `ingest` (source)

## Step 2: Compile

When building a topic from multiple sources or from training knowledge:

1. Create the topic folder and `_index.md` (if not exists)
2. Write individual articles -- one concept per article, not one source per article
3. Cross-link articles within the topic and across topics
4. Each `_index.md` must contain:
   - Topic overview (a paragraph or blockquote)
   - Articles table (columns: Article, Status, Summary)
   - Sources list with provenance (only when sources exist -- don't scaffold empty sections)
   - Coverage assessment in frontmatter: `coverage: none | partial | good | comprehensive`
   - Open questions / known gaps
5. Update `wiki/index.md` and `log.md`

## Step 3: Query

When answering a question:

1. Read `wiki/index.md` to find relevant topics
2. Think broadly -- a query about "landing page design" might need articles from philosophy, competitors, visual inspiration, AND design topics. Don't limit to the obvious single topic.
3. Read the relevant `_index.md` files, then drill into articles across topic boundaries
4. Answer from wiki content. Cite articles: "per [[article-name]]..."
5. If wiki has no coverage: answer from training knowledge, flag it as unverified
6. **File good answers back.** If the answer is substantive and reusable:
   - Save to `_agent/outputs/YYYY-MM-DD-description.md`
   - If the answer reveals a gap, create or update a wiki article
   - Log to `log.md` as `query`

## Step 4: Maintain

Ongoing hygiene, triggered by ingests and by explicit health checks:

- **Update articles, not just indexes.** When new information arrives that's relevant to existing articles, update those articles directly. Don't just flag -- integrate the new context.
- When new sources are added: update `_index.md` and `wiki/index.md`
- Bump `updated` date on every changed file
- Note contradictions: when new data conflicts with an existing article, update the article to reflect both claims with dates, and flag in `_index.md` Open Questions
- Never delete -- mark superseded articles with `status: superseded`

## Step 5: Lint (Health Check)

Run when asked ("health check") or proactively when the wiki has grown significantly. Check for:

1. **Contradictions** -- two articles making conflicting claims
2. **Stale claims** -- older articles superseded by newer sources (check dates)
3. **Orphan pages** -- articles with no inbound links from any `_index.md`
4. **Missing pages** -- concepts mentioned in articles that lack their own page
5. **Missing cross-references** -- articles in the same topic that don't link to each other
6. **Data gaps** -- topics with `coverage: partial` or `coverage: none`
7. **Index drift** -- `wiki/index.md` out of sync with actual topic folders
8. **Stale indexes** -- `_index.md` article count doesn't match actual files

Output a report to `_agent/outputs/YYYY-MM-DD-lint-report.md`. Log to `log.md` as `lint`.

## Step 6: File Outputs Back

- Answers, analyses, reports go to `_agent/outputs/`
- Substantive outputs that would benefit future queries should also be distilled into wiki articles
- Your work always "adds up" -- the knowledge base grows with every interaction
