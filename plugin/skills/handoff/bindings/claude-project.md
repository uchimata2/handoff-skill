# Binding: Claude Project docs (task index plus task records)

Use the **docs of the Claude Project** attached to a claude.ai chat as the work tracker: one central
**index** doc with a row per task, and an optional **record** doc per task. All reads and writes go
through the Projects tool (`project_info`, `project_read`, `project_write`, `project_search`). It is
the project-doc sibling of [`local-markdown-dir.md`](local-markdown-dir.md) and, like it, makes no
code or domain assumptions.

The agent stub `agents/claude-ai.SKILL.md` explains how project docs are read and written; this
binding only says where tasks live and how their status changes.

## Project config it expects

- `tracker_index` — doc path of the central index (for example `02-tasks/task-register.md`): a
  Markdown table with one row per task, holding at least the id, the title and the status.
  **Maintained by hand**, not generated.
- `tracker_dir` — doc-path prefix of the task records (for example `02-tasks/`).
- `tracker_id_prefix` — *optional*; the id prefix. Default `T-`. Match the zero-padding width of the
  existing ids.
- `tracker_template` — *optional*; doc path of the record template. If omitted, use the minimal
  shape below.
- `tracker_status_done` — *optional*; the status value that means done. Default `Done`.
- `tracker_history_section` — *optional*; the record section where updates are appended, newest
  last. Default `History`.
- `tracker_index_notes_section` — *optional*; the index section that holds history for tasks that
  have no record. Default `Notes`.

## Item format

A task is **one row in `tracker_index`** and, when it needs one, **a record doc**
`<tracker_dir><id>-<slug>.md`. A small task may exist as a row only.

- **Status has one home: the index row.** A record header may show a lifecycle phase or a short state,
  but the index row is authoritative.
- **History** goes to the record's history section; for a row-only task, to the index's notes
  section.

Minimal record shape, when no template is set:

```text
# T-014 Short title

- **Status:** In progress
- **Depends on:** n/a

## Goal
What "done" looks like.

## History
- 2026-06-24: what happened, newest last.
```

The exact fields, status values and sections are the project's convention, defined by
`tracker_template`. The binding needs only three things: where the status is (the index row and the
record header), which value means done, and where to append history.

## Operations

**find** — read `tracker_index` and match the user's reference against the id or the title. To find
the record, list the project's docs with `project_info` and match `<tracker_dir><id>-*.md`. A row
with no record is a valid item, not an error.

**read** — the index row, plus the whole record if one exists.

**create** — the next id is the highest id in the index plus one, counting every row, including
cancelled ones; never reuse a number. Add the index row. Write a record from `tracker_template` (or the
minimal shape) only when the task needs more than a row — and then in the same pass as the row.

**update** — read the doc, change it, and write the whole doc back (there is no partial update).
Append a dated one-line entry to the history home (record history section, or the index notes section
for a row-only task), newest last. Change the status in the index row; if the record header shows a
state, keep it consistent in the same pass. Done: set `tracker_status_done` with the date in the index
row; nothing moves, because there is no closed folder.

**reference** — the id plus the record's doc path, or the index path plus the id when the task has no
record.

## Keeping the tracker consistent

There is no lint hook: no code runs against project docs. Check by reading, as part of every core §3a
sweep (Create, Close, Reconcile):

- each index row and its record header agree on the **state category** only — open, blocked, done
  or cancelled. Different wording inside a category is not drift; never rewrite a detailed status to
  make two texts match;
- ids are unique, and every record has an index row;
- every finished task is marked `tracker_status_done`;
- every doc path the index or a record points to still exists (`project_info`).

## Assumptions this binding makes

Check these against the adopting project in about 30 seconds; if one is false, adapt the project
config, not this binding:

- **The index row is authoritative for status; the record is authoritative for content.** Only the
  state category is compared between them.
- Row-only tasks keep their history in the index's notes section.
- The index is **maintained**, so it is updated in the same pass as any record change; a record
  change with a stale index row is the classic silent failure.
- Done is signalled by the status **value**, not by location.
- At most one record per task; ids are unique and never reused.
- Records written before the project adopted a template may keep their own layout.
- Writes replace whole docs, so read each doc immediately before writing it, to avoid overwriting a
  newer edit from another chat.
