# Contributing

Thanks for your interest in improving the **Handoff skill** — the portable, project- and
agent-neutral source for a skill that transfers working context between AI sessions.
Contributions of all sizes are welcome: fixes, clearer wording, new tracker bindings, or
support for another agent.

## What's in here

- `handoff.core.md` — the always-loaded spine (config, routing model, detection, session types,
  binding contract) — the heart of the skill.
- `flows/` — the two on-demand flow files: `create.md` (Create / Close) and `resume.md`
  (Resume / Status).
- `config.example.md` — the per-project config schema.
- `bindings/` — tracker bindings (`notion`, `local-markdown`) + how to write your own.
- `agents/` — per-agent stub templates.
- `EXAMPLES.md` — annotated good-vs-bad handoffs and walkthroughs by session type.
- `README.md` — install + overview.

The package is plain Markdown — there is no build step for the package itself.

## Ground rules

- **Keep the core generic.** `handoff.core.md` must stay free of any project-, tracker-,
  agent-, or language-specific detail — those belong in a project's config or in a binding.
  Quick check: a case-insensitive grep of the core for a specific tool/project/tracker name
  should come back empty (the abstract binding contract aside).
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
- **Then implement:** branch, make the change (Markdown only), and open a PR that closes the issue
  (`Closes #123`). Keep it small and focused, and add a `CHANGELOG.md` entry under *Unreleased*.

Status labels track where an issue is: `status: needs spec` → `status: ready` →
`status: in progress` → merged. They also drive a visual kanban — the
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
  actually contains every PR's commits and that each linked issue auto-closed — a PR only closes its
  issue when it merges into the **default** branch (`main`).

## Adding a tracker binding

Add `bindings/<tracker>.md` implementing the binding contract from `handoff.core.md` (§8):
**find / read / create / update / reference**. See `bindings/README.md` for the shape and an
example to copy.

## License

By contributing, you agree that your contributions are licensed under the repository's
[MIT License](LICENSE).
