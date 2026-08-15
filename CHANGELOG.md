# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **The install steps now name the two other shapes people actually use.** `README.md` documented
  exactly one install — a copy of the package per project, one config, one stub — so both variations
  were reachable only by working them out for yourself, and one of them only by hand-editing the
  installed stub. A new *Other install shapes* section covers **one install serving several
  projects**, where a shared stub has no single `{{config}}` and the config must instead be
  *discovered* (project-local first, a user-level config next, then core §0's ask), and **a directory
  link instead of a copy**, which is how you work on the package without a copy going quietly stale.
  Each shape says which of steps 1–6 it replaces, so the default stays one procedure rather than
  becoming a fork. `agents/claude.SKILL.md` carries the discovery sentence verbatim, which is what
  turns a shared stub from a private hand-edit — re-applied by hand at every release — into a
  documented variation. The linked shape states its cost where it cannot be missed: **the installed
  skill follows whatever the checkout has checked out**, for every project on that machine at once,
  with no signal (#109).

### Fixed
- **Archiving no longer moves a consumed handoff into a subfolder — that broke every relative
  pointer inside it.** `0.7.0` sent archives into `handoff-archive/`, one directory deeper than the
  file they were written in. A handoff's body is written against its own directory: core §3 asks for
  repo-relative pointers, so a handoff at `.handoff/HANDOFF.md` reaches its project docs as
  `../docs/…`. The move silently redirected all of them — an adopting project's link checker
  reported 12 broken links in one archived file and failed the build, and moving that file back
  cleared all 12 with no other edit, which isolated the cause to the depth change alone. §1 now
  states the reason as an invariant rather than a path, so a later tidy-up cannot reintroduce it:
  **archiving preserves the file's depth; it is a rename, never a move.** The rename happens in
  place beside `handoff_file`, which still keeps `processed_` and `discarded_` sorted together —
  most of what the folder was for. **Nothing moves:** archives a project already collected in a
  folder of their own stay exactly where they are, so no upgrade relocates existing records.
  **Upgrading is not sufficient on its own.** The archives `0.7.0` already moved keep their broken
  pointers until they are moved back beside `handoff_file`, which restores them with no other edit.
  §1 now says so in as many words — the skill relocating nothing is a limit on the skill, not an
  instruction to you — and **Check** (§9) reports a `handoff-archive/` folder when it finds one, so
  the repair is offered at setup instead of waiting for a link checker to go red. The first wording
  said only "nothing moves", which read as *these records must stay put*: the opposite of the repair
  that the report demonstrated (#112, #114).

## [0.7.0] - 2026-08-15

### Changed
- **Consumed handoffs are archived into `handoff-archive/` instead of beside the live one.** Since
  archives are never deleted, the folder holding `handoff_file` only grew: one adopting repository
  held 47 files, then 49 two days later, all in the same directory as the single live handoff. Core
  §1 now sends `processed_` / `discarded_` renames into `handoff-archive/`, a folder beside
  `handoff_file` created on first use, so the directory holding the live resume pointer is not
  dominated by files that are not it. The name is deliberately not `archive/`: that folder is often
  shared (`docs/`, a repo root) and a generic name can collide with one already in use. No config
  key — the location is a convention, and a key is only worth its bytes if the skill acts on it.
  **Nothing moves:** archives already sitting beside `handoff_file` stay exactly where they are, so
  no project's existing records are relocated by an upgrade; only new archives go to the folder.
  `README.md` install step 3 is simpler for it — one folder to track or ignore, rather than a
  growing pile of loose files (#92).

### Added
- **An ad-hoc handoff now names the one block with no durable home, and Resume empties it first.**
  Core §7.1 lets task specifics live in the handoff when the user declines a tracked item — the
  single allowed exception to §2 — and said they move out "once a tracked item is created". Nothing
  carried that obligation forward: the next session read a handoff holding task content with no
  signal that it was the exception rather than the house style, so the shape propagated and the
  content stayed homeless for as long as anyone kept handing it on. Those specifics now go under one
  section named exactly `## Untracked specifics (move into a task when one exists)`, and nowhere
  else in the file; `flows/resume.md` §6.4 makes emptying it **step 2 — before archiving, before any
  work starts** — rather than something to notice later. The name is defined in the spine rather
  than in a flow because `create.md` writes the section and `resume.md` empties it, and the two
  never load in the same run, so a name defined in either would be invisible to the other (#55).
- **The install now ends with a step that proves the install.** An adopter reached the end of it with
  no way to tell a sound config from a plausible-looking one, so the first feedback arrived from a
  real run — usually a Create, at the moment they were trying to stop work. `README.md` step 6 is now
  **"Confirm it works"**: run **Check** (§9) and read the result against what a good one looks like —
  every key resolved or on a documented fallback, the binding file found, `handoff_file` writable. It
  says plainly that **no handoff existing yet is expected**, because Check verifies the path and
  never the file; without that line the honest result reads like a broken install. The step was
  re-specced onto Check from Status, which reads only the handoff file and, on a fresh install, has
  nothing to read at all (#54).
- **A config can now be checked before a session depends on it.** A config is prose read by an
  agent, not a parsed file, so nothing rejects a misspelled key, a `tracker` naming a binding that
  does not exist, or a `handoff_file` under a folder nobody created. All three surfaced **during** a
  run — usually a Create, at the moment the user was trying to stop work. A fifth mode, **Check**,
  moves that failure to setup: it resolves every §0 key, confirms the active binding file exists,
  confirms `handoff_file` can be written, runs the binding's invariant hook if it declares one, and
  reports the lot at once rather than stopping at the first failure. It fixes nothing and opens
  nothing — the paths to the homes are the question, not what is in them. The steps live in a new
  on-demand `flows/check.md` (§9) rather than in the always-loaded spine, because the concern bites
  once, at setup, and an adopter needs to validate a config **without** starting a real run. **How**
  to look is left to the environment, as with the §6.2 arrival check: the flow says a file exists, a
  folder accepts a write, a declared command exits clean, and names no tool for any of it. §0 gains
  the matching rule that a key which is present but will not resolve is a config defect to report,
  not something to work around mid-run (#53).
- **The package now states what happens to archived handoffs, and commits to never deleting one.**
  Consuming or discarding a handoff renames it and always has, so archives accumulate at roughly one
  per session — one adopting repository held 47 of them, and 49 two days later — but nothing in the
  package had ever said so, or said whose job it was to prune them. The answer is that it is **not**
  the skill's: they are the project's records and the only evidence of what a past session claimed,
  the only moment the skill could act on them is mid-Create or mid-Resume, and a tool invoked to
  preserve context should not be deleting files. No retention config key, for the same reason —
  a key is only worth its bytes if the skill acts on it. `handoff.core.md` §1 gains the two rules an
  agent needs (**only `handoff_file` is live**; an archive is never a resume candidate), and
  `README.md` and `config.example.md` put the tracked-or-ignored decision where an adopter actually
  makes it (#84).
- **Derived values are now routed by how hard they are to produce again.** A count, a duration, a
  size or a rate is *produced* by something, and prose hides that: "the full run takes 7–11 minutes"
  reads as a description rather than as one measurement taken once, so the next session has nothing
  to distrust. One adopter carried a measured figure through **five consecutive handoffs**; when it
  was finally re-measured it was 154 seconds against the 7–11 minutes being carried. Another carried
  a tracker count that was already stale when written. Both passed every gate, because §3 step 4
  admits "pure ephemeral state recorded nowhere else" and a measurement satisfies that honestly.
  `handoff.core.md` §3 gains the rule *Derived values decay* — cheap to re-derive, point at what
  answers it; expensive, route it to a durable home stamped with what was measured and when;
  neither, leave it out — plus an exclusion in step 4, where the mistake is actually made, and a
  pointer from §2's OUT list. The create flow's pre-write checklist gains a derived-value block,
  including a check that nothing was copied forward from a previous handoff unre-checked (#83).
- **Resume now checks which of the handoff's claims still hold before acting on them.** A handoff
  describes the workspace as it stood when a session stopped, and the world keeps moving after that
  — another session, another person, or elapsed time can make a claim false **without anyone having
  written it wrongly**. One adopter resumed a handoff stating a clean workspace with nothing pushed;
  on arrival there were four uncommitted items and the work had been pushed. No write-side rule can
  reach this, because the resume side is the only side that can know what arrived. `flows/resume.md`
  §6.2 now tests the handoff's checkable ephemeral claims, reports what no longer holds, and lets it
  change the plan — the workspace wins, and silently reconciling the difference is not an option. It
  runs before §6.3, so a mismatch reaches the user while resuming is still a decision. **How** to
  check is left to the environment: the core names no tool and keeps its domain-neutrality. Status
  (§6.5) deliberately does **not** run it — it previews the document rather than acting on it (#86).

### Fixed
- A **mode word followed by a qualifier** now has a correct reading in `handoff.core.md` §4
  *Explicit invocation and its argument*. The rule previously said that an argument which *is just a
  mode word* selects the mode, and **otherwise** the whole argument is a Create subject — so
  `resume, full lifecycle` selected **Create** and recorded "resume, full lifecycle" as the next
  session's task. That is the opposite of what was asked, and it discarded the live handoff in the
  same move. A leading mode word now always selects the mode; the remainder is the handoff's
  *subject* after `create`, and a *qualifier on this run* after `resume` / `status` / `close`. Adds
  one narrow ask-don't-guess case, for a qualifier that plainly describes work for a later session.
  Reported by an adopter (#78).
- **`reconcile_targets` is a floor, not a ceiling.** Core §3a said to sweep the declared targets
  *"otherwise"* the homes the session touched, and `flows/create.md` said to sweep **"exactly
  those"** — an either/or in which declaring the key silently *narrowed* the §3a sweep. An adopter
  closing four tasks left statements stale in two documents outside its declared list; they were
  only reconciled because the session happened to have touched them. The homes the session touched
  are now **always** swept, and declared targets are swept in addition. §0, `config.example.md` and
  `README.md` agree with it (#85).

### Documentation
- `bindings/local-markdown-dir.md` and `config.example.md` now state that **an unset
  `tracker_closed_dir` means nothing moves on closure** — done tasks stay in `tracker_dir`. The
  id-increment rule reads "across both the open and closed folders", which invited the reader to
  think closure needs a second folder; the `tracker_lint` invariant that every done file lives in
  the closed folder now says to skip it when the key is unset (#57).
- `config.example.md` and `README.md` now say what a **good** `reconcile_targets` looks like — the
  homes that go stale silently: the index, the lessons / decision files, the tracker (#57).

## [0.6.0] - 2026-08-09

First fixes from real production use: `local-markdown-dir` no longer assumes the folder is the index
(and every binding now states its assumptions), reconcile is surfaced as a first-class capability,
and an explicit `/handoff <text>` records that text as the handoff's subject instead of executing it.

### Fixed
- An explicit invocation with trailing text — e.g. `/handoff work on task T-012 full lifecycle` —
  is now unambiguously a **Create** whose *subject* is that text: the core records it as the intended
  next action in the handoff file and does **not** perform the described work in the current session.
  Previously the trailing text read like an instruction, so the agent sometimes did the task and never
  wrote the handoff. Added a `handoff.core.md` §4 *"Explicit invocation and its argument"* subsection
  (which also lands the explicit-vs-inferred note deferred from #47), taught `flows/create.md` to
  record the argument as the next action, and made both agent stubs state at the entry point that the
  argument is content to record, not a command to run. A leading mode word
  (`resume` / `status` / `close`) still selects that mode (#62).

### Changed
- Surfaced **reconcile** (core §3a) as a first-class capability. It was reachable only by reading the
  spine end-to-end; now `README.md` (intro, "How it works", and the modes diagram) and both agent
  skill descriptions (`agents/claude.SKILL.md`, `agents/copilot.agent.md`) name the backward
  staleness sweep that Create/Close run — so an adopter learns handoff doesn't only *record* new work,
  it *fixes the durable homes the session made stale*. Decision recorded on a standalone
  `/handoff reconcile` mode: worth doing, tracked as a separate follow-up (#60) (#56).
- `local-markdown-dir` no longer presents "the folder is the index" as the only topology. It now
  names two — **folder-as-index** and **a central index (generated or maintained)** — and spells out
  that a declared central index is a durable home that must be kept in sync (regenerate if generated,
  edit in the same pass if maintained), with `tracker_lint` as the enforcement hook that core §3a
  reconcile relies on. Fixes a silent failure where a handoff could follow the binding correctly and
  still leave a project's central index stale. Every binding (`notion`, `local-markdown`,
  `local-markdown-dir`) gained an **"Assumptions this binding makes"** section, and `bindings/README.md`
  makes that a required step when writing a binding; `EXAMPLES.md` and `config.example.md` show the
  central-index case (#52).

## [0.5.0] - 2026-07-17

Reconciliation as an explicit, backward-looking half of routing — a staleness sweep on Create and
Close so a "clean" handoff can't leave the tracker or memory contradicting the session's work —
plus a friction cut (explicit `resume` no longer re-asks to confirm) and a token-trimmed spine intro.

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

[Unreleased]: https://github.com/uchimata2/handoff-skill/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/uchimata2/handoff-skill/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/uchimata2/handoff-skill/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/uchimata2/handoff-skill/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/uchimata2/handoff-skill/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/uchimata2/handoff-skill/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/uchimata2/handoff-skill/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/uchimata2/handoff-skill/releases/tag/v0.1.0
