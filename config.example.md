# Handoff config (template)

Copy this file to your project's config location and fill it in. The handoff core
(`handoff.core.md`) reads these keys; the active tracker binding reads the `tracker_*`
keys. It's plain Markdown read by the agent — no parser — so keep the `key: value` shape
simple.

## Core keys (project config)

- `handoff_file`: <path to the live handoff document, e.g. .agents/handoff/HANDOFF.md>
- `tracker`: <binding from bindings/: notion | local-markdown | none>
- `project_docs`: <where durable project docs live, e.g. AGENTS.md, docs/>
- `language`: <optional; language for written artifacts; omit to match the task / source>

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

### tracker: none
- (no tracker keys; every session is treated as ad-hoc — see `handoff.core.md` §7.1)
