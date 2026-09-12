---
name: handoff
description: Transfers working context between AI sessions — any work, not just coding — so a later session, another agent, or another person can continue seamlessly. Creating or closing a handoff also reconciles your durable homes — a backward sweep that fixes stale tracker statuses, project docs, memory, and index lines the session made out of date — and that sweep can be run on its own, mid-session, without writing a handoff. Use it when wrapping up or pausing significant work, switching agents or sessions, before a context compaction, when a handoff file exists, or when the user says handoff, hand off, resume, continue later, pick up where we left off, take over, save state, reconcile, sweep for stale statuses, tidy up stale statuses, make the tracker match reality, check or validate the handoff config, close out, or wrap up — even if they don't name the skill explicitly.
argument-hint: "What will the next session be used for?"
---

# Handoff

## 0. Resolve `$HANDOFF` first, before following any path below

Every path in this skill is written from `$HANDOFF`, the directory this file sits in — the package
travels with the skill. A bare path would resolve against the user's project, which may have files
of these names itself.

**Read it off this file's own location.** A harness that loads a skill names the directory it loaded
it from, and `$HANDOFF` is that directory. That answer stays correct for a copy of this plugin
published under another name.

The authoritative workflow is the portable core at `$HANDOFF/handoff.core.md` — the
always-loaded spine. Open and follow it, reading the project config for the handoff-file path, tracker, and project docs. Look first for a
project-local config in the current project (commonly `.handoff/config.md`); if none exists,
resolve the missing keys by the core's §0 chain — discover them from the project, ask only what is
left, and record the result. **A key that is not there is not a blocker** — resolve
it by §0's chain: discover it from the project, ask only what is left, then record what you
discovered or asked, so the next session does not repeat it. Its §4 detection then points you to the
on-demand flow file for the chosen mode (`$HANDOFF/flows/create.md`,
`$HANDOFF/flows/resume.md`, `$HANDOFF/flows/reconcile.md`, or `$HANDOFF/flows/check.md`);
load just that one.

- **memory:** `claude` — Claude Code has a persistent user-level memory store; use it as
  the "agent memory" store in the core's routing rules (§1–§3).
- **Proactive reminders (optional):** wire Claude Code hooks to nudge you to handoff or close
  at session start and before a compaction — see `$HANDOFF/agents/claude.hooks.md`.
- **Reconcile (built in, and available alone):** Create and Close run the core's §3a backward
  sweep — fixing stale tracker statuses, docs, memory, and index lines — before finishing, not only
  routing new work forward. It runs automatically as part of those modes, and **Reconcile (§10)** is
  the same sweep asked for on its own, mid-session: it corrects the durable homes, reports what it
  changed, and leaves the handoff file untouched.

This single skill exposes every mode: invoke it with `/handoff` (or let Claude trigger it
from the description above), and the core's §4 detection picks Create (§5), Resume (§6),
Status (§6.5, a read-only preview — "show / preview / what's in the handoff"), Close
(§5 *Close*, wrap up with no handoff — "close out / done for good"), Reconcile (§10, the staleness
sweep on its own — "reconcile / make the tracker match reality"), or Check (§9, validate the
config — "check the config / handoff doctor") from what you say.

**Anything you type after `/handoff` is the handoff's *subject*, not a command to run now.**
`/handoff work on TASK-42 next` means *write a handoff whose next action is "work on TASK-42"* — the
core records that text (§4) and stops; it does **not** start the task. Writing the handoff is the
task. (A mode word — `/handoff resume` / `status` / `close` / `reconcile` — still selects that
mode.)

To expose distinct commands instead, add separate `handoff-create`, `handoff-resume`,
`handoff-status`, `handoff-close`, `handoff-reconcile`, and `handoff-check` skills — each pointing
straight at its flow file for an even leaner load (`handoff-create` / `handoff-close` →
`$HANDOFF/flows/create.md`; `handoff-resume` / `handoff-status` → `$HANDOFF/flows/resume.md`;
`handoff-reconcile` → `$HANDOFF/flows/reconcile.md`; `handoff-check` →
`$HANDOFF/flows/check.md`) → `/handoff-create`, `/handoff-resume`, `/handoff-status`,
`/handoff-close`, `/handoff-reconcile`, and `/handoff-check`; see `$HANDOFF/README.md`.
