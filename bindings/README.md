# Tracker bindings

A **binding** teaches the handoff core how to use one work tracker. The core stays
tracker-agnostic; each file here implements the **binding contract** (see
`../handoff.core.md` §8) for a specific tracker. The active binding is chosen by the
`tracker` key in the project config.

## Available bindings

- `notion.md` — a Notion database / data source as the tracker.
- `local-markdown.md` — a plain Markdown backlog file in the repo (zero dependencies).
- `local-markdown-dir.md` — a folder of one-file-per-task Markdown files with frontmatter, "open"
  vs "done" signalled by folder location (zero dependencies).

## The contract (summary)

Every binding defines five operations: **find**, **read**, **create**, **update**,
**reference**. See `../handoff.core.md` §8 for what each one means. Don't restate the
contract here — just implement the operations for your tracker.

## Writing a new binding

1. Copy the closest existing binding (`notion.md` for an API / SaaS tracker,
   `local-markdown.md` for a file-based one).
2. Fill in each operation using whatever that tracker exposes — an MCP server, a CLI,
   an HTTP API, or plain file edits.
3. Call out any project-specific values (which database, which id scheme, which file) as
   things the project **config** supplies — keep the binding itself reusable.
4. Set `tracker: <your-binding>` in the project config.
