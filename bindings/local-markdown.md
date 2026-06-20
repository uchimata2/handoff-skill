# Binding: Local Markdown backlog

Use a plain Markdown file in the repository as the work tracker. Zero dependencies — just
file reads and edits. Good for projects with no external tracker, and for non-development
work (research, writing, ops).

## Project config it expects

- `tracker_file` — path to the backlog file (e.g. `BACKLOG.md`). Created on first use.

## Item format

One work item per level-2 heading. Keep it simple:

```text
## [ITEM-3] Short title
- status: in-progress
- created: 2026-06-20

<description, plan, decisions, results — everything needed to work this item>
```

Ids are `ITEM-<n>`, `<n>` incrementing from the highest existing id (start at 1).

## Operations

**find** — open `tracker_file`; match the heading by id (`[ITEM-n]`) or by title text.

**read** — return the matched item's whole section (from its heading to the next `## `).

**create** — append a new `## [ITEM-<next>] <title>` section with `status` and `created`
lines and the body. Create `tracker_file` if it doesn't exist.

**update** — edit the item's section in place: change the `status` line, or append
decisions / results / notes under it. Leave other items untouched.

**reference** — the item id (`ITEM-<n>`) plus a relative link to `tracker_file` (a heading
anchor if your renderer supports it).

## Notes

- No code or domain assumptions — equally fine for research notes, writing tasks, or ops.
- Statuses are free text; a small set such as `backlog / in-progress / done` is plenty.
