# Handoff skill — portable package

A drop-in **handoff** skill: it lets any AI working session — a later session, another
agent, or another person — pick up work seamlessly, while keeping a strict single source
of truth. Every fact has exactly one home, and the handoff only *points* to those homes.
It works in any project (development or not), with or without an external task tracker,
and across agents.

## What's in here

- `handoff.core.md` — the agent- and project-neutral workflow (the authoritative body).
- `config.example.md` — the per-project config schema.
- `bindings/` — tracker bindings (`notion`, `local-markdown`) + how to write your own.
- `agents/` — per-agent stub templates (`claude.SKILL.md`, `copilot.agent.md`).
- `README.md` — this file.

Nothing here is project-specific; all specifics live in the config you create.

## Install in a new project

1. **Copy the package.** Drop this folder into the new repo (e.g. at
   `.agents/handoff-skill/`).
2. **Create a config.** Copy `config.example.md` to a project location (e.g.
   `.agents/handoff/config.md`) and fill in `handoff_file`, `tracker`, `project_docs`,
   and `language`.
3. **Choose a tracker.** Set `tracker` to a binding in `bindings/` and fill its
   `tracker_*` keys — or `tracker: none`. Need a different tracker? See
   `bindings/README.md`.
4. **Wire your agent.** Copy the matching template from `agents/` into your agent's native
   location and replace `{{package}}` (this folder's path) and `{{config}}` (your config
   path):
   - **Claude Code** → `.claude/skills/handoff/SKILL.md`. Also add two command pointers:
     - `.claude/skills/handoff/commands/create.md` → "Follow §5 (Create) of
       `{{package}}/handoff.core.md`, using config `{{config}}`."
     - `.claude/skills/handoff/commands/resume.md` → "Follow §6 (Resume) of
       `{{package}}/handoff.core.md`, using config `{{config}}`."
   - **GitHub Copilot CLI** → `.github/agents/handoff.agent.md`.
   - **Another agent** → copy the closest template, point it at the core + config, and set
     its `memory` value (its store, or `none`).
5. **Done.** Trigger it by saying "handoff", "resume", "hand off", etc. (see core §4).

## How it works (one paragraph)

The core sorts every piece of session information into one of four stores — handoff file,
task docs, project docs, agent memory — using a short routing procedure (core §2–§3). The
handoff file holds only a pointer to what to resume plus pure session-ephemeral state;
everything durable goes to its real home. Trackers are reached through a binding; memory
is whatever your agent supplies (or none).

## Degrades gracefully

- **No tracker** (`tracker: none`): every session is treated as ad-hoc — the skill offers
  to create a tracked item, or captures specifics in the handoff snapshot (core §7.1).
- **No memory** (`memory: none`): memory-bound items fall back to project docs; nothing is
  silently lost.

## License

[MIT](LICENSE) © 2026 uchimata2
