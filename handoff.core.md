# Handoff Skill — Core

> Portable, project- and agent-neutral body of the handoff skill. It contains **no**
> project, tracker, or agent specifics — those live in the per-project **config** and
> the **tracker bindings** (`bindings/`). Don't edit this file to fit one project;
> change the config instead. To reuse the skill in another project, copy this package
> and write a config — see `README.md`.

Handoffs let any working session — a later session, another agent, or another person —
pick up work seamlessly, while upholding a strict **single source of truth**: every
fact has exactly one home, and the handoff only *points* to those homes.

This core is consumed four ways — **Create** (wrapping up / switching agents, §5), **Resume**
(starting fresh, §6), **Status** (preview without changing anything, §6.5), and **Close** (wrap
up leaving no handoff, §5 *Close*).

It is split for **progressive disclosure**: this file is the always-loaded **spine** (§0–§4,
§7–§8 — configuration, routing model, detection, session types, binding contract). Each mode's
*steps* live in an on-demand **flow file** that §4 directs you to load — `flows/create.md`
(Create / Close) or `flows/resume.md` (Resume / Status); a run loads the spine plus one flow,
never both.

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
| `reconcile_targets` | project config | Homes to sweep for staleness on Create / Close — paths, globs, or named stores (tracker folder, memory files, index docs) | The durable homes the session touched (§3a) |
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
- OUT — never goes in the handoff:
  - task-specific content (requirements, plans, findings, file lists, copied next-steps);
  - anything that already has a durable home — reusable lessons, task references, and
    **restated workflow / how-tos, including a procedure another skill or doc already
    defines** (point to the authoritative source, don't describe it);
  - **secrets and user-/machine-private data** — the §3 step-1 exclusion gate;
  - **pointers that resolve only to agent-private memory**, and anything that lives only there.

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

**Reference, don't restate:** if another skill, doc, or tool already defines *how* to
proceed, the handoff (and the core) **point** to that authoritative source rather than
copying its steps — restating it risks drift and breaks single source of truth.

### 3a. Reconcile — routing runs in both directions

§3 routes each *new* discovery **forward** to its home. A session also **invalidates** facts that
already have homes: a finished task still marked open, an umbrella item whose findings are now all
resolved, a project-doc or memory line the session made false, a pointer that now targets a moved
file. These are **undocumented regressions** — the mirror image of undocumented progress, and just
as much a single-source-of-truth failure.

So before writing (Create) or closing (Close) a handoff, **sweep the durable homes the session
touched and reconcile them with the new state**:

- **statuses** — mark finished work done and move it per the tracker binding; close umbrella /
  review items whose parts are all resolved; leave genuinely-paused work open (don't close what's
  only parked);
- **superseded content** — correct or remove statements a later verified fact overrode, including
  index / summary lines;
- **pointers** — every reference (in the handoff, task docs, project docs) still resolves.

The test: the tracker, the project docs, the memory, and the handoff must tell the **same, current**
story. Where two disagree, the most recent verified fact wins — fix the others. If the project
config declares `reconcile_targets` (§0), sweep those explicitly; otherwise sweep the homes the
session touched.

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
connection strings, credential-bearing URLs). Before saving or sharing, the Create flow's
pre-write checklist (`flows/create.md` §5) scans for exactly these.

For worked examples of this routing in action — a two-facet discovery, pure ephemeral state,
and a workflow owned elsewhere — see [`EXAMPLES.md`](EXAMPLES.md) *§8 Routing a single discovery*.

---

## 4. Detection

### Triggers

Activate when the user says things like: "handoff", "hand off", "pass this to",
"continue later", "pick up where", "transfer context", "save state", "resume",
"take over". Read-only previews also activate: "what's in the handoff", "show /
preview / summarize the handoff", "status of the handoff", "is there a handoff".
Closing words also activate: "handoff close", "close out", "wrap up — no handoff",
"done for good".

### Create, resume, status, or close

- User is **wrapping up**, stopping, or switching agents → **Create** (§5).
- User is **starting fresh** and a handoff exists at `handoff_file` → **Resume** (§6).
- User wants to **see what's in the handoff** without consuming it (preview / show /
  summarize / status) → **Status** (§6.5) — read-only, no changes.
- User wants to **wrap up without leaving a handoff** (explicit "close out", "done for
  good", "wrap up — no handoff") → **Close** (§5, *Close*).

When intent is ambiguous between resume and status, default to the **non-mutating**
path: summarize (Status), then offer to resume — never archive on a maybe.

A bare "wrap up" or "I'm done" is ambiguous between Create and Close — they leave
different end states (a resume pointer vs none), so **ask** ("leave a resume pointer
(handoff), or close out with none?") rather than guess.

### Load the relevant flow

Each mode's steps live in an on-demand flow file. Once you've picked the mode, load **only**
that file and follow it — a Create/Close run never needs the Resume/Status flow, and
vice-versa:

- **Create** (§5) or **Close** (§5, *Close*) → `flows/create.md`.
- **Resume** (§6) or **Status** (§6.5) → `flows/resume.md`.

The routing model (§1–§3), session types (§7), and binding contract (§8) stay here in the
spine; the flow files reference them, never restate them.

### Proactive suggestion

Consider offering a handoff when: the user signals they're stopping ("I need to go",
"let's stop here"); a significant milestone is reached; the session has accumulated a
lot of context; a context compaction is near; or the session has idled for a while.

Ask: "Want me to create a handoff so you (or another agent) can continue later?"

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
