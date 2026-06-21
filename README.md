# Handoff skill — portable package

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Latest release](https://img.shields.io/github/v/release/uchimata2/handoff-skill?sort=semver)](https://github.com/uchimata2/handoff-skill/releases)

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
- `EXAMPLES.md` — annotated good-vs-bad handoffs and walkthroughs by session type.
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

## Build an installable artifact (optional)

The package is plain Markdown and needs no build to use — just copy it per the steps above.
For distribution you can bundle it into a single `handoff.skill` archive:

```sh
pwsh scripts/build-skill.ps1
```

This writes `dist/handoff.skill` — a zip of the package under a top-level `handoff/` folder.
Unzip it into your project and follow the install steps above. The artifact is regenerated on
demand and is git-ignored. See [CHANGELOG](CHANGELOG.md) for release history.

## How it works (one paragraph)

The core sorts every piece of session information into one of four stores — handoff file,
task docs, project docs, agent memory — using a short routing procedure (core §2–§3). The
handoff file holds only a pointer to what to resume plus pure session-ephemeral state;
everything durable goes to its real home. Trackers are reached through a binding; memory
is whatever your agent supplies (or none).

## The routing model (visual)

Every piece of session information runs through the routing procedure (core §3). A single
discovery can split into several facets — each is written to its own home — while the handoff
keeps only a pointer plus pure ephemeral state:

```mermaid
flowchart TD
  start(["Each piece of session info"]) --> q1{"Secret / sensitive?"}
  q1 -- yes --> drop["Redact — store nowhere"]
  q1 -- no --> q2{"Task-specific facet?"}
  q2 -- yes --> td[("Task docs<br/>via tracker binding")]
  q2 -- no --> q3{"Generic / reusable facet?"}
  td --> q3
  q3 -- "project-scoped & shareable" --> pd[("Project docs")]
  q3 -- "cross-project / private" --> mem[("Agent memory<br/>else project docs")]
  q3 -- no --> q4{"Pure ephemeral,<br/>recorded nowhere else?"}
  pd --> q4
  mem --> q4
  q4 -- yes --> ho[["Handoff file"]]
  q4 -- no --> pt["Already has a home —<br/>handoff only points to it"]
```

The two flows that consume this model — **Create** (§5) and **Resume** (§6):

```mermaid
flowchart LR
  subgraph Create
    direction TB
    c1["Route every discovery<br/>through §3 to its home"] --> c2["Write handoff:<br/>pointer + ephemeral state only"]
  end
  subgraph Resume
    direction TB
    r1["Read handoff"] --> r2["Summarize and confirm"] --> r3["Open the pointed-to homes"] --> r4["Archive handoff, then continue"]
  end
```

See [`EXAMPLES.md`](EXAMPLES.md) for annotated good-vs-bad handoffs that put this into practice.

## Degrades gracefully

- **No tracker** (`tracker: none`): every session is treated as ad-hoc — the skill offers
  to create a tracked item, or captures specifics in the handoff snapshot (core §7.1).
- **No memory** (`memory: none`): memory-bound items fall back to project docs; nothing is
  silently lost.

## License

[MIT](LICENSE) © 2026 uchimata2
