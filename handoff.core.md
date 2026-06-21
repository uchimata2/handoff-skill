# Handoff Skill — Core

> Portable, project- and agent-neutral body of the handoff skill. It contains **no**
> project, tracker, or agent specifics — those live in the per-project **config** and
> the **tracker bindings** (`bindings/`). Don't edit this file to fit one project;
> change the config instead. To reuse the skill in another project, copy this package
> and write a config — see `README.md`.

Handoffs let any working session — a later session, another agent, or another person —
pick up work seamlessly, while upholding a strict **single source of truth**: every
fact has exactly one home, and the handoff only *points* to those homes.

This core is consumed two ways:

- **Create** a handoff when wrapping up or switching agents (§5).
- **Resume** from an existing handoff when starting fresh (§6).

---

## 0. Configuration

Two sources feed the core:

- the project **config** (one file per project; your agent's stub names its path) — see
  `config.example.md` for the schema;
- your **agent's stub**, which supplies anything agent-specific (currently just `memory`,
  since memory mechanisms differ from one agent to the next).

Read these keys; if one is absent, use the fallback.

| Key | Source | Meaning | Fallback |
|---|---|---|---|
| `handoff_file` | project config | Path to the live handoff document | Ask the user |
| `tracker` | project config | Active tracker binding (a file in `bindings/`), or `none` | `none` — every session is ad-hoc (§7) |
| `tracker_*` | project config | Binding-specific settings the active binding reads | per binding |
| `project_docs` | project config | Where durable project docs live (instructions, standards, guidelines) | Ask the user |
| `language` | project config | Language for written artifacts | Match the task / source |
| `memory` | agent stub | The agent's persistent memory mechanism, or `none` | `none` — memory-bound items fall back to project docs |

Everything tracker-specific (how to find / read / create / update a work item) lives in
the active binding (§8), configured by its `tracker_*` keys.

---

## 1. The four stores

Every piece of information from a session belongs to exactly one of these. A single
*discovery* may split into several facts, each with its own home (§3).

| Store | What it holds | Lifetime / scope |
|---|---|---|
| **Handoff file** | A pointer to what to resume + pure session-ephemeral state | One live snapshot, consumed once by the next session |
| **Task docs** | Everything needed to work one task independently | Durable; lives in the tracker (via the active binding) |
| **Project docs** | Project-wide conventions, standards, workflow, tooling, onboarding | Durable; shared by all agents and people on the project |
| **Agent memory** | Durable, cross-project, agent/user-private preferences & reusable lessons | Durable; private to one agent; **optional** |

---

## 2. Routing matrix

For each store — what belongs in it, and what must stay out.

**Handoff file**

- IN: which work item to pick up next (a pointer / id / reference only); the intended
  next action (e.g. "resume planning the task"); pure session-ephemeral state recorded
  nowhere else and not worth keeping permanently (uncommitted working state, "stopped
  mid-step 3", a transient session quirk described generically — no usernames, absolute
  local paths, hostnames, IPs, or env values); pointers to **commonly accessible** homes —
  the tracker / work item, repo files, or public URLs — reachable by anyone who pulls the repo.
- OUT: any task-specific content (requirements, plans, findings, file lists, copied
  next-steps); anything already in project docs or memory; reusable lessons; task
  references that belong on the task; restated workflow / how-tos; **secrets and
  user-/machine-private data** (per §3 step 1 — usernames, home or absolute local paths,
  hostnames, IP/MAC addresses, local env values, copied local-memory contents); **pointers
  that resolve only to agent-private memory**, and anything that lives only in local memory.

**Task docs**

- IN: requirements; plan and progress; task-specific decisions and their rationale;
  what was tried and failed *for this task*; task-specific gotchas; useful references;
  test / verification results.
- OUT: project-wide conventions; the generic facet of a lesson (that goes to project
  docs or memory).

**Project docs**

- IN: conventions, standards, workflow, tooling / environment rules, onboarding, and
  *generic lessons that generalize beyond one task*.
- OUT: task specifics; ephemeral session state; agent-private preferences.

**Agent memory** (optional)

- IN: durable, cross-project, agent / user-private preferences and reusable lessons not
  appropriate to commit to a shared repository.
- OUT: task facts; project facts that belong in the repository (commit those so everyone
  benefits); secrets. If memory is unavailable, shareable items fall back to project
  docs; the rest are dropped.

---

## 3. Routing procedure

Run this for **each** piece of information surfaced during the session. A single
discovery can match more than one step — when it does, write **each facet** to its home
(e.g. a bug you hit may yield a task-specific fix note *and* a reusable project rule;
both get written, at their own altitude).

1. **Secret, sensitive, or user-/machine-private?** → **exclude it; store it nowhere.**
   This single gate covers three things that must never enter a handoff (or any durable
   home it points to):
   - **Secrets** — API keys, tokens / JWTs, passwords, connection strings, credential-bearing
     URLs. How to strip them safely: *Redacting secrets*, below.
   - **User-/machine-identifying data** — OS usernames, home directories, absolute or local
     paths outside the repo, hostnames, IP / MAC addresses, local environment-variable values,
     machine / OS specifics.
   - **Contents of a local or private memory store** — don't copy them in; a *reference* to a
     shared, publicly reachable home is fine.

   *Allowed* (generic, non-identifying ephemeral state): "stopped mid-step 3 of 5",
   "uncommitted changes in the working tree", "a local preview process is still running";
   repo-relative paths; branch names; port numbers.
2. **Has a task-specific facet?** → write it to the **task docs** (via the active binding).
3. **Has a generic / reusable facet?** →
   - project-scoped and shareable → **project docs**;
   - else cross-project or agent / user-private → **agent memory** if available; else
     project docs if shareable; else drop.
4. **Pure session-ephemeral state**, recorded nowhere else and not worth keeping? →
   **handoff file**.
5. **Otherwise it already has a home** → in the handoff, only **point** to it — provided
   that home is reachable by whoever resumes (see *Portable references*). If the sole home
   is agent-private memory, the handoff can't rely on it: promote the shareable facet to
   task or project docs (per step 3) and point there, or omit it.

The golden rule: **the handoff points, it does not store.** If a fact has any durable
home (task, project, memory), it goes there; the handoff at most references it.

**Portable references:** a handoff is cross-agent, cross-user, and cross-session — every
pointer in it must resolve for anyone who pulls the repo (the tracker / work item, repo
files, or public URLs). It must never point at, or depend on, an agent's local / private
memory; memory may still hold private lessons, but resuming must not require them.

### Redacting secrets

When step 1 catches a **secret**, redacting it is not masking — it means the value lives
**nowhere** (not in the handoff, task docs, project docs, or memory):

- **Omit the value.** If the secret's *existence* matters for continuity, reference its
  **location or name** — "the deploy token, kept in the team vault" — never the value itself.
- **If structure must be shown, use an obvious placeholder** (`<REDACTED>`, `<API_KEY>`).
  Never paste a partial or truncated real value — a prefix still leaks.
- **Don't park it "temporarily"** in a scratch note, comment, or commit message on the way
  to somewhere else — that is still storing it.

This applies to every secret category in step 1 (API keys, tokens / JWTs, passwords,
connection strings, credential-bearing URLs). Before saving or sharing, the §5 pre-write
checklist scans for exactly these.

### Worked examples

**A discovery with two facets.** While doing a task you find that a tool silently does
nothing unless a flag is set.

- *task-specific facet* — this task's step needs that flag → **task docs**.
- *generic facet* — the tool needs the flag in general → **project docs** (or **memory**
  if it's a personal preference).
- *handoff* — nothing: both facets now have durable homes.

**Pure ephemeral state.** You stopped half-way through a multi-part change.

- recorded nowhere else and not worth keeping → **handoff file** ("stopped mid-way
  through step 3 of 5").
- once the work lands in the task or is finished, it leaves the handoff.

---

## 4. Detection

### Triggers

Activate when the user says things like: "handoff", "hand off", "pass this to",
"continue later", "pick up where", "transfer context", "save state", "resume",
"take over".

### Create vs resume

- User is **wrapping up**, stopping, or switching agents → **Create** (§5).
- User is **starting fresh** and a handoff exists at `handoff_file` → **Resume** (§6).

### Proactive suggestion

Consider offering a handoff when: the user signals they're stopping ("I need to go",
"let's stop here"); a significant milestone is reached; the session has accumulated a
lot of context; a context compaction is near; or the session has idled for a while.

Ask: "Want me to create a handoff so you (or another agent) can continue later?"

---

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

   If the project ships a security policy with its own handoff checklist, apply that too
   (if present).
5. If the session was **ad-hoc** (no task), follow §7.1 first (offer to create a tracked
   item; only if declined may task-like specifics live in the handoff snapshot).

### What a good handoff looks like

- Reads in under a minute.
- Names *where* to continue, not *what the task is*.
- Contains nothing a reader could already get from the task docs or project docs.

---

## 6. Resume

### 6.1 Find and read

Look for the handoff at `handoff_file`. If absent, tell the user there's no prepared
session to continue. Read it fully.

### 6.2 Summarize

Give a brief summary (not the whole file):

```text
Resuming from handoff: <title>

<short summary>
```

### 6.3 Confirm

Ask: "Resume / Keep it for later / Discard?".

- **Resume** → §6.4.
- **Keep** → leave it untouched.
- **Discard** → archive it (rename to a `discarded_<timestamp>` form alongside the file).

### 6.4 Continue

1. Open the pointed-to homes (task docs via the active binding, plan, project docs) and
   read them — the handoff intentionally does **not** duplicate them.
2. Archive the handoff (rename to a `processed_<timestamp>` form) so it isn't resumed twice.
3. Start the work as described.
4. If the handoff is unclear on something critical, ask the user rather than guess.

---

## 7. Session types

The routing rules are content-based, so they apply unchanged across all four combinations:

| | **Ticketed** (a tracked work item exists) | **Ad-hoc** (no tracked item) |
|---|---|---|
| **Development** | Normal flow; task facets → task docs. | §7.1 |
| **Non-development** (research, writing, ops, …) | Same flow; "task docs" = the tracked item, no code assumed. | §7.1 |

### 7.1 Ad-hoc sessions

When there is no tracked work item (or `tracker: none`):

1. **Offer to create one** via the active binding, so task facts get a durable home.
2. If the user **declines**, the otherwise-task-specific specifics may be captured in the
   handoff snapshot — the **single allowed exception** to §2, because no task home exists yet.
3. Once a tracked item is created, move those specifics into it and out of the handoff.

Bindings, examples, and project docs must not assume code, version control, or any
specific domain — that's what keeps the skill usable for non-development work.

---

## 8. Tracker binding contract

The core never names a tracker. The active binding (`tracker` in config → a file in
`bindings/`) must provide these operations; everything tracker-specific lives there:

- **find** — locate a work item from a reference the user gives (id, title, link).
- **read** — fetch an item's full content (description, plan, status, comments).
- **create** — make a new work item (used by §7.1).
- **update** — write back to an item (status, decisions, results, comments, references).
- **reference** — produce a stable pointer to an item (id / link / path) for the handoff.

If `tracker: none`, there is no binding: every session is treated as ad-hoc (§7.1) and
the create offer instead proposes setting up a tracker or using the handoff snapshot.
