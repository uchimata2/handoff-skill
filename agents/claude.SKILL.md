---
name: handoff
description: Transfers working context between AI sessions — any work, not just coding — so a later session, another agent, or another person can continue seamlessly. Use it when wrapping up or pausing significant work, switching agents or sessions, before a context compaction, when a handoff file exists, or when the user says handoff, hand off, resume, continue later, pick up where we left off, take over, or save state — even if they don't name the skill explicitly.
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

In Claude Code, expose the two flows as the slash commands `/handoff:create` and
`/handoff:resume`, mapping to the Create (§5) and Resume (§6) sections of the core. Add the
matching `commands/create.md` and `commands/resume.md` pointers (see `../README.md`).
