# Binding: Notion

Use a Notion database (data source) as the work tracker. Implements the binding
contract (`../handoff.core.md` §8) through the Notion MCP server.

## Project config it expects

- `tracker_database` — URL or id of the Notion database / data source that holds work items.
- `tracker_id_property` — *(optional)* the property carrying a human work-item id (e.g. an
  auto-increment ticket id). If absent, items are matched by title / URL only.
- `tracker_workflow` — *(optional)* a project doc describing board conventions (statuses,
  how plans attach, comment etiquette) to follow when reading and writing items.

## Operations

**find** — from the user's reference:

- a Notion URL or page id → use it directly;
- a human id (e.g. `ABC-123`) → `search` the workspace for that exact string, then
  `fetch` the top results and confirm `tracker_id_property` matches — resolve by that
  property, not the title (titles rarely contain the id);
- a title or phrase → `search`, and confirm with the user if ambiguous.

**read** — `fetch` the page: properties (status, assignee, dates), the full description,
child pages (specs / plans), and comments. Follow `tracker_workflow` if set.

**create** — create a page under `tracker_database` (data-source parent). Set the title
and required properties; never set an auto-increment id — Notion assigns it. Put the body
in the page content, then re-`fetch` to read the assigned id for the reference.

**update** — write back: change properties (status, …), append or replace content, or add
a comment for a milestone. Attach a plan as a child page when the workflow calls for it.

**reference** — the page URL (stable), plus the human id from `tracker_id_property` if present.

## Notes

- This binding is generic. Project-specific board conventions (id scheme, statuses,
  plan-attachment rules) belong in `tracker_workflow`, not here — that keeps the binding
  reusable across Notion-based projects.

## Assumptions this binding makes

Check these against the adopting project in ~30 seconds; if one is false, adapt via the project
config (or `tracker_workflow`), not this binding:

- The **Notion database** (`tracker_database`) is the authoritative store; the repo keeps no copy
  of task content — references are page URLs, so resuming needs Notion access.
- **Board conventions** (statuses, id scheme, plan attachment, comment etiquette) live in
  `tracker_workflow`, not the binding.
- **Notion assigns ids.** When the database has an auto-increment id property (named by
  `tracker_id_property`), never set it — read the assigned id back for the reference. Without such a
  property, items are matched by title / URL only.
- Access is via the **Notion MCP server** (a live service + auth) — unlike the zero-dependency
  file bindings, availability and permissions can affect find/read/create/update.
