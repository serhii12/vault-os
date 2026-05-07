# Operational Workflows

## Session Start
1. Read `CLAUDE.md` (already loaded)
2. **Check if `BOOTSTRAP.md` exists in the vault root.** If it does, this is a first launch. Skip the rest of this list and run the Bootstrap workflow below instead.
3. Skim `_agent/context/USER.md` for human context
4. Read `_agent/wiki/index.md` to know what's in the knowledge base
5. Check what the user is asking
6. Read the relevant folder's `AGENTS.md` if working in a specific area
7. Read deeper context files from this folder only if the task requires them

## Bootstrap (First Launch)

Triggered automatically when `BOOTSTRAP.md` exists in the vault root, or manually with "Run bootstrap".

### Flow

1. Read `BOOTSTRAP.md` for the full setup guide.
2. Greet the user. Explain this is first-time setup and walk through each step interactively.
3. For each step, ask the user for their preference. Accept defaults if they say "skip" or "default".
   - **Step 1 - Agent name:** Ask what they want to call the agent. Default: Noa.
   - **Step 2 - Personality:** Offer the style options (direct, conversational, technical, custom). Default: direct.
   - **Step 3 - User profile:** Ask about name, role, interests, vault usage, preferences. All optional.
   - **Step 4 - Seed topics:** Ask if they want starter research. Collect topic list.
4. Summarize all choices back to the user. Ask for confirmation before applying.
5. Apply changes:
   - Write `_agent/context/USER.md` with user profile
   - Update `_agent/context/IDENTITY.md` with agent name
   - Update `_agent/context/SOUL.md` with personality style
   - Update `CLAUDE.md` to replace agent name references
   - Log setup to `_agent/log.md` as `bootstrap`
6. Delete `BOOTSTRAP.md` from the vault root.
7. If seed topics were requested, begin research using the standard Research workflow.

### Rules
- Never skip the confirmation step. Show what will change before changing it.
- If the user exits mid-bootstrap, do NOT delete `BOOTSTRAP.md` - it will trigger again next session.
- The bootstrap is conversational. One step at a time. Don't dump all questions at once.

---

## Core Commands

**"Research [topic]"** -> Read `_agent/context/knowledge-base-workflow.md`, then execute. Always update `wiki/index.md` and `log.md`.

**"What do you know about [X]?"** -> Read `_agent/wiki/index.md` first. Find the topic. Read its `_index.md` and relevant articles. Answer from KB if found. Offer to research if not.

**"Health check"** / **"Lint"** -> Run the full lint checklist from `knowledge-base-workflow.md` Step 5:
1. Contradictions between articles
2. Stale claims superseded by newer sources
3. Orphan pages with no inbound links
4. Concepts mentioned but lacking own page
5. Missing cross-references within topics
6. Topics with partial or no coverage
7. `wiki/index.md` out of sync with actual folders
8. `_index.md` article counts not matching actual files

Output report to `_agent/outputs/YYYY-MM-DD-lint-report.md`. Log to `log.md`.

**"Graduate [file]"** -> Read `_agent/context/graduation.md`, then execute.

**"Daily brief"** -> Check today's daily note + active projects, summarize status.

**"Weekly digest"** -> Summarize this week's daily notes, project changes, wiki growth. Output to `_agent/outputs/`.

**"What's in the log?"** -> Read `_agent/log.md`, summarize recent activity.

## File Creation Rules
- Every file you create MUST have `source: agent` in frontmatter
- Read `_agent/context/tagging.md` for the full schema before your first file creation in a session
- Use kebab-case filenames: `topic-name.md`
- Wiki indexes: `_agent/wiki/[topic]/_index.md`
- Outputs: `_agent/outputs/YYYY-MM-DD-description.md`
- After every wiki operation: update `_agent/wiki/index.md` and append to `_agent/log.md`
