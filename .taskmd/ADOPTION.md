# taskmd adoption — assessment, not yet an adoption

**Assessed 2026-08-09.** This project tracks work as GitHub Issues with a Projects board, so the
relevant taskmd binding is **GitHub Issues**, shipped with the taskmd plugin as
`docs/bindings/github-issues.md`. No local `tasks/` folder and no taskmd CLI are involved: the CLI is
local-Markdown only, and nothing in it touches the network.

That binding opens with six assumptions, described as *claims about your project, not about GitHub*,
each of which has to be true before the instructions are safe. They were checked here rather than
assumed. **One fails, and it is structural** — so this file records the position instead of declaring
an adoption that would be false on the day it was written.

## The check

| # | Assumption | Here |
| :-- | :--- | :--- |
| 1 | Nothing needs a task's id before the task exists | **Holds**, as far as could be seen — ids appear in the changelog and the board after the issue exists, not before |
| 2 | Nobody closes or reopens an issue in the UI; `state` is written *from* the `status:` label | **Fails — see below** |
| 3 | Every label the vocabulary needs already exists | **Partly.** Three exist: `status: needs spec`, `status: ready`, `status: in progress`. taskmd's default status vocabulary has eight values; the gap is a mapping decision, not a blocker |
| 4 | `gh` ≥ 2.94.0, issues with sub-issues and dependencies, `repo` scope | **Holds.** `gh version 2.96.0` |
| 5 | A GitHub cross-reference is not treated as a recorded link | **Unverified.** Needs a judgement from whoever works the issues |
| 6 | Nothing about a task is recorded only in a PR, commit or branch | **Unverified, and worth answering honestly** — this project reviews through PRs |

## Why assumption 2 fails, and what it would cost

`PROJECT_BOARD.md` defines the **Merged** column as *issue closed*, and
`.github/workflows/sync-status-to-project.yml` implements it: the job reads
`github.event.issue.state` and picks the column from it, falling back to the `status:` labels only
when the issue is open.

So here, open/closed is an **independent fact** a human sets in the UI, and the board is derived from
it. The binding requires the reverse: the `status:` label is the one stored fact, and state is a
rendering written from it — *"a click that changes the rendering without changing the fact leaves the
task contradicting itself, and no view will flag it."*

These are not reconcilable by documentation. Adopting the binding as written would mean changing the
workflow so the label is authoritative and the state is written from it, and asking the team to stop
closing issues by hand. That is a real change to working automation, and it is a decision for the
maintainer rather than something to slip into an install.

## What was deliberately not done

- **No local `tasks/` folder.** Migrating the issues into Markdown would abandon the board and its
  sync, and would give the project two homes for one fact.
- **No change to the workflow, the labels, or the board.** All of it works; none of it was touched.
- **No claim that this project follows the binding.** It follows its own board convention, which is
  coherent — it simply is not this binding.

## If you want to proceed

The order that costs least first:

1. Answer assumptions 5 and 6, which need a person rather than a grep.
2. Decide assumption 2: make the `status:` label authoritative and have the workflow write state
   from it, or accept that this project keeps its own convention and does not adopt the binding.
3. Only then map the label set onto the status vocabulary, which is the easy part and is wasted
   effort before step 2.
