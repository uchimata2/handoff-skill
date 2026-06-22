# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Status mode — a read-only "what's in the current handoff?" preview alongside Create and
  Resume. It finds and summarizes the handoff (title + short summary + the pointers it
  references) and stops: no archive, no routing, no tracker interaction. Added core §6.5,
  status triggers and the resume-vs-status disambiguation (non-mutating default) to §4, an
  `EXAMPLES.md` walkthrough, and an optional `handoff-status` split skill in the Claude stub
  and README (#9).
- Close mode — wrap up a session cleanly **without** leaving a handoff. Close does all of
  Create's durable-homes routing (§3) but writes no handoff file; if a live handoff exists it
  is archived (`processed_<timestamp>`) so no resume pointer remains. Added a `### Close`
  subsection under core §5, close triggers and the create-vs-close disambiguation to §4, the
  ad-hoc edge (declined specifics have no fallback — surfaced, not dropped silently), an
  `EXAMPLES.md` walkthrough, and an optional `handoff-close` split skill (#12).
- Optional Claude Code hook reminders — a new `agents/claude.hooks.md` documents soft, opt-in,
  non-mutating wiring for `SessionStart` (nudge to resume/preview when a handoff is waiting) and
  `PreCompact` (nudge to handoff/close before a compaction, via a non-blocking `systemMessage`).
  Cross-platform examples (PowerShell + POSIX `sh`); the core stays agent-neutral, and the Claude
  stub and README §4 carry only a one-line pointer (#11).
- CONTRIBUTING: a "Merging dependent or stacked PRs" guide — prefer sequential PRs, merge stacks
  bottom-up one at a time and let the base retarget, and verify the default branch actually
  contains every PR (and that linked issues auto-closed) before treating them as shipped. Pairs
  with enabling the repo's "Automatically delete head branches" so stacks retarget correctly (#33).

### Changed
- Split the monolithic core for **progressive disclosure**: `handoff.core.md` is now the
  always-loaded **spine** (§0 config, §1–§3 routing model, §4 detection, §7 session types, §8
  binding contract), and each consumption flow moved to an on-demand file — `flows/create.md`
  (§5 Create + Close) and `flows/resume.md` (§6 Resume + §6.5 Status). §4 directs each run to
  load the spine plus one flow, never both; the routing model stays single-sourced in the spine
  and the flows reference it. Sections keep their numbers and anchors (relocate, don't renumber).
  The agent stubs, `README.md`, `CONTRIBUTING.md`, and `scripts/build-skill.ps1` were updated to
  bundle and point at the flow files (#20).

### Fixed
- Reference/inventory hygiene after the #20 core split: repointed the pre-write / commit checklist
  citations in `SECURITY.md` and the core §3 *Redacting secrets* pointer to `flows/create.md` §5
  (they still read as `handoff.core.md` §5, but §5 now lives in the Create flow); listed
  `agents/claude.hooks.md` in the README "What's in here"; and refreshed the README routing-model
  section (prose + second diagram) to reflect all four modes — Create, Resume, Status, Close —
  instead of only Create/Resume (#32).
- Agent stub templates no longer carry a bare `../README.md` link that dangles once the stub is
  copied to its install location (`.claude/skills/handoff/SKILL.md` /
  `.github/agents/handoff.agent.md`). The reference now goes through the existing `{{package}}`
  substitution (`{{package}}/README.md`), consistent with the templates' other links, so it
  resolves to the real package README after install (#25).

## [0.2.0] - 2026-06-21

Portability & security hardening, plus docs and packaging polish.

### Added
- `EXAMPLES.md` — annotated good-vs-bad handoffs, a filled-in config, and walkthroughs by
  session type (#1).
- README: Mermaid diagrams of the four-store routing procedure and the create/resume flows,
  plus a link to `EXAMPLES.md` (#2).
- CONTRIBUTING: a "Working the backlog" guide (issues, specify-before-build, labels).
- Project board automation: a GitHub Projects kanban auto-synced from issue `status:` labels
  (`.github/workflows/sync-status-to-project.yml`), documented in `PROJECT_BOARD.md` and linked
  from `README.md` / `CONTRIBUTING.md`.
- Concrete secret-redaction method in the core (`handoff.core.md` §3, *Redacting secrets*):
  omit the value, reference by location/name, use placeholders not partial values, and store it
  nowhere. `SECURITY.md` cross-references it (#7).

### Changed
- Handoff exclusion rule broadened from secrets-only to a single consolidated gate covering
  secrets, user-/machine-private data, and copied local-memory contents; the shipped core now
  carries a pre-write / commit checklist (`handoff.core.md` §3 step 1, §5). `SECURITY.md`
  references it instead of holding a separate copy (#5).
- Handoff references must now resolve to commonly accessible homes (tracker / work item, repo
  files, public URLs) and must never point at or depend on agent-private memory; added a
  *Portable references* principle and qualified the §3 routing so resuming never requires local
  memory (`handoff.core.md` §2, §3, §5) (#4).
- Workflow / how-to knowledge owned by another skill or doc must be referenced, not restated:
  broadened §2 OUT, added a *Reference, don't restate* principle and a worked example
  (`handoff.core.md` §2–§3), with a matching good-vs-bad example in `EXAMPLES.md` (#6).
- Tidied §2 Handoff-file *OUT* into a de-duplicated sub-list that points to the §3 step-1
  exclusion gate instead of restating its categories (`handoff.core.md` §2).

### Fixed
- Claude Code install instructions: the documented `.claude/skills/handoff/commands/*.md`
  pointers never registered as `/handoff:create` / `/handoff:resume` (a skill's subfolder holds
  on-demand supporting files, not slash commands). Documented the working setup — the single
  `handoff` skill plus the core's §4 detection — and the correct optional path (separate
  `handoff-create` / `handoff-resume` skills) (#21).
- The built `handoff.skill` artifact now bundles `EXAMPLES.md`, which the packaged README
  links to but the build script previously omitted; listed it in the CONTRIBUTING package
  manifest too.
- README routing diagram now matches the broadened gate — "Secret / sensitive / user-private?"
  and "Exclude — store nowhere" (was the pre-#5 "Secret / sensitive?" / "Redact").

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

[Unreleased]: https://github.com/uchimata2/handoff-skill/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/uchimata2/handoff-skill/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/uchimata2/handoff-skill/releases/tag/v0.1.0
