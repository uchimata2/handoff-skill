---
name: handoff
description: "Transfers working context between AI sessions — any work, not just coding — so a later session, another agent, or another person can continue seamlessly. Creating or closing a handoff also reconciles your durable homes — a backward sweep that fixes stale tracker statuses, project docs, and index lines the session made out of date — and that sweep can be run on its own, mid-session, without writing a handoff. Use it when wrapping up or pausing significant work, switching chats or agents, when a chat is getting long, when a handoff file exists, or when the user says handoff, hand off, resume, continue later, pick up where we left off, take over, save state, reconcile, sweep for stale statuses, make the tracker match reality, check or validate the handoff config, close out, or wrap up — even if they don't name the skill explicitly."
---

# Handoff — claude.ai chat

> Agent stub for chats on claude.ai (web, desktop, mobile) that run inside a **Claude Project**. In
> the package, copy this file to `SKILL.md` at the top of the skill folder. It adds only what is
> specific to this environment; the workflow stays in the core.

## 0. Check that this is a claude.ai chat, then resolve `$HANDOFF`

**This file applies only in a claude.ai chat.** Section 1 replaces the core's archive rule with a
delete, which is right only for docs in a Claude Project. A skill uploaded to claude.ai also loads in
other harnesses (the Claude desktop app's Code tab is one), and there that rule would destroy a
handoff the core keeps. Decide first:

- **The Projects tool is present** (`project_read`, `project_write`): this is a claude.ai Project
  chat. Go on with this file.
- **There is no Projects tool, and you are a claude.ai chat:** go on with this file. Section 1's *No
  project attached* applies.
- **Anywhere else**, for example Claude Code working in a local project: stop reading this file.
  Follow `$HANDOFF/agents/claude.SKILL.md` instead, and skip its template banner. Read its package
  path as `$HANDOFF`. For its config path, look first for a config in the current project (commonly
  `.handoff/config.md`), then use core §0's chain. Archive handoffs by plain rename, as the core says.
  Nothing below applies.

Every path to the skill's own files is written from `$HANDOFF`, the folder this file sits in. In a
claude.ai chat the whole skill folder is copied into the code-execution sandbox when the skill loads;
read `$HANDOFF` off this file's own location there. Read the skill's files from the sandbox. Write
nothing for the project there (section 1).

## 1. Where the project's things live — read before any step

**The sandbox does not survive the chat.** A handoff written there is gone in the next chat. Every
durable home, the project config and `handoff_file` therefore live in the **Claude Project** attached
to the chat, reached with the Projects tool — never with sandbox file writes:

- read a doc: `project_read`; list docs: `project_info`; search: `project_search`;
- create or replace a doc: `project_write`, with the **whole** content. There is no patch: read the
  doc immediately before you change it, then write the full text back;
- delete a doc: `project_delete` — used only to remove a consumed or discarded handoff (below).

**Paths are project doc paths** (for example `handoff/HANDOFF.md`, `02-tasks/T-007-rules.md`). They
take the role the core gives to repo-relative paths: anyone with access to the project can open them.
"Anyone who pulls the repo" in the core means "anyone with access to the project" here. **Every path
needs a folder**: `project_write` files a new bare file name under `claude/`, so a bare name is
written to one path and read from another.

**Config.** Look first for the project doc `handoff/config.md`, then `.handoff/config.md`. If neither
exists, resolve the keys by core §0's chain and, behind one confirmation covering the doc and its
content, create `handoff/config.md` with `project_write`.

**Consumed and discarded handoffs are deleted — a deliberate deviation from core §1.** The core keeps
each consumed or discarded handoff as a renamed record. In claude.ai project chats this stub replaces
that rule: wherever a flow says *archive*, *rename*, `processed_` or `discarded_` (Resume, Discard,
Close), **delete** `handoff_file` with `project_delete` instead, and write no copy. Reasons:

- every project doc is loaded into, or searched by, every chat in the project, so old handoffs add
  noise and use shared context; Anthropic advises removing project files that are no longer used;
- a handoff only points, so its facts already live in the durable homes, and the task records'
  history keeps the trail of what each session did.

Delete only after the consuming step has read the handoff in full. If the delete fails, say so and
name the doc the user must delete by hand, so the next chat does not resume it a second time.

**Check in this environment (core §9).** Step 4: report the path as valid when it has a folder and
does not clash with a file uploaded to the project; write access itself is confirmed only by the first
real write, so say that. Flag a bare `handoff_file`. Step 6: list the project's docs with
`project_info` and report any `processed_*` or `discarded_*` doc as a leftover the user can delete.
Check itself deletes nothing.

**No project attached.** If the Projects tool is missing, there is no durable store. Say so first,
then give the handoff as text the user can paste into the next chat; task facets go under core §7.1's
named section, because no tracker can be written.

**Shared context cost.** Every project-doc write changes the knowledge that all chats in the project
load. Write each home once per run, with its final content, rather than in several small edits.

## 2. Agent-specific values

- **memory:** `none`. The handoff never writes to or relies on claude.ai memory; memory-bound items
  fall back to project docs per core §1–§3.
- **Proactive reminders.** Chat has no hooks. Two substitutes:
  - **Chat start:** skills load only when triggered, so the project instructions must ask for the
    check. Setup step — paste this into the project instructions: "At the start of every chat, check
    whether the handoff doc named in handoff/config.md exists. If it does, use the handoff skill to
    show its status and offer to resume it." When asked, run Status (core §6.5) and offer Resume.
  - **During a chat:** offer a handoff at core §4's moments — a finished task, the user stopping, a
    long chat. You cannot measure how full the context is; a long chat with many tool results is the
    signal. Offer early rather than late: a chat that hits its limit cannot run Create.

## 3. Then follow the core

The authoritative workflow is the portable core at `$HANDOFF/handoff.core.md` — the always-loaded
spine. Open and follow it, reading the project config for the handoff file, tracker and project docs.
A key that is not there is not a blocker: resolve it by core §0's chain — discover it from the
project, ask only what is left, then record what you discovered or asked. Core §4's detection then
points to one flow file — `$HANDOFF/flows/create.md`, `$HANDOFF/flows/resume.md`,
`$HANDOFF/flows/reconcile.md` or `$HANDOFF/flows/check.md`; load just that one.

The active tracker binding is the file in `$HANDOFF/bindings/` named by the `tracker` key. For task
records kept in the same Claude Project, use `claude-project` (`$HANDOFF/bindings/claude-project.md`).

Text after the handoff keyword is the handoff's **subject**, not a command to run now: the core
records it as the intended next action (core §4) and stops. A mode word — `resume`, `status`,
`close`, `reconcile`, `check` — still selects that mode.
