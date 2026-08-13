# taskmd adoption — adopted, with recorded deviations

**Assessed 2026-08-09. Adopted 2026-08-10** on the maintainer's instruction. This project tracks work
as GitHub Issues with a Projects board, so the binding is **GitHub Issues**, shipped with the taskmd
plugin as `docs/bindings/github-issues.md`. The schema is [`config.md`](config.md). No local `tasks/`
folder and no taskmd CLI are involved: the CLI is local-Markdown only, and nothing in it touches the
network.

The earlier version of this file recorded an assessment and declined to adopt, because one of the
binding's six assumptions fails structurally here. That assumption still fails. Adoption went ahead
anyway, so this file's job is now to say exactly where the project departs from the binding and what
each departure costs — an adoption that hid them would be the failure mode the binding's own
preamble describes, *a project inconsistent while appearing to comply*.

## The check

Assumptions are claims about **this project**, not about GitHub.

| # | Assumption | Here |
| :-- | :--- | :--- |
| 1 | Nothing needs a task's id before the task exists | **Holds** — ids appear in the changelog and the board after the issue exists, not before |
| 2 | Nobody closes or reopens an issue in the UI; `state` is written *from* the `status:` label | **Fails — deviation 1** |
| 3 | Every label the vocabulary needs already exists | **Holds as of adoption** — `status: done` and `status: cancelled` were created; everything else already existed |
| 4 | `gh` ≥ 2.94.0, issues with sub-issues and dependencies, `repo` scope | **Holds.** `gh version 2.96.0` |
| 5 | A GitHub cross-reference is not treated as a recorded link | **Holds** — see below |
| 6 | Nothing about a task is recorded only in a PR, commit or branch | **Fails narrowly — deviation 4** |

**Assumption 5, answered 2026-08-10.** This project groups related work by
[milestone](https://github.com/uchimata2/handoff-skill/milestones)
([`../CONTRIBUTING.md`](../CONTRIBUTING.md)), not by mentioning one issue on another. The only `#N`
convention is `Closes #N` in a PR's *Related issue* section, which is a closing link rather than a
relation between two tasks. Nothing here has ever read an incidental cross-reference as a record, so
moving `related` into the issue-body property block takes nothing away.

**Assumption 6, answered 2026-08-10 — and it fails**, though not where the assessment expected. It
expected review discussion to be the leak, because this project reviews through PRs. It is not: the
last six merged PRs (#51, #58, #59, #61, #63, #64) carry **zero comments and zero reviews between
them**, so there is no review thread for a decision to hide in. The leak is deviation 4.

## Deviation 1 — closure is state-driven, not label-driven

[`../PROJECT_BOARD.md`](../PROJECT_BOARD.md) defines the **Merged** column as *issue closed*, and
`.github/workflows/sync-status-to-project.yml` implements it: the job reads
`github.event.issue.state` and picks the column from it, falling back to the `status:` labels only
when the issue is open. On top of that, this project's PRs carry `Closes #N` and are squash-merged,
so **GitHub closes issues automatically** — a state change with no label write behind it.

The binding requires the reverse: the `status:` label is the one stored fact, and state is a
rendering written from it — *"a click that changes the rendering without changing the fact leaves
the task contradicting itself, and no view will flag it."*

**Cost.** Between a PR merging and someone setting the label, the issue reads `status: in progress`
and `state: closed` at the same time. Nothing detects this. It is invisible in the board, which
shows Merged and looks right.

**Mitigation, procedural and therefore fallible.** Setting `status: done` is part of merging a PR,
not a step after it — see [`../AGENTS.md`](../AGENTS.md), which reaches an agent only by the route
described in *How `AGENTS.md` reaches the agent* below. This is a convention, not an invariant; the
workflow is unchanged and still derives the column from state.

**The fix not taken.** Making the label authoritative means editing the sync workflow to read labels
only, adding a Merged-from-`status: done` rule, and dropping `Closes #N` auto-close. That is a real
change to working automation and a maintainer's decision, not something to slip into an adoption.

## Deviation 2 — `backlog` is the absence of a label

The binding's mapping rule 2 makes every enumerated value a `<field>:<value>` label. This repo
deliberately keeps lower-priority issues **off** the board by giving them no `status:` label at all.
Rather than relabel them — which would pull every one of them onto the board and change what the
board means — the schema names that absence `backlog`. Writing a task to `backlog` removes its
`status:` label instead of adding one.

## Deviation 3 — label names carry a space

The binding writes `status:proposed`. This repo's labels are `status: needs spec`, `status: ready`,
`status: in progress` — with a space, matched literally by the sync workflow. Renaming them would
break the workflow for a cosmetic gain, so the space stays and every `gh` write must reproduce it
exactly. A mistyped label fails the write rather than mislabelling, which is what makes this safe.

## Deviation 4 — the PR body is a second home for "why"

[`../.github/PULL_REQUEST_TEMPLATE.md`](../.github/PULL_REQUEST_TEMPLATE.md) opens with **"What
changed and why"**. That section invites the reasoning behind a change into the pull request, and
this binding never reads anything attached to an issue, so a decision whose only home is a PR body —
or a commit message — has no home at all (METHOD §6).

This is structural rather than accidental: the template asks for it every time. It is also the
smallest of the four deviations to live with, because the venue that would have made it serious does
not exist here — nobody discusses in review threads on this repo.

**Mitigation.** The *why* belongs on the issue; the PR body summarises what the issue already says
and links to it. Recorded in [`../AGENTS.md`](../AGENTS.md) so it binds at the moment of writing a
PR, which is the only moment it can be obeyed — and therefore subject to the same delivery route as
deviation 1's mitigation, below.

## How `AGENTS.md` reaches the agent

Both mitigations above are rules in a file. A rule in a file that no agent is given is not a
mitigation, so how the file is delivered is part of the adoption rather than a detail of it.

**Measured 2026-08-10, and the first answer was no.** taskmd's `adopt.md` describes the method: start
a session, ask what it was handed **before it uses any tool**, and read the answer. A fresh session in
this repo named three sources — the user's global `CLAUDE.md`, that user's project-scoped memory
index, and its own system prompt — and no file from this repository. `AGENTS.md` had been on `main`
for the whole of that session's existence. Both mitigations were inert for as long as it took to
check, which was one session.

**The delivery route is [`../CLAUDE.md`](../CLAUDE.md)**, a file whose entire content is a
`@AGENTS.md` import. `AGENTS.md` stays canonical because this repo is agent-neutral; the import is a
loading mechanism, not a second copy of a fact.

**Verified 2026-08-10, in two probes, because delivery is not force.** A rule that arrives and is
then sailed past is worth nothing, and it is worse than one that never arrived: the file still reads
as authoritative.

*Delivered.* A fresh session, asked as its first message to list every project-specific convention it
had been handed and name the file each came from — **before using any tool** — named `AGENTS.md` and
stated that it reaches the session only because `CLAUDE.md` imports it. That sentence is written
nowhere else, so it could only have been given. Zero tool calls, and the transcript is the evidence:
a session that *reads* the file to answer has failed the probe, and the reading is what proves it.

*In force.* The same probe, given an ordinary two-phase request — *"add a `status: blocked` value to
this project's task schema and wire it up"* — which §3.1 requires be stopped after the spec. It
stopped, cited §3.3 by name for surfacing findings before acting, and kept its recorded assumptions
separate from its open questions. It also found a live defect in the board sync that this file's own
author had introduced and missed. Rules that catch their author's mistakes are doing work rather
than sitting in context.

**The loader is load-bearing and looks disposable.** A one-line file with no prose invites deletion
or a rename, and removing it disarms two mitigations at once with no error, no failing check, and
nothing in any view to show it. Re-run **both** probes after touching either file — never in the
session that wrote it, whose context is already contaminated, and never while naming `AGENTS.md` in
the question, which invalidates the first. Assume nothing about which filenames an agent loads; that
assumption is what this section exists to record.

## What was deliberately not done

- **No local `tasks/` folder.** It would abandon the board and its sync, and give one fact two homes.
- **No change to the workflow or the board.** All of it works; none of it was touched.
- **No new taxonomy.** `phase`, `type` and `effort` are not enumerated, so adoption created two
  labels rather than twenty-eight. See [`config.md`](config.md) *Vocabularies*.

## Finding worth sending upstream to taskmd

The config format strips ` #` and everything after it as a comment. On this binding the natural
`id_prefix` is `#`, so `id_prefix: #` parses as an **empty value** rather than as the prefix — the
one backend where that key most obviously wants a `#` is the one where writing it plainly is wrong.
Quoting is used here (`id_prefix: '#'`) and is untested against the parser, because the CLI does not
run on this project. Worth a taskmd issue.
