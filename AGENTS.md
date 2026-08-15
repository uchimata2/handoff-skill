# Conventions for agents working in this repository

Short on purpose: this file is loaded on every turn, before it is clear that there is any task work.
Anything that can wait to be looked up lives in the document it belongs to and is linked from here.

It does not load itself. [`CLAUDE.md`](CLAUDE.md) is a one-line import that pulls this file in;
without it nothing here reaches an agent, and two of the mitigations in
[`.taskmd/ADOPTION.md`](.taskmd/ADOPTION.md) stop being true. Moving or renaming either file means
re-running the check described there.

## Task tracking

Tasks are **GitHub issues** in this repository, worked with the
[taskmd](https://github.com/uchimata2/taskmd) method and its **GitHub Issues** binding. The schema is
[`.taskmd/config.md`](.taskmd/config.md).

**Read [`.taskmd/ADOPTION.md`](.taskmd/ADOPTION.md) before writing to a task.** This project departs
from that binding in two recorded ways — down from four, since closure is now driven by the `status:`
label and the PR template no longer asks for the *why*. The board is
[Handoff — Roadmap](https://github.com/users/uchimata2/projects/1); see
[`PROJECT_BOARD.md`](PROJECT_BOARD.md). Never drag a card by hand.

Three things that bind at the moment of acting:

- **Setting `status: done` is how you close an issue.** The label is the one stored fact; the issue's
  open/closed state and its board column are both rendered from it. So the last step of merging a PR
  is labelling its issue — not because a convention asks, but because nothing else closes it. PRs
  carry `Refs #N`, never `Closes #N`.
- **An issue with no `status:` label is not unclassified — it is `backlog`,** and deliberately off
  the board. Do not add a label to "fix" it.
- **Change a status with one combined `gh issue edit --add-label … --remove-label …`.** The field
  holds one value and two labels fail the sync; a combined edit removes before it adds, two separate
  calls leave a window where both exist.
- **The *why* goes on the issue, not in the PR.** A reason that lives only in a PR body or a commit
  message is invisible to every task operation. The PR template now asks only "what changed" and
  points the *why* at the issue, so this is the template's default rather than a discipline — but a
  commit message is still an easy place to strand a decision.

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
  implement on a branch off `main` — not off another feature branch — then PR with `Refs #N`,
  squash-merge, `--delete-branch`, then set `status: done`, which closes the issue.
- Update `CHANGELOG.md` `[Unreleased]` with every change **to the shipped package** — the files in
  the `$items` manifest in [`scripts/build-skill.ps1`](scripts/build-skill.ps1), which is what the
  release asset is built from. Repo infrastructure gets **no** entry: CI, workflows, issue and PR
  templates, board tooling, this file, `CONTRIBUTING.md`, `control/`. The changelog is read by
  someone deciding whether to update the copy they installed, and a change they cannot observe in
  that copy is noise to them (#76).
- CI ([`.github/workflows/checks.yml`](.github/workflows/checks.yml)) must be green: portability
  guard and offline link check.
- This repo is public and agent-neutral. Never introduce origin-internal names — source ticket ids,
  the originating project's name, or the internal tools it used — into anything committed here.
