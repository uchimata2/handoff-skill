# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `CHANGELOG.md`.
- Issue templates (bug report, feature/improvement, new tracker binding or agent) and a
  pull-request template under `.github/`.
- `scripts/build-skill.ps1` — bundles the package into a distributable `handoff.skill`
  archive (cross-platform PowerShell; not required to use the skill).

## [0.1.0] - 2026-06-21

Initial public release of the portable Handoff skill package.

### Added
- `handoff.core.md` — the project- and agent-neutral workflow (four stores, routing
  matrix and procedure, detection, create/resume flows, session types, binding contract).
- `config.example.md` — the per-project config schema.
- `bindings/` — tracker bindings for `notion` and `local-markdown`, plus a guide for
  writing your own (`bindings/README.md`).
- `agents/` — per-agent stub templates (`claude.SKILL.md`, `copilot.agent.md`).
- `README.md`, `CONTRIBUTING.md`, and an MIT `LICENSE`.

[Unreleased]: https://github.com/uchimata2/handoff-skill/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/uchimata2/handoff-skill/releases/tag/v0.1.0
