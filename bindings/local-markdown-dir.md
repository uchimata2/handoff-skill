# Binding: Local Markdown task folder (one file per task)

Use a **folder of Markdown files — one file per work item** — as the work tracker, instead
of a single backlog file. Zero dependencies: just file reads, edits, and moves. Good for
projects that keep each task as its own document (frontmatter + body) and signal "open" vs
"done" by which folder the file lives in. Like [`local-markdown.md`](local-markdown.md) it
makes no code or domain assumptions — equally fine for research, writing, or ops.

If your backlog is a single file of `## [ITEM-n]` sections, use
[`local-markdown.md`](local-markdown.md) instead — this binding is its directory-shaped sibling.

## Project config it expects

- `tracker_dir` — folder holding the **open** task files (e.g. `tasks/`). Created on first use.
- `tracker_closed_dir` — *optional*; folder that **done** tasks are moved to (e.g.
  `tasks/closed/`). If omitted, "done" is recorded by the status field alone and files stay put.
- `tracker_id_prefix` — *optional*; the id scheme prefix (e.g. `TASK`). Default `ITEM`.
- `tracker_template` — *optional*; path to a task-file template used to seed new files
  (frontmatter + section skeleton). If omitted, use the minimal shape below.
- `tracker_lint` — *optional*; a command that validates the folder **and any central index** after a
  write and exits non-zero on drift. Run it after create/update and resolve what it reports before
  finishing. This is the binding's invariant-enforcement hook — see *Keeping the tracker consistent*.

## Item format

One task per file, named `<id>-<slug>.md`, with **YAML frontmatter** and a body:

```text
---
id: TASK-014
title: Short title
status: in-progress        # the project's status vocabulary (e.g. backlog · in-progress · blocked · done)
updated: 2026-06-24        # YYYY-MM-DD
---

## Goal
What "done" looks like.

## Plan
- [ ] step / phase

## Log
- 2026-06-24 — what happened, newest last.
```

Ids are `<prefix><n>` (`<prefix>` from `tracker_id_prefix`, default `ITEM`), `<n>` incrementing
from the highest existing id across **both** the open and closed folders — never reuse a number.
Match the zero-padding width of the existing ids.

The **exact** frontmatter fields, their allowed values, and the body sections are the project's
convention — defined by `tracker_template` and any `tracker_lint` script, not by this binding.
The binding only needs to know two things: which `status` value means **done** (to trigger the
move) and where the log section is (to append). Everything else it carries through unchanged.

## Operations

**find** — resolve the user's reference (id, title, or filename) to a file: look in `tracker_dir`
first, then `tracker_closed_dir` (if set). Match on the id prefix of the filename (`<id>-*.md`)
or on title / slug text.

**read** — return the matched file whole (frontmatter + body).

**create** — pick the next id (highest existing `<prefix><n>` across open **and** closed, +1).
Write `<tracker_dir>/<id>-<slug>.md` from `tracker_template` if set (else the minimal shape
above), filling `id`, `title`, an initial `status`, and `updated` (today). Create `tracker_dir`
if missing. If `tracker_lint` is set, run it and fix any error.

**update** — edit the file in place: change frontmatter fields (`status`, `updated`, …) and
append decisions / results / notes to the log section, newest last; leave unrelated content
intact. **When the item reaches the done status:** set the status field **and**, if
`tracker_closed_dir` is set, **move the file there** — the folder is part of the status signal,
so a done file left in the open folder is inconsistent (a linter will usually flag it). If
`tracker_lint` is set, run it after writing. If the project declares a **central index** (see
*Index topology*), update it in the **same** write — regenerate it if it is generated, edit it in
place if it is maintained — so the index never lags the files.

**reference** — the item id (`<id>`) plus a repo-relative link to its file (in the open or
closed folder), so anyone who pulls the repo can open it. Add a heading anchor if useful.

## Index topology

Projects use this binding in one of two shapes. **Know which one the adopting project is** before
you write, because "done" means different work in each:

- **(a) Folder-as-index** — there is *no* central list. The set of files, and each file's `status`,
  are the single source of truth; a status change is one edit (plus a folder move when done).
- **(b) A central index exists** — a task list / board / dashboard built from the files. That index
  is a **durable home too**, so it must stay consistent with the files:
  - if it is **generated** (built by a script from the files), never hand-edit it — **regenerate**
    it after any write;
  - if it is **maintained** (edited by hand), update it in the **same pass** as the status change.

  Following this binding literally *without* accounting for a central index is the classic silent
  failure: the file is correct, the index is stale, and nothing complains. If a central index
  exists, the project config should say so — how it is produced (generated vs maintained) — and
  point `tracker_lint` at a check.

## Keeping the tracker consistent

`tracker_lint` is the enforcement hook: a command that fails when the folder or the index has
drifted, run after every create/update. It gives core **§3a reconcile** a concrete check for the
stale index a handoff would otherwise leave behind. A check typically verifies, and exits non-zero
on any mismatch:

- every file's `status` is in the project's allowed vocabulary;
- every **done** file lives in `tracker_closed_dir` (and no open file does);
- ids are unique across open + closed;
- **the central index (if any) matches the files** — same ids, same statuses.

```text
# in project config
- `tracker_lint`: scripts/check-tasks --strict      # exits non-zero on any drift above
```

If the check has no "fix" mode, treat a non-zero exit as work to finish by hand before the write is
done — don't leave it failing.

## Notes

- Status vocabulary is the project's own; a small set such as `backlog / in-progress / blocked /
  done` is plenty. The binding stays agnostic to the specific values.
- Keep a task template (`tracker_template`) out of `tracker_dir` itself, or it will look like a
  task; a common home is a sibling `_TEMPLATE.md` one level up. A `_templates/` subfolder is also
  fine as long as its files don't match the `<id>-*.md` pattern **find** scans for.

## Assumptions this binding makes

Check these against the adopting project in ~30 seconds; if one is false, the project config (not
this binding) is where you adapt:

- The **file set** is authoritative — *unless* the project declares a central index (see *Index
  topology*), in which case the index is a durable home that must be kept in sync.
- **Folder location is part of the status signal**: an item's open/done state is read from which
  folder holds it (when `tracker_closed_dir` is set), not from the `status` field alone.
- **One file per work item**, named `<id>-<slug>.md`; ids are unique across the open and closed
  folders and never reused.
- The binding owns only *where* things live and *when* a file moves; the frontmatter fields, status
  vocabulary, and body sections are the project's own (via `tracker_template` / `tracker_lint`).
