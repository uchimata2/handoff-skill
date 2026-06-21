---
name: handoff
description: Transfers working context between AI sessions — any work, not just coding — so a later session, another agent, or another person can continue seamlessly. Use it when wrapping up or pausing significant work, switching agents or sessions, before a context compaction, when a handoff file exists, or when the user says handoff, hand off, resume, continue later, pick up where we left off, take over, save state, close out, or wrap up — even if they don't name the skill explicitly.
argument-hint: "What will the next session be used for?"
---

# Handoff

> Template — copy to `.claude/skills/handoff/SKILL.md` in your project and replace the
> `{{...}}` placeholders. See `../README.md` for the full install steps.

The authoritative workflow is the portable core at `{{package}}/handoff.core.md`. Open and
follow it, reading the project config at `{{config}}` for the handoff-file path, tracker,
and project docs.

- **memory:** `claude` — Claude Code has a persistent user-level memory store; use it as
  the "agent memory" store in the core's routing rules (§1–§3).

This single skill exposes every mode: invoke it with `/handoff` (or let Claude trigger it
from the description above), and the core's §4 detection picks Create (§5), Resume (§6),
Status (§6.5, a read-only preview — "show / preview / what's in the handoff"), or Close
(§5 *Close*, wrap up with no handoff — "close out / done for good") from what you say. To
expose distinct commands instead, add separate `handoff-create`, `handoff-resume`,
`handoff-status`, and `handoff-close` skills (each pointing at the relevant section) →
`/handoff-create`, `/handoff-resume`, `/handoff-status`, and `/handoff-close`; see
`../README.md`.
