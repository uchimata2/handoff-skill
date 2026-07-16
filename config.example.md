# Handoff config (template)

Copy this file to your project's config location and fill it in. The handoff core
(`handoff.core.md`) reads these keys; the active tracker binding reads the `tracker_*`
keys. It's plain Markdown read by the agent — no parser — so keep the `key: value` shape
simple.

## Core keys (project config)

- `handoff_file`: <path to the live handoff document, e.g. .agents/handoff/HANDOFF.md>
- `tracker`: <binding from bindings/: notion | local-markdown | local-markdown-dir | none>
- `project_docs`: <where durable project docs live, e.g. AGENTS.md, docs/>
- `language`: <optional; language for written artifacts; omit to match the task / source>
- `reconcile_targets`: <optional; homes to sweep for staleness on Create/Close — paths, globs, or named stores like the tracker open dir, memory files, index docs; omit to sweep the homes the session touched. See `handoff.core.md` §3a>

`memory` is not a project key — it's agent-specific, so each agent's stub supplies it
(`memory: <agent> | none`). See `handoff.core.md` §0.

## Tracker keys

Include only the block matching your `tracker`.

### tracker: notion
- `tracker_database`: <URL or id of the Notion database / data source>
- `tracker_id_property`: <optional; property holding a human work-item id>
- `tracker_workflow`: <optional; project doc with board conventions to follow>

### tracker: local-markdown
- `tracker_file`: <path to the backlog file, e.g. BACKLOG.md>

### tracker: local-markdown-dir
- `tracker_dir`: <folder holding open task files, e.g. tasks/>
- `tracker_closed_dir`: <optional; folder done tasks move to, e.g. tasks/closed/>
- `tracker_id_prefix`: <optional; id scheme prefix, e.g. TASK; default ITEM>
- `tracker_template`: <optional; path to a task-file template to seed new files>
- `tracker_lint`: <optional; command to validate the folder after a write>

### tracker: none
- (no tracker keys; every session is treated as ad-hoc — see `handoff.core.md` §7.1)
