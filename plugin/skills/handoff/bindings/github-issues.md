# Binding: GitHub Issues

Use a repository's GitHub issues as the work tracker. Implements the binding contract
(`../handoff.core.md` §8) through the `gh` CLI — no server, no MCP, no token handling of your own.

One work item per issue. Nothing is stored in the repository: the issues are the tracker, and a
handoff points at them by URL.

## Project config it expects

- `tracker_repo` — *(optional)* `owner/name`. Defaults to the repository `gh` resolves from the
  working directory, which is right whenever the work and the issues live together.
- `tracker_status` — **how this project stores an item's status.** The one thing the binding cannot
  guess; see *Status is configured, not owned* below. One of:
  - `state` — GitHub's own open/closed. **Default.**
  - `label:<prefix>` — a `<prefix><value>` label, e.g. `label:status: ` for `status: done`.
  - `label:<prefix>+state` — the label, **and** open/closed written alongside it.
- `tracker_status_done` — *(optional)* the value meaning done, for the two label forms. Default
  `done`.
- `tracker_status_new` — *(optional)* the status a newly created item gets. **Default: none is set** —
  see the note under *create*.
- `tracker_workflow` — *(optional)* a project doc describing the conventions to follow (which
  statuses exist, when items move, comment etiquette).

## Status is configured, not owned

This binding writes a status in exactly one place: core §3a's backward sweep, *"mark finished work
done"*. That is the whole of its interest in your task schema, and it is why it knows **one** status
value — whatever `tracker_status_done` names — and defines no vocabulary, no transitions, and no
other value.

The reason it must be told rather than assume: on GitHub, "done" has three different homes depending
on whether a method is layered on top, and each choice makes the other two wrong.

| Your project | `tracker_status` | Done is written by |
|---|---|---|
| Plain GitHub, no method | `state` | `gh issue close` |
| A label is the **one stored fact** and open/closed is rendered from it (a sync workflow, or by hand) | `label:<prefix>` | setting the label — **and nothing else** |
| A label vocabulary, but nothing renders open/closed | `label:<prefix>+state` | setting the label, then closing |

The middle row is the one that bites. Where state is a rendering, `gh issue close` changes the
rendering while the stored fact stays put — the issue then contradicts itself and **no view flags
it**, because every view is computed from the fact that did not change. On the next label event the
project's own automation reverts the close, and the only evidence is a workflow run nobody reads.

The 30-second question that separates the last two rows: **does anything close issues for you?**

## Operations

**find** — an issue number → `gh issue view <n>`. Anything else → search, and report the candidates
rather than choosing:

```bash
gh issue list --repo <tracker_repo> --state all --search "<text>" --limit 100 \
  --json number,title,labels,state
```

`--state all` is not optional. `gh issue list` defaults to **open**, so a finished item — exactly what
a §3a sweep is looking for — comes back missing, and an empty result reads like an answer. `--limit`
defaults to **30**; set it above the issue count and check the result against it.

**read** — one issue whole, body and comments together:

```bash
gh issue view <n> --repo <tracker_repo> --json number,title,body,labels,state,url,comments
```

The comments are part of the item, not commentary on it: on this tracker a spec, a revision, or a
decision is usually a comment rather than a body edit, so a read that stops at the body will miss
what the item currently asks for. **Where `tracker_status` is a label form, do not report `state` as
the status** — read it from the label.

**create** — used by core §7.1 when a session has no tracked item:

```bash
gh issue create --repo <tracker_repo> --title "<title>" --body-file <file>
```

**No status label is set unless `tracker_status_new` is declared**, and that default is deliberate. A
project may treat *no status label* as a real state — an unlabelled item that is deliberately in the
backlog and off the board — and a binding that helpfully stamps a starting status would overwrite
that decision silently, every time. Labels are per-repository and `gh` will not invent one: a label
named in your config that does not exist fails the write, which is the safe direction.

**update** — write back a decision, a result, or a status.

*Prefer a comment.* Decisions and results are what handoff routes to a task (core §2), and on this
tracker a comment is where they belong — appended, attributed, timestamped, and impossible to
overwrite:

```bash
gh issue comment <n> --repo <tracker_repo> --body-file <file>
```

*Edit the body only where the project's method puts that content there* — and then round-trip the
whole body:

```bash
gh issue view <n> --repo <tracker_repo> --json body --template '{{.body}}' > body.md
# edit body.md
gh issue edit <n> --repo <tracker_repo> --body-file body.md
```

Two rules attach to that round trip:

- **`--template`, not `--jq .body`.** Both jq forms append a newline the body does not have, so the
  stored body grows one byte per round trip — compounding, and invisible in rendered Markdown.
- **There is no patch: `--body-file` replaces everything.** Sending only the part you meant to change
  deletes the rest, and **`gh` exits 0 for the destructive edit exactly as for the correct one.** No
  error means nothing here.

*A status change is one command,* whichever carrier your config names:

```bash
# tracker_status: state
gh issue close <n> --repo <tracker_repo>

# tracker_status: label:status:      (a label is the one stored fact — never also close)
gh issue edit <n> --repo <tracker_repo> --add-label "status: done" --remove-label "status: ready"

# tracker_status: label:status:+state
gh issue edit <n> --repo <tracker_repo> --add-label "status: done" --remove-label "status: ready"
gh issue close <n> --repo <tracker_repo>
```

**One combined `gh issue edit`, never two calls.** The field holds one value, so two calls leave a
window in which both labels exist; a combined edit removes before it adds.

**reference** — the **full issue URL**, optionally with the number for readability:
`[#41](https://github.com/owner/name/issues/41)`. Not a bare `#41`: a handoff is read across agents,
sessions, and sometimes outside the repository, where a bare number resolves to nothing (core §3
*Portable references*). Issue numbers are never reused, so a reference stays valid for the life of
the project.

## What §3a can reach here

This is the binding's main return. The reconcile sweep can, without leaving the CLI:

- list what the tracker still thinks is unfinished — `gh issue list --state all --json
  number,title,labels,state` — and compare it against what the session actually finished;
- set the status of each finished item through the carrier above;
- spot the contradiction the middle row warns about: with a label carrier, any issue whose `state`
  disagrees with its status label is a rendering that did not follow its fact.

## Assumptions this binding makes

Check these against the adopting project in ~30 seconds; if one is false, adapt via the project
config (or `tracker_workflow`), not this binding:

- **`gh` is installed and authenticated**, and the account can read and write issues on
  `tracker_repo`. Unlike the file bindings, every operation is a live call — availability and
  permissions can fail find / read / create / update.
- **The issues are the authoritative store.** The repository keeps no copy of item content, so
  resuming from a handoff needs access to that repository's issues. On a private repository the
  pointer resolves only for people who already have it — which satisfies core §3 *Portable
  references* for that population and nobody else.
- **Nobody closes or reopens issues by hand where `tracker_status` is a label form.** It is one click
  and it looks like finishing the task. Answer this one honestly: if your team works in the web UI as
  much as the CLI, the rendering will drift from the fact and nothing will tell you.
- **Ids are assigned by GitHub.** The issue number is the id; it cannot be known in advance, reserved,
  or renumbered. A habit of writing an id into a branch or a document before the item exists does not
  survive.
- **Every label your config names already exists in the repository.** Creating them is the one setup
  action; `gh` will not invent a label, and a mistyped name fails the write rather than mislabelling
  quietly.
- **The item is the issue, whole — body plus comments.** This binding reads nothing attached to an
  issue, so a decision whose only home is a pull-request description or a commit message has no home
  at all.
