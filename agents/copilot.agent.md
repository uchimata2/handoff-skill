---
name: handoff
description: "Transfers working context between AI sessions — any work, not just coding — so a later session, another agent, or another person can continue seamlessly. Creating or closing a handoff also reconciles your durable homes — a backward sweep for stale tracker statuses, docs, and memory the session made out of date — and that sweep can be run on its own, mid-session, without writing a handoff. Use it when wrapping up or pausing significant work, switching agents or sessions, before a context compaction, when a handoff file exists, or when the user says handoff, hand off, resume, continue later, pick up where we left off, take over, save state, reconcile, sweep for stale statuses, make the tracker match reality, check or validate the handoff config, or close out — even if they don't name the skill explicitly."
---

> Template — copy to `.github/agents/handoff.agent.md` in your project and replace the
> `{{...}}` placeholders. See `{{package}}/README.md` for the full install steps.

Transfers working context between sessions. The authoritative workflow is the portable
core at `{{package}}/handoff.core.md` — the always-loaded spine; open and follow it, reading
the project config at `{{config}}` (handoff-file path, tracker, project docs). A key that is not
there is not a blocker: resolve it by §0's chain — discover it from the project, ask only what is
left, then record what you discovered or asked. Its §4
detection then points you to the on-demand flow file for the chosen mode
(`{{package}}/flows/create.md`, `{{package}}/flows/resume.md`, `{{package}}/flows/reconcile.md`, or
`{{package}}/flows/check.md`); load just that one.

Text you pass after the handoff keyword is the handoff's **subject**, not a command to run: the
core records it as the intended next action (§4) and stops — it does not carry that work out now
(a mode word like `resume` / `status` / `close` / `reconcile` / `check` still selects that mode).

- **memory:** `none` — GitHub Copilot CLI has no persistent memory store, so memory-bound
  items fall back to project docs per the core's rules.

This wrapper exists only to expose the capability to GitHub Copilot CLI, which has no
native skills mechanism.
