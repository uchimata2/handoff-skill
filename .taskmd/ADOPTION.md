# taskmd adoption — adopted, with recorded deviations

**Assessed 2026-08-09. Adopted 2026-08-14** on the maintainer's instruction. This project tracks work
as GitHub Issues with a Projects board, so the binding is **GitHub Issues**, shipped with the taskmd
plugin as `docs/bindings/github-issues.md`. The schema is [`config.md`](config.md). No local `tasks/`
folder and no taskmd CLI are involved: the CLI is local-Markdown only, and nothing in it touches the
network.

The earlier version of this file recorded an assessment and declined to adopt, because one of the
binding's six assumptions failed structurally here. Adoption went ahead anyway, so this file's job is
to say exactly where the project departs from the binding and what each departure costs — an adoption
that hid them would be the failure mode the binding's own preamble describes, *a project inconsistent
while appearing to comply*.

**Two of the four departures were since fixed rather than lived with** (#66 and #72, 2026-08-14),
including the structural one. They are kept below as retired entries rather than deleted: what the
adoption cost, and what closed the gap, is the part worth being able to read later.

## The check

Assumptions are claims about **this project**, not about GitHub.

| # | Assumption | Here |
| :-- | :--- | :--- |
| 1 | Nothing needs a task's id before the task exists | **Holds** — ids appear in the changelog and the board after the issue exists, not before |
| 2 | Nobody closes or reopens an issue in the UI; `state` is written *from* the `status:` label | **Holds since 2026-08-14** — see *Deviation 1, retired* |
| 3 | Every label the vocabulary needs already exists | **Holds as of adoption** — `status: done` and `status: cancelled` were created; everything else already existed |
| 4 | `gh` ≥ 2.94.0, issues with sub-issues and dependencies, `repo` scope | **Holds.** `gh version 2.96.0` |
| 5 | A GitHub cross-reference is not treated as a recorded link | **Holds** — see below |
| 6 | Nothing about a task is recorded only in a PR, commit or branch | **Holds since 2026-08-14** — see *Deviation 4, retired* |

**Assumption 5, answered 2026-08-14.** This project groups related work by
[milestone](https://github.com/uchimata2/handoff-skill/milestones)
([`../CONTRIBUTING.md`](../CONTRIBUTING.md)), not by mentioning one issue on another. The only `#N`
convention is `Refs #N` in a PR's *Related issue* section — a reference rather than a relation between
two tasks, and since #66 not a closing link either. Nothing here has ever read an incidental
cross-reference as a record, so moving `related` into the issue-body property block takes nothing
away.

**Assumption 6, answered 2026-08-14 — it failed, and was then fixed.** It failed, though not where
the assessment expected: review discussion was the predicted leak, because this project reviews
through PRs, but the last six merged PRs before adoption (#51, #58, #59, #61, #63, #64) carried
**zero comments and zero reviews between them**, so there was no review thread for a decision to hide
in. The leak was deviation 4 — the PR template asking for the *why* — and removing that prompt is
what closed it.

## Deviation 1 — retired 2026-08-14

**What it was.** `PROJECT_BOARD.md` defined the **Merged** column as *issue closed*, and the sync
workflow implemented it: the job read `github.event.issue.state` and picked the column from it,
falling back to the `status:` labels only when the issue was open. PRs carried `Closes #N` and were
squash-merged, so GitHub closed issues automatically — a state change with no label write behind it.
Between a merge and someone setting the label, an issue read `status: in progress` and
`state: closed` at the same time, invisibly, because the board showed Merged and looked right.

**The fix this file called "not taken" was taken** (#66, after #72 gave the chain branches for
`done` and `cancelled`). The workflow now reads labels only and renders **both** views from them —
the board column *and* the issue's open/closed state. `Closes #N` is gone; PRs use `Refs #N`, and
setting `status: done` is what closes an issue.

**It is now an invariant rather than a convention.** The previous mitigation was procedural — a rule
in `AGENTS.md`, fallible by construction. Nothing now depends on anyone remembering: a merged PR
whose issue was never labelled leaves that issue **open**, which is visible, where the old failure
was an issue closed with a stale label, which was not.

**The backlog of contradictions it left is cleared** (#69, 2026-08-14). Every one of the 40 closed
issues now carries `status: done`; none carries an open value, and none carries none. The check that
found the problem — *closed issues still carrying an open `status:` label* — returns **0**, from 17.
No issue was reopened by the sweep and no workflow run failed. That also retired the hazard this
paragraph used to warn about, which was live for exactly the hours between the two merges.

**What is left of it.** Closing an issue by hand is now *reverted* on the next label event. That is
correct — state is a rendering — but it will surprise anyone who does it, because nothing warns you
at the moment of clicking.

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

## Deviation 4 — retired 2026-08-14

**What it was.** [`../.github/PULL_REQUEST_TEMPLATE.md`](../.github/PULL_REQUEST_TEMPLATE.md) opened
with **"What changed and why"**. That section invited the reasoning behind a change into the pull
request, and this binding never reads anything attached to an issue, so a decision whose only home
was a PR body — or a commit message — had no home at all (METHOD §6). It was structural rather than
accidental: the template asked for it every time.

**Fixed at the source** (#66, folded in because it lands in the same files). The heading is now
**"What changed"**, and the template points the *why* at the issue. The cause was the prompt, so
removing the prompt removes the deviation; the previous mitigation was a rule in `AGENTS.md` asking
people not to answer a question the template kept asking.

**What is left of it.** A commit message is still an easy place to strand a decision, and no template
governs those. `AGENTS.md` keeps the rule for that reason, narrowed to it.

## How `AGENTS.md` reaches the agent

The two mitigations this section was written for are gone — #66 and #72 replaced both with
automation, which is the point: a rule in a file that no agent is given is not a mitigation at all.
`AGENTS.md` still carries the deviation-2 and deviation-3 rules and the conduct rules, so how the
file is delivered remains part of the adoption rather than a detail of it. It matters less than it
did, and the probes below are still the only evidence that it works.

**Measured 2026-08-14, and the first answer was no.** taskmd's `adopt.md` describes the method: start
a session, ask what it was handed **before it uses any tool**, and read the answer. A fresh session in
this repo named three sources — the user's global `CLAUDE.md`, that user's project-scoped memory
index, and its own system prompt — and no file from this repository. `AGENTS.md` had been on `main`
for the whole of that session's existence. Both mitigations were inert for as long as it took to
check, which was one session.

**The delivery route is [`../CLAUDE.md`](../CLAUDE.md)**, a file whose entire content is a
`@AGENTS.md` import. `AGENTS.md` stays canonical because this repo is agent-neutral; the import is a
loading mechanism, not a second copy of a fact.

**Verified 2026-08-14, in two probes, because delivery is not force.** A rule that arrives and is
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
