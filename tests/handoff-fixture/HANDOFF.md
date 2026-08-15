# Handoff — fixture, not a real handoff

> **This is a CI fixture.** It is a handoff-shaped document written in the repo-relative pointer
> style that core §3 *Portable references* asks for, so that the link check has something whose
> links depend on the file's depth. It carries no session state and is not a resume target. See
> [`README.md`](README.md) in this folder for what it guards.

## Resume here

**Continue the worked example in [`EXAMPLES.md`](../../EXAMPLES.md) — routing a single discovery.**

The next session picks it up from the routing procedure in
[`handoff.core.md`](../../handoff.core.md) §3, then follows the write path in
[`flows/create.md`](../../flows/create.md).

## Where the state is

| For | Read |
|---|---|
| The routing model, the stores, and the reconcile sweep | [`handoff.core.md`](../../handoff.core.md) |
| What Resume does with this file when it is consumed | [`flows/resume.md`](../../flows/resume.md) |
| How the config's keys resolve | [`config.example.md`](../../config.example.md) |
| The tracker operations this fixture's project would use | [`bindings/local-markdown.md`](../../bindings/local-markdown.md) |
| Install and setup | [`README.md`](../../README.md) |

## Session state

Nothing is mid-flight. Every pointer above is repo-relative and resolves from the folder this file
sits in — which is the property under test, and the one that breaks the moment an archived copy of
this document is written to a different depth.
