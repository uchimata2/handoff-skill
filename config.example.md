# Handoff config (template)

**You may not need this file.** Core §0 resolves every key by a chain — **declared** here, then
**discovered** from what your project already says, then **asked** — and records what it discovered
or asked at `.handoff/config.md` on the first run. A discovered value is written with its source,
`tracker: github-issues (discovered: AGENTS.md, 2026-08-16)`, which marks it as a cache that Check
re-derives rather than a second home for the fact.

Write this file yourself to **override** what discovery would find, or to set the two keys it never
guesses: `handoff_file` and `reconcile_targets`. The handoff core (`handoff.core.md`) reads these
keys; the active tracker binding reads the `tracker_*` keys. It's plain Markdown read by the agent —
no parser — so keep the `key: value` shape simple.

**Nothing validates this file automatically**, which is why a typo here surfaces mid-session rather
than now. When you have filled it in, ask the skill to **check** it (`handoff.core.md` §9,
`flows/check.md`): it resolves every key, confirms your binding exists and your handoff file can be
written, runs your binding's invariant hook if it declares one, and reports what it could not
resolve — at setup, instead of in the middle of a run.

## Core keys (project config)

- `handoff_file`: <path to the live handoff document, e.g. .agents/handoff/HANDOFF.md; consumed handoffs are renamed in place beside it (`processed_` / `discarded_`) and never deleted, so that directory accumulates about one file per session — decide whether they are tracked>
- `tracker`: <binding from bindings/: github-issues | notion | local-markdown | local-markdown-dir | none>
- `project_docs`: <where durable project docs live, e.g. AGENTS.md, docs/>
- `language`: <optional; language for written artifacts; omit to match the task / source>
- `reconcile_targets`: <optional; **extra** homes to sweep for staleness on Create/Close, on top of the ones the session touched — paths, globs, or named stores. Good ones are the homes that go stale **silently**: your index, your lessons / decision files, your tracker. A floor, not a ceiling — omitting it still sweeps the homes the session touched. See `handoff.core.md` §3a>

`memory` is not a project key — it's agent-specific, so each agent's stub supplies it
(`memory: <agent> | none`). See `handoff.core.md` §0.

## Tracker keys

Include only the block matching your `tracker`.

### tracker: github-issues
- `tracker_repo`: <optional; owner/name; defaults to the repo `gh` resolves from the working directory>
- `tracker_status`: <how this project stores status: state | label:<prefix> | label:<prefix>+state; default state. Pick by asking whether anything closes issues for you — see `bindings/github-issues.md` *Status is configured, not owned*>
- `tracker_status_done`: <optional; the value meaning done, for the label forms; default done>
- `tracker_status_new`: <optional; the status a new item gets; default none is set, because an unlabelled item may be a deliberate state>
- `tracker_workflow`: <optional; project doc with the conventions to follow>

### tracker: notion
- `tracker_database`: <URL or id of the Notion database / data source>
- `tracker_id_property`: <optional; property holding a human work-item id>
- `tracker_workflow`: <optional; project doc with board conventions to follow>

### tracker: local-markdown
- `tracker_file`: <path to the backlog file, e.g. BACKLOG.md>

### tracker: local-markdown-dir
- `tracker_dir`: <folder holding open task files, e.g. tasks/>
- `tracker_closed_dir`: <optional; folder done tasks move to, e.g. tasks/closed/; if unset, nothing moves on closure and done tasks stay in `tracker_dir`>
- `tracker_id_prefix`: <optional; id scheme prefix, e.g. TASK; default ITEM>
- `tracker_template`: <optional; path to a task-file template to seed new files>
- `tracker_lint`: <optional; command that validates the folder **and any central index** after a write, exiting non-zero on drift — the invariant hook. If this project keeps a central index, declare how it's produced (generated vs maintained); see `bindings/local-markdown-dir.md` *Index topology*>

### tracker: none
- (no tracker keys; every session is treated as ad-hoc — see `handoff.core.md` §7.1)
