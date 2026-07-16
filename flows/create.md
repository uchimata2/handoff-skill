# Handoff Skill — Create / Close flow

> On-demand flow file for the handoff **core**. Load this when the spine's §4 detection
> selects **Create** or **Close**; the read path (Resume / Status) lives in `resume.md`.
> Section references below (§2, §3, §7, §7.1, §8) point to the spine, `../handoff.core.md` —
> the routing model, session types, and binding contract stay there; this file follows them,
> it does not restate them. (§6.4 is in `resume.md`.)

## 5. Create

Goal: leave the project state consistent and produce a handoff that lets ANY next
session continue — **without** copying anything that has a durable home.

### Process

1. If a handoff already exists at `handoff_file`, show its summary and ask: overwrite it
   with the current handoff, or keep the existing one and stop. If keep → stop.
2. **Route every session discovery through §3 first.** This is the important step:
   - task-specific facets → task docs (via the active binding);
   - generic facets → project docs and / or memory;
   - update statuses, decisions, results, and references in their proper homes so they
     are not undocumented progress.

   Do this *before* writing the handoff, so the handoff can simply point to the updated
   homes.

   After routing new facts forward, **reconcile the existing homes** the session touched
   (core §3a): mark finished tracker items done and move them per the binding; close umbrella /
   review items whose parts are all resolved; correct superseded project-doc / memory / index
   lines; and confirm every pointer still resolves. If the config sets `reconcile_targets`, sweep
   exactly those. This backward pass is as required as the forward one.
3. **Write the handoff file** (`handoff_file`) with only:
   - the work item to resume (pointer / id / reference) and the intended next action;
   - pure session-ephemeral state per §2 (what isn't, and shouldn't be, recorded elsewhere);
   - pointers to the relevant homes (task, plan, project docs) — by reference to a commonly
     accessible home, not copied, and never to agent-private memory (see *Portable references*).

   Keep it short; if it's getting long, you're probably storing things that belong in a
   durable home — go back to step 2.
4. **Scan the handoff before saving or committing it.** Re-read what you wrote and strip
   anything caught by the §3 step-1 exclusion gate. Pre-write / commit checklist:
   - [ ] No secrets (API keys, tokens, passwords, connection strings, credential-bearing URLs).
   - [ ] No OS usernames or home directories.
   - [ ] No absolute / local paths outside the repo — use repo-relative paths instead.
   - [ ] No hostnames, IP, or MAC addresses.
   - [ ] No local environment-variable values or machine / OS specifics.
   - [ ] No contents copied from a local / private memory store — reference shared homes instead.
   - [ ] Ephemeral notes are generic, with no identifiers (§2).

   **Reconciliation checklist (in addition to the secrets/privacy scan; see core §3a):**
   - [ ] Every task the session finished is marked done and moved to the closed location.
   - [ ] No open tracker item's status contradicts the session's work; umbrella items with all
         parts resolved are closed.
   - [ ] No project-doc, memory, or index/summary line contradicts a newer verified fact.
   - [ ] Every pointer in the handoff resolves (no link to a moved or closed path).

   If the project ships a security policy with its own handoff checklist, apply that too
   (if present).
5. If the session was **ad-hoc** (no task), follow §7.1 first (offer to create a tracked
   item; only if declined may task-like specifics live in the handoff snapshot).

### What a good handoff looks like

- Reads in under a minute.
- Names *where* to continue, not *what the task is*.
- Contains nothing a reader could already get from the task docs or project docs.

### Close — wrap up without a handoff

Close ends a session **in a consistent state with no resume pointer** — it is Create minus
the handoff file: do all the durable-homes work, then stop without writing `handoff_file`.
Use it when the session is finished, not being handed off.

1. **Route every session discovery through §3** to its proper home — task docs / project
   docs / memory — updating statuses, decisions, results, and references (the *Process*
   step 2 above). The §3 step-1 exclusion gate still applies, so secrets and private data
   never reach a durable home. Then **reconcile the existing homes for staleness** exactly as
   Create *Process* step 2 (core §3a) — Close must not leave the tracker or memory contradicting
   the final state either.
2. **Resolve any live handoff** at `handoff_file`. Since the session is being closed, not
   handed off, no live resume pointer may remain: archive it (rename to the
   `processed_<timestamp>` form, as §6.4). Its content already lives in durable homes — the
   handoff only pointed — so nothing is lost.
3. **Write no handoff file.** Skip *Process* steps 3–4 (handoff write + scan): there is no
   snapshot to produce.
4. **Confirm the workspace is left consistent.**

**Ad-hoc edge:** in an ad-hoc session, §7.1 normally lets declined task specifics fall back
into the handoff snapshot — but Close writes no handoff, so that fallback doesn't exist.
Close still makes the §7.1 offer to create a tracked item; if the user **declines**, say
plainly that the untracked specifics will have **no durable home** (offer Create instead, or
proceed and drop them) — never lose them silently.
