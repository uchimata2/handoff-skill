# Contributing

Thanks for your interest in improving the **Handoff skill** — the portable, project- and
agent-neutral source for a skill that transfers working context between AI sessions.
Contributions of all sizes are welcome: fixes, clearer wording, new tracker bindings, or
support for another agent. By participating, you agree to uphold our
[Code of Conduct](CODE_OF_CONDUCT.md).

## What's in here

For the package layout, see [README's "What's in here"](README.md#whats-in-here). The exact set of
files bundled into the `handoff.skill` artifact is the canonical **package manifest** — defined once,
in the `$items` array in [`scripts/build-skill.ps1`](scripts/build-skill.ps1) — so this guide and the
README describe the package rather than keeping their own copies of the file list.

The package is plain Markdown — there is no build step for the package itself.

`tests/` is repo infrastructure and is **not** in that manifest, so nothing under it ships. Today it
holds one thing: [`tests/handoff-fixture/`](tests/handoff-fixture/README.md), a handoff-shaped
document and its archived rename, both written with repo-relative pointers so the link check has an
artifact whose links depend on its depth. **If you change where archives go, move those two files
with it** — that is the whole point of them, and its README says so.

## Ground rules

- **Keep the core generic.** The core — the `handoff.core.md` spine **and** the `flows/` files —
  must stay free of any project-, tracker-, agent-, or language-specific detail; those belong in a
  project's config or in a binding. Quick check: a case-insensitive grep of `handoff.core.md` and
  `flows/` for a specific tool/project/tracker name should come back empty (the abstract binding
  contract aside).
- **One home per fact.** The skill exists to enforce single-source-of-truth routing, so keep
  the docs themselves free of duplication (core vs. bindings vs. config should not repeat
  each other).
- **Stay domain-neutral.** Wording and examples must not assume code, version control, or any
  one kind of work — the skill is for any session, dev or not.
- Keep PRs small and focused; update `README.md` if you change behavior or structure.

## How to contribute

1. Fork the repo and create a branch.
2. Make your change (Markdown only).
3. Open a pull request describing what changed and why.

## Working the backlog

Work is tracked in [GitHub issues](https://github.com/uchimata2/handoff-skill/issues):

- **Find something to do:** filter by label. `status: ready` means the approach is agreed and it's
  ready to implement; `good first issue` is a gentle start. Priority is the `priority:*` labels;
  related work is grouped by [milestone](https://github.com/uchimata2/handoff-skill/milestones).
- **Specify before you build (for non-trivial changes):** agree the approach on the issue first —
  a short spec in the issue or a comment — and get a maintainer's sign-off. This keeps single
  source of truth (the issue holds the spec) and avoids rework. Small fixes can go straight to a PR.
- **Then implement:** branch, make the change (Markdown only), and open a PR that references the
  issue (`Refs #123` — **not** `Closes #123`; see below). Keep it small and focused, and add a
  `CHANGELOG.md` entry under *Unreleased* if the change touches the shipped package.
- **Then close it by labelling it:** set `status: done` on the issue. That is what closes it — the
  label is the one stored fact, and both the issue's open/closed state and its board column are
  rendered from it. `Closes #N` is avoided precisely because it makes GitHub close the issue with no
  label write behind it, leaving the label saying one thing and the state another.

Status labels track where an issue is: `status: needs spec` → `status: ready` →
`status: in progress` → `status: done`. Move between them with **one combined edit** —
`gh issue edit N --add-label "status: ready" --remove-label "status: needs spec"` — because the field
holds one value and the sync fails the run if it finds two. They also drive a visual kanban — the
[Handoff — Roadmap board](https://github.com/users/uchimata2/projects/1). Cards move
automatically when you change a label, so there's no board to manage by hand; see
[`PROJECT_BOARD.md`](PROJECT_BOARD.md) for how the sync works.

## Merging dependent or stacked PRs

Most changes here are independent — open them as separate PRs branched off `main`. When a change
genuinely builds on another that isn't merged yet (a *stack*), merge with care: a stacked merge can
otherwise cascade *sideways* into the lower branch instead of landing on `main`, leaving `main` with
only the bottom PR and the upper PRs' issues still open.

- **Prefer sequential, non-stacked PRs** when practical — merge one, then branch the next off the
  updated `main`. There's less to go wrong.
- **If you do stack, merge bottom-up, one at a time.** This repo auto-deletes head branches on merge,
  so as each PR merges GitHub retargets the next one's base to `main` — wait for that retarget before
  merging the next.
- **Verify the default branch before calling it shipped.** After the stack lands, confirm `main`
  actually contains every PR's commits, and that each issue carries `status: done` and is closed.
  Nothing closes an issue for you: a merged PR leaves its issue **open** until the label is set. That
  is deliberate — an issue still open after its PR merged is a visible reminder, where an issue
  closed with a stale label is invisible.

## Adding a mode

A mode's steps live in a new `flows/<mode>.md`, but the mode also has to be **reachable**, and
reachability is spread across seven files. Adding **Check** touched every one of them
([PR #100](https://github.com/uchimata2/handoff-skill/pull/100)); this list is that file set.

| File | What the new mode has to reach |
| :--- | :--- |
| `flows/<mode>.md` | the mode's own steps — the new file |
| `handoff.core.md` | §4 *Triggers*; the mode list in the §4 subsection heading; §4 *Explicit invocation and its argument*; §4 *Load the relevant flow*; the flow-file list near the top of the spine |
| `config.example.md` | only if the mode reads or writes a config key — Check did, most won't |
| `README.md` | the *What's in here* flow list, and install step 5's mode list |
| `agents/claude.SKILL.md` | the `description:` frontmatter, the flow-file list, the mode list, the distinct-commands paragraph |
| `agents/copilot.agent.md` | the `description:` frontmatter, the flow-file list, the mode-word parenthetical |
| `CHANGELOG.md` | `[Unreleased]` — a mode changes the shipped package |

**The `description:` frontmatter is the one that fails silently.** Core §4 lists a mode's trigger
words, but §4 is only read once the skill has already activated, and it is the `description:` that
decides whether it activates at all. A mode the description says nothing about is reachable only by
typing `/handoff <mode>`: the natural-language triggers §4 documents never fire, nothing errors, and
the mode looks correct to whoever tested it the way they built it. Both agent templates carry a
description, and both need the clause.

Every other line in the table is visible the first time someone reads the file it belongs to, which
is why only this one carries an explanation.

## Adding a tracker binding

Add `bindings/<tracker>.md` implementing the binding contract from `handoff.core.md` (§8):
**find / read / create / update / reference**. See `bindings/README.md` for the shape and an
example to copy.

## License

By contributing, you agree that your contributions are licensed under the repository's
[MIT License](LICENSE).
