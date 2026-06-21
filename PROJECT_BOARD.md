# Project board & status automation

This repo's roadmap is a visual kanban on GitHub Projects:
**[Handoff — Roadmap](https://github.com/users/uchimata2/projects/1)**.

The board is just a view of the [issues](https://github.com/uchimata2/handoff-skill/issues) —
the same items, grouped by lifecycle stage. **You never drag cards by hand.** A card's column
is driven by the issue's `status:` label and kept in sync automatically (see
[How the sync works](#how-the-sync-works)).

## Columns = lifecycle

`status: needs spec` → `status: ready` → `status: in progress` → **Merged**

| Column          | Driven by                  | Meaning                                  |
| --------------- | -------------------------- | ---------------------------------------- |
| **Needs spec**  | label `status: needs spec` | Scheduled; the approach isn't written.   |
| **Ready**       | label `status: ready`      | Spec agreed; ready to implement.         |
| **In progress** | label `status: in progress`| Being worked on now.                     |
| **Merged**      | issue **closed**           | Shipped.                                 |

Lower-priority issues with **no** `status:` label are intentionally kept **off** the board.
They live in the [backlog filter](https://github.com/uchimata2/handoff-skill/issues?q=is%3Aopen+is%3Aissue+-label%3A%22status%3A+needs+spec%22+-label%3A%22status%3A+ready%22+-label%3A%22status%3A+in+progress%22)
linked from the board's README.

## How the sync works

[`.github/workflows/sync-status-to-project.yml`](.github/workflows/sync-status-to-project.yml)
runs on every issue `labeled`, `unlabeled`, `reopened`, or `closed` event. It:

1. Reads the issue's current labels and open/closed state.
2. Picks the target column — closed ⇒ **Merged**, otherwise the highest-priority `status:`
   label present (**in progress** > **ready** > **needs spec**).
3. Adds the issue to the board if it isn't there yet (idempotent), then sets its **Status** field.

An open issue with no `status:` label is left where it is — the workflow never clears a column.

### Required secret

The default `GITHUB_TOKEN` **cannot** write to a user-owned Projects v2 board, so the workflow
authenticates with a repo secret:

- **`ADD_TO_PROJECT_PAT`** — a *classic* personal access token with the **`project`** scope.

Create one at <https://github.com/settings/tokens/new?scopes=project>, then store it:

```sh
gh secret set ADD_TO_PROJECT_PAT --repo uchimata2/handoff-skill
```

> **Most common failure mode:** the PAT expired. If cards stop moving, regenerate the token and
> re-run the command above — nothing else needs to change.

## Recreating the board from scratch

If the board is ever lost, this is the sequence — including the non-obvious parts that cost time
the first time around:

1. **Scope.** `gh auth refresh -s project`. Projects v2 needs the `project` OAuth scope; the
   `repo` scope alone fails with *missing required scopes [read:project]*. (This step is
   interactive — it can't be scripted in CI.)
2. **Create.** `gh project create --owner uchimata2 --title "Handoff — Roadmap"`.
3. **Columns.** The default Status options (Todo / In Progress / Done) **cannot be renamed via
   `gh`.** Replace them in one GraphQL call — `updateProjectV2Field` with `singleSelectOptions`,
   which replaces the *entire* option set; each option needs `name` / `color` / `description`.
4. **Board view.** There is **no API mutation to create or convert a Board view** (verified by
   schema introspection). Add it once in the web UI: *New view → Board*, grouped by Status. The
   API manages fields and items only, not view layouts.
5. **Populate.** `gh project item-add` per issue, then `gh project item-edit
   --single-select-option-id …` to drop each card in its column.

### Reference IDs (maintainers)

Not secrets — opaque node IDs the workflow hard-codes. If you recreate the field or options,
update them in the workflow file too.

- Project node: `PVT_kwHOBq4P884BbSJ7`
- Status field: `PVTSSF_lAHOBq4P884BbSJ7zhWDtj0`
- Options: Needs spec `2a7723f0` · Ready `812d008e` · In progress `ba2c97a3` · Merged `6041979a`

## Lessons (the short version)

- Projects v2 ≠ `repo` scope — it needs `project`, granted interactively.
- The GraphQL API covers fields and items but **not** view layouts — boards are a UI-only setup.
- Single-select options are replaced wholesale, not renamed.
- User-owned project boards can't be written by `GITHUB_TOKEN`; automation needs a classic PAT
  with `project` scope as a secret. Its expiry is the silent failure to check first.
