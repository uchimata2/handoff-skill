# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `EXAMPLES.md` — annotated good-vs-bad handoffs, a filled-in config, and walkthroughs by
  session type (#1).
- README: Mermaid diagrams of the four-store routing procedure and the create/resume flows,
  plus a link to `EXAMPLES.md` (#2).
- CONTRIBUTING: a "Working the backlog" guide (issues, specify-before-build, labels).
- Project board automation: a GitHub Projects kanban auto-synced from issue `status:` labels
  (`.github/workflows/sync-status-to-project.yml`), documented in `PROJECT_BOARD.md` and linked
  from `README.md` / `CONTRIBUTING.md`.

### Added
- Concrete secret-redaction method in the core (`handoff.core.md` §3, *Redacting secrets*):
  omit the value, reference by location/name, use placeholders not partial values, and store it
  nowhere. `SECURITY.md` cross-references it (#7).

### Changed
- Handoff exclusion rule broadened from secrets-only to a single consolidated gate covering
  secrets, user-/machine-private data, and copied local-memory contents; the shipped core now
  carries a pre-write / commit checklist (`handoff.core.md` §3 step 1, §5). `SECURITY.md`
  references it instead of holding a separate copy (#5).

## [0.1.0] - 2026-06-21

Initial public release of the portable Handoff skill.

### Added
- `handoff.core.md` — the project- and agent-neutral workflow (four stores, routing matrix
  and procedure, detection, create/resume flows, session types, binding contract).
- `config.example.md` — the per-project config schema.
- `bindings/` — tracker bindings for `notion` and `local-markdown`, plus a guide for writing
  your own (`bindings/README.md`).
- `agents/` — per-agent stub templates (`claude.SKILL.md`, `copilot.agent.md`).
- `scripts/build-skill.ps1` — bundles the package into a distributable `handoff.skill` archive
  (cross-platform PowerShell; not required to use the skill).
- Project docs and collaboration scaffolding: `README.md`, `CONTRIBUTING.md`,
  `CODE_OF_CONDUCT.md`, `SECURITY.md`, an MIT `LICENSE`, a `CHANGELOG.md`, issue templates
  (bug, feature, new tracker binding or agent) and a pull-request template under `.github/`.

[Unreleased]: https://github.com/uchimata2/handoff-skill/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/uchimata2/handoff-skill/releases/tag/v0.1.0
