# Link-check fixture — an archived handoff keeps its depth

This folder exists so that CI can catch the bug in
[#112](https://github.com/uchimata2/handoff-skill/issues/112): archiving a consumed handoff into a
subfolder moved it one directory deeper than the document it was written in, so every repo-relative
pointer in its body resolved one level too high the moment it stopped being editable and became a
record.

An adopting project's link checker found that. This repository's could not have, for two reasons —
its own handoffs live under a git-ignored `control/`, and they point at work with absolute URLs and
bare code spans, so they are depth-invariant by accident. Nothing here was written in the style that
breaks. This fixture is.

## What it is

| File | Role |
|---|---|
| [`HANDOFF.md`](HANDOFF.md) | A synthetic handoff at its **live** depth. No session content. |
| [`processed_20260816-000000_HANDOFF.md`](processed_20260816-000000_HANDOFF.md) | The same document after archiving — **same body, same folder, different name**. |

The two bodies are identical, and that is the assertion. Archiving is a **rename, never a move**
([`handoff.core.md`](../../handoff.core.md) §1), so the archived copy must resolve from exactly where
the live one did. One body that has to work from two places can only do so if those places are the
same depth.

No CI change was needed: the link check in
[`.github/workflows/checks.yml`](../../.github/workflows/checks.yml) already globs `'*.md'` and
`'**/*.md'`, so both files were covered the moment they existed.

## How to break it

Move the archived copy one level down and run the link check:

```
mkdir tests/handoff-fixture/handoff-archive
git mv tests/handoff-fixture/processed_20260816-000000_HANDOFF.md tests/handoff-fixture/handoff-archive/
```

Its `../../…` pointers now resolve into `tests/` instead of the repository root, and lychee fails on
a file nobody edited. That is #112, reproduced. Move it back and the check passes again.

## What it does not cover

Editing the archiving rule in [`handoff.core.md`](../../handoff.core.md) or
[`flows/`](../../flows/create.md) while leaving this folder alone fires nothing — the fixture tests
an artifact, not a sentence. So **if you change where archives go, move these files with it.** The
red run you get is the guard doing its job, not an obstacle to route around.

## It does not ship

The package manifest is the `$items` array in
[`scripts/build-skill.ps1`](../../scripts/build-skill.ps1), and it is an allowlist. Anything outside
it — this folder included — is excluded by construction.
