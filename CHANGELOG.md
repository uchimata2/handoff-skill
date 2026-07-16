# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Reconcile (staleness sweep) as an explicit, backward-looking half of routing. The spine now names
  it (`handoff.core.md` §3a): §3 routes each *new* discovery **forward** to its home; §3a requires a
  **backward** pass that reconciles the durable homes the session touched — mark finished work done
  and move it, close umbrella/review items whose parts are all resolved, correct superseded
  project-doc / memory / index lines, and confirm every pointer still resolves — so a "clean" handoff
  can't ship a finished task still marked open or a memory line a newer fact made false. Create and
  Close both run the sweep before the handoff is written / the session closes (`flows/create.md`
  *Process* step 2 and Close step 1), and the pre-write checklist gained a reconciliation group
  alongside the secrets/privacy scan. A new **optional** `reconcile_targets` config key lets a project
  point at the exact homes to sweep (fallback: the homes the session touched); documented in
  `config.example.md`, `README.md`, and the §0 config table (#46).

### Changed
- Explicit `resume` no longer re-asks for confirmation: when the invocation names the mode
  **explicitly and adjacent to the handoff keyword** ("resume", "resume handoff", "handoff resume"),
  the Resume flow now prints the summary and continues straight to §6.4, skipping the
  Resume/Keep/Discard prompt (`flows/resume.md` §6.3). The prompt is retained for **inferred**
  resumes (auto-trigger, paraphrase, or an incidental "resume" not next to the keyword), where the
  user never actually asked to consume the handoff. Safe because the only pre-work state change is
  archiving the handoff by rename, which is recoverable; the spine's ambiguity default (§4) is
  unchanged (#47).
- Token-trimmed the `handoff.core.md` intro: the "consumed four ways" bulleted list is now a single
  inline sentence and the progressive-disclosure paragraph was tightened, with no change to meaning
  or structure. Ports a wording optimization already proven in a downstream install, shrinking the
  always-loaded spine by a few lines.

## [0.4.0] - 2026-07-02

A new tracker binding for projects that keep each work item as its own Markdown file in a
folder — the directory-shaped sibling of `local-markdown`.

### Added
- New tracker binding `bindings/local-markdown-dir.md` — a **folder of one-file-per-task**
  Markdown files with YAML frontmatter, where "open" vs "done" is signalled by folder location
  (e.g. `tasks/` vs `tasks/closed/`). The directory-shaped sibling of `local-markdown`, for
  projects that keep each work item as its own document rather than sections of one backlog file.
  Zero dependencies; makes no code/domain assumptions. Reads generic `tracker_*` keys
  (`tracker_dir`, optional `tracker_closed_dir`, `tracker_id_prefix`, `tracker_template`,
  `tracker_lint`). Enumerated everywhere the bindings are listed (`config.example.md`,
  `bindings/README.md`, the bug-report template) and given an `EXAMPLES.md` §4 walkthrough.

## [0.3.0] - 2026-06-22

Progressive-disclosure core split (an always-loaded spine plus on-demand flow files), two new
modes — **Status** and **Close** — optional Claude Code hook reminders, and release tooling
(a CI portability + link guard, a single-sourced package manifest, and doc-consistency polish).

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
- README now links the GitHub wiki (a new "Learn more" section) and the `CODE_OF_CONDUCT.md`
  (README "Roadmap" + the CONTRIBUTING intro), so both are discoverable from tracked docs
  (#34, #35).
- CI: a `checks` GitHub Actions workflow runs on every push and PR and guards two invariants —
  a **portability guard** that fails if the always-loaded core (`handoff.core.md` + `flows/`)
  contains a denylisted project/tracker/agent token, and an **offline Markdown link check** that
  fails on unresolved internal links (`.github/workflows/checks.yml`) (#10).

### Changed
- Split the monolithic core for **progressive disclosure**: `handoff.core.md` is now the
  always-loaded **spine** (§0 config, §1–§3 routing model, §4 detection, §7 session types, §8
  binding contract), and each consumption flow moved to an on-demand file — `flows/create.md`
  (§5 Create + Close) and `flows/resume.md` (§6 Resume + §6.5 Status). §4 directs each run to
  load the spine plus one flow, never both; the routing model stays single-sourced in the spine
  and the flows reference it. Sections keep their numbers and anchors (relocate, don't renumber).
  The agent stubs, `README.md`, `CONTRIBUTING.md`, and `scripts/build-skill.ps1` were updated to
  bundle and point at the flow files (#20).
- Single-sourced the package manifest: the `$items` array in `scripts/build-skill.ps1` is now the
  canonical list of files that ship in `handoff.skill`. The README and CONTRIBUTING "What's in
  here" sections describe the package but point to that manifest instead of keeping their own file
  lists that could drift (#19).
- Trimmed the always-loaded spine: the §3 *Worked examples* block moved out of `handoff.core.md`
  into `EXAMPLES.md` (new §8 *Routing a single discovery*); the spine §3 keeps a one-line pointer.
  Routing rules unchanged — illustrative content only. Spine: 281 → 261 lines (#36).
- Doc polish after the v0.3.0 split: the "core stays generic" rule (PR template + CONTRIBUTING,
  including its grep check) now explicitly covers the `flows/` files alongside the `handoff.core.md`
  spine, and the dense Claude Code install bullet in the README was broken into scannable
  sub-bullets (#35).

### Fixed
- Issue templates now reflect the v0.3.0 spine + `flows/` split: the feature-request "which part it
  affects" prompt and the bug-report "where" example treated the core as the single `handoff.core.md`
  file, so they now name the spine **and** the flow files (Create / Resume / Status / Close).
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

[Unreleased]: https://github.com/uchimata2/handoff-skill/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/uchimata2/handoff-skill/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/uchimata2/handoff-skill/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/uchimata2/handoff-skill/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/uchimata2/handoff-skill/releases/tag/v0.1.0
