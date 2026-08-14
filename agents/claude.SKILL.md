---
name: handoff
description: Transfers working context between AI sessions — any work, not just coding — so a later session, another agent, or another person can continue seamlessly. Creating or closing a handoff also reconciles your durable homes — a backward sweep that fixes stale tracker statuses, project docs, memory, and index lines the session made out of date. Use it when wrapping up or pausing significant work, switching agents or sessions, before a context compaction, when a handoff file exists, or when the user says handoff, hand off, resume, continue later, pick up where we left off, take over, save state, reconcile or sweep stale statuses, check or validate the handoff config, close out, or wrap up — even if they don't name the skill explicitly.
argument-hint: "What will the next session be used for?"
---

# Handoff

> Template — copy to `.claude/skills/handoff/SKILL.md` in your project and replace the
> `{{...}}` placeholders. See `{{package}}/README.md` for the full install steps.

The authoritative workflow is the portable core at `{{package}}/handoff.core.md` — the
always-loaded spine. Open and follow it, reading the project config at `{{config}}` for the
handoff-file path, tracker, and project docs. Its §4 detection then points you to the
on-demand flow file for the chosen mode (`{{package}}/flows/create.md`,
`{{package}}/flows/resume.md`, or `{{package}}/flows/check.md`); load just that one.

- **memory:** `claude` — Claude Code has a persistent user-level memory store; use it as
  the "agent memory" store in the core's routing rules (§1–§3).
- **Proactive reminders (optional):** wire Claude Code hooks to nudge you to handoff or close
  at session start and before a compaction — see `{{package}}/agents/claude.hooks.md`.
- **Reconcile (built in):** Create and Close run the core's §3a backward sweep — fixing stale
  tracker statuses, docs, memory, and index lines — before finishing, not only routing new work
  forward. It runs automatically as part of those modes.

This single skill exposes every mode: invoke it with `/handoff` (or let Claude trigger it
from the description above), and the core's §4 detection picks Create (§5), Resume (§6),
Status (§6.5, a read-only preview — "show / preview / what's in the handoff"), Close
(§5 *Close*, wrap up with no handoff — "close out / done for good"), or Check (§9, validate the
config — "check the config / handoff doctor") from what you say.

**Anything you type after `/handoff` is the handoff's *subject*, not a command to run now.**
`/handoff work on TASK-42 next` means *write a handoff whose next action is "work on TASK-42"* — the
core records that text (§4) and stops; it does **not** start the task. Writing the handoff is the
task. (A mode word — `/handoff resume` / `status` / `close` — still selects that mode.)

To expose distinct commands instead, add separate `handoff-create`, `handoff-resume`,
`handoff-status`, `handoff-close`, and `handoff-check` skills — each pointing straight at its flow
file for an even leaner load (`handoff-create` / `handoff-close` → `{{package}}/flows/create.md`;
`handoff-resume` / `handoff-status` → `{{package}}/flows/resume.md`; `handoff-check` →
`{{package}}/flows/check.md`) → `/handoff-create`, `/handoff-resume`, `/handoff-status`,
`/handoff-close`, and `/handoff-check`; see `{{package}}/README.md`.
