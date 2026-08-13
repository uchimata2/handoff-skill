# Conventions for agents working in this repository

Short on purpose: this file is loaded on every turn, before it is clear that there is any task work.
Anything that can wait to be looked up lives in the document it belongs to and is linked from here.

## Task tracking

Tasks are **GitHub issues** in this repository, worked with the
[taskmd](https://github.com/uchimata2/taskmd) method and its **GitHub Issues** binding. The schema is
[`.taskmd/config.md`](.taskmd/config.md).

**Read [`.taskmd/ADOPTION.md`](.taskmd/ADOPTION.md) before writing to a task.** This project departs
from that binding in four recorded ways, and one of them — closure being driven by issue state
rather than by the `status:` label — is the kind of mismatch that leaves a task quietly contradicting
itself. The board is [Handoff — Roadmap](https://github.com/users/uchimata2/projects/1); see
[`PROJECT_BOARD.md`](PROJECT_BOARD.md). Never drag a card by hand.

Two consequences of the deviations, stated here because they bind at the moment of acting:

- **Setting `status: done` is part of merging a PR, not a step after it.** `Closes #N` plus a
  squash-merge closes the issue without touching the label, and nothing detects the disagreement.
- **An issue with no `status:` label is not unclassified — it is `backlog`,** and deliberately off
  the board. Do not add a label to "fix" it.
- **The *why* goes on the issue, not in the PR.** The PR template asks "what changed and why", and a
  reason that lives only there — or only in a commit message — is invisible to every task operation.
  Put the reasoning on the issue and let the PR body summarise it.

## Conduct

These two bind on every turn, in every phase, including before any task is in view. They are
[taskmd METHOD](https://github.com/uchimata2/taskmd) §3.1 and §3.3, carried here because a session
that has not yet loaded the method has not been given them.

### One phase per request — never auto-advance

Do the phase that was asked for, then stop and report. Do not continue into the next one because it
is obvious, because the plan already describes it, or because a note said it was next. **A pointer is
context, not authorization** — a "next step" line, a resumption note, an unfinished checklist, the
rhythm of the last three tasks: none of these is a request.

### Surface what you discover — never absorb it, never drop it

Work turns up things nobody anticipated: a better approach, a flawed premise, an unrelated defect, a
missing prerequisite. Each goes to exactly one of two places.

- **It changes what the current task should produce** → raise it as a question now, before
  continuing. Quietly widening or narrowing the outcome substitutes your judgement for the owner's.
- **It is actionable but outside this task** → raise a new task for it.

Never the third option: fixing it silently, or noticing it and moving on. A silent fix makes the
task's record false; a dropped observation is lost the moment the session ends.

## Working conventions

- Work the backlog **one-by-one, specify-then-implement**: agree the spec on the issue, then
  implement on a branch off `main` — not off another feature branch — then PR with `Closes #N`,
  squash-merge, `--delete-branch`.
- Update `CHANGELOG.md` `[Unreleased]` with every change.
- CI ([`.github/workflows/checks.yml`](.github/workflows/checks.yml)) must be green: portability
  guard and offline link check.
- This repo is public and agent-neutral. Never introduce origin-internal names — source ticket ids,
  the originating project's name, or the internal tools it used — into anything committed here.
