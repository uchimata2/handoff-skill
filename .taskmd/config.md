---
# ---------------------------------------------------------------- identity
id_field: id               # the GitHub issue number; assigned by GitHub, never chosen
id_prefix: '#'             # ids read as #41 — see "The id prefix" below before editing
id_width: 1                # issue numbers are not zero-padded
title_field: title         # the issue title
tasks_dir: tasks           # UNUSED on this binding — see "The tasks folder" below

# ------------------------------------------------------------------ status
status_field: status
open_statuses: [backlog, needs spec, ready, in progress]
blocked_status: none       # this project has no "held up" status value

# ------------------------------------------------------------- deliverables
deliverables_field: none   # outputs are not tracked per task here

# ---------------------------------------------------------------- ordering
value_field: priority      # the repo's existing `priority:` labels
effort_field: none         # not estimated on this project

# ------------------------------------------------------------------- hooks
after_write: none          # nothing to regenerate — the issue list is the index

# ------------------------------------------------------------------- views
context_fields: [status, priority]
index_columns: [status, priority]
---

# taskmd schema — uchimata2/handoff-skill

Binding: **`docs/bindings/github-issues.md`**. One task per GitHub issue in this repository.
The adoption record, including every place this project knowingly departs from that binding, is
[`ADOPTION.md`](ADOPTION.md) — read it before writing to a task.

Everything here replaces the default schema wholesale; a config does not merge with the default,
so every key is written even where the value matches.

## The tasks folder

`tasks_dir` is unused: this project's tasks are issues, and there is no folder. The key is still
required to be written, so it carries the default value and means nothing here.

The consequence is worth stating plainly rather than discovering: **the `taskmd` CLI does not run
on this project.** `taskmd check` would fail on a `tasks_dir` that does not exist, and every other
command is the local-Markdown backend. The operations for this project are the `gh` instructions in
the binding, followed by an agent. Nothing validates this file automatically.

## The id prefix

`id_prefix: '#'` is quoted for a reason. The config format strips ` #` and everything after it as a
comment, so an unquoted `#` here would parse as an empty value rather than as the prefix. Nothing in
this project parses the file — see above — so the quoting is for a reader and for whatever reads it
next. Reported as a finding in [`ADOPTION.md`](ADOPTION.md).

## Vocabularies

Two fields are enumerated, and both are carried by labels **that already exist in this repository**,
so adopting taskmd did not introduce a parallel taxonomy. `phase`, `type` and `effort` are
deliberately not enumerated: this repo's lifecycle is already carried by `status`, and its
`core` / `binding` / `examples` / `visual` / `agent-support` labels already classify issues without
a `<field>:<value>` shape. An unenumerated field is still recorded — it goes to the property block
at the top of the issue body — it is simply not validated as a vocabulary.

| Field | Values |
| :--- | :--- |
| status | backlog, needs spec, ready, in progress, done, cancelled |
| priority | critical, high, normal, low |

`backlog` is the one value with **no label**: on this repo an issue carrying no `status:` label is
deliberately off the board ([`../PROJECT_BOARD.md`](../PROJECT_BOARD.md)), and that absence is what
`backlog` names. Writing a task to `backlog` means removing its `status:` label, not adding one.
This is a departure from the binding's mapping rule 2 and is recorded as such in
[`ADOPTION.md`](ADOPTION.md).

## Edges

Standard. GitHub carries the first two natively — sub-issues and issue dependencies — and `related`
lives in the property block, which is the one thing this binding absorbs.

| Kind | Shape | Inverse |
| :--- | :--- | :--- |
| `hierarchy` | at most one value | derived, a list, under the name in `Derives` |
| `dependency` | a list | derived, a list, under the name in `Derives` |
| `soft` | a list | derived **symmetrically**, under its own name — write `-` |

| Field | Kind | Derives |
| :--- | :--- | :--- |
| parent | hierarchy | children |
| blocked_by | dependency | blocks |
| related | soft | - |

## Ordering

`priority` orders the work, best first, in the vocabulary order above. Effort is not estimated here,
so a task sorts on blocked-last, then priority, then id.
