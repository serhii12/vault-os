# Dashboard Spec

Reference for filling `assets/dashboard-template.html` and writing the result to `_agent/outputs/today.html`.

The vault's `Dashboard/` folder is reserved for markdown views with Dataview queries — those auto-update from the vault and the agent must not write there. HTML output is the agent's deliverable and lives under `_agent/`.

## Placeholder map

The template contains `{{...}}` placeholders. Replace each with HTML strings (already escaped if user-content). Lists become repeated `<li>` blocks built by you.

| Placeholder | Type | What goes here |
|---|---|---|
| `{{DATE_ISO}}` | string | `2026-05-06` |
| `{{DATE_PRETTY}}` | string | `Wednesday, May 6, 2026` |
| `{{DAY_TYPE}}` | string | One of: `Open day`, `Heavy meeting day`, `Travel day`, `Recording day`, `Solo-parenting day`, `Special event day` |
| `{{CORE_THEME}}` | string | The single phrase from Step 7 |
| `{{THEME_CONTEXT}}` | string | 1 sentence elaborating the theme |
| `{{ALERT_BANNER}}` | HTML | Either an empty string or `<div class="alert">…</div>` if hard constraints exist |
| `{{TOP_PRIORITIES_LIST}}` | HTML | `<li class="task" data-id="p1"><label>…</label><p class="ctx">…vault context…</p></li>` × 2 |
| `{{SCHEDULE_LIST}}` | HTML | `<li class="task" data-id="ev-<id>" data-start="HH:MM" data-end="HH:MM"><span class="time">09:00</span><label>Title</label><span class="loc">Location</span></li>` for every event today |
| `{{QUICK_WINS_LIST}}` | HTML | `<li class="task" data-id="qw1"><label>…</label></li>` × 5 |
| `{{OVERDUE_LIST}}` | HTML | `<li class="task overdue" data-id="ov-<id>"><label>…</label><span class="due">3 days overdue</span></li>` |
| `{{DUE_THIS_WEEK_LIST}}` | HTML | Same shape, due-date label like `Due Fri` |
| `{{FLOATING_LIST}}` | HTML | Tasks with no due date |
| `{{UPCOMING_LIST}}` | HTML | Next 2–3 days' notable events: `<li><span class="day">Thu</span> 14:00 — Meeting title</li>` |
| `{{TOTAL_ITEMS}}` | int | Count of all togglable items (priorities + schedule + quick wins + overdue + this week + floating). Used by the progress ring. |

## Data attributes

Every togglable `<li class="task">` MUST have a unique `data-id`. The template's JS uses these as localStorage keys. Use stable IDs (e.g., `ev-<calendarEventId>`, `lin-<linearIssueId>`, `qw1..qw5`) so checking persists across re-runs on the same day.

Schedule items also include `data-start` and `data-end` (24h `HH:MM`) so the template can highlight the current time block.

## Styling rules already baked into the template

- Dark theme, system fonts.
- Overdue items render in red because of the `overdue` class.
- Stats bar (schedule done / quick wins / overdue cleared / total done) computes from DOM.
- Progress ring uses `{{TOTAL_ITEMS}}` as denominator and counts `.task.done` as numerator.
- localStorage key is `today:<{{DATE_ISO}}>`.

Do NOT modify the template's `<style>` or `<script>` blocks unless adding genuinely new behavior. Only fill placeholders.

## Empty-state handling

If a list is empty, render a placeholder `<li class="empty">No items</li>` instead of leaving the section blank — keeps the grid layout consistent.

If `{{ALERT_BANNER}}` has no constraints, set it to the empty string (the template handles missing banner gracefully).
