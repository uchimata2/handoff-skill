# Handoff Skill — Core

> Portable, project- and agent-neutral body of the handoff skill. It contains **no**
> project, tracker, or agent specifics — those live in the per-project **config** and
> the **tracker bindings** (`bindings/`). Don't edit this file to fit one project;
> change the config instead. To reuse the skill in another project, copy this package
> and write a config — see `README.md`.

Handoffs let any working session — a later session, another agent, or another person —
pick up work seamlessly, while upholding a strict **single source of truth**: every
fact has exactly one home, and the handoff only *points* to those homes.

This core is consumed six ways — **Create** (wrapping up / switching agents, §5), **Resume**
(starting fresh, §6), **Status** (preview without changing anything, §6.5), **Close** (wrap
up leaving no handoff, §5 *Close*), **Reconcile** (the §3a sweep on its own, mid-session, §10), and
**Check** (validate the config before a session depends on it, §9).

It is split for **progressive disclosure**: this file is the always-loaded **spine** (§0–§4,
§7–§8 — configuration, routing model, detection, session types, binding contract). Each mode's
*steps* live in an on-demand **flow file** that §4 directs you to load — `flows/create.md`
(Create / Close), `flows/resume.md` (Resume / Status), `flows/reconcile.md` (Reconcile), or
`flows/check.md` (Check); a run loads the spine plus one flow, never more.

---

## 0. Configuration

Two sources feed the core:

- the project **config** (one file per project; your agent's stub names its path, or
  `.handoff/config.md` by convention) — see `config.example.md` for the schema. **It may not exist
  yet, and that is an ordinary starting state**, not an error;
- your **agent's stub**, which supplies anything agent-specific (currently just `memory`,
  since memory mechanisms differ from one agent to the next).

Every key resolves by the same chain, and the first step that answers wins:

1. **Declared** — a value in the project config. It always wins; a person chose it.
2. **Discovered** — read from the project itself, and only where the evidence can be **named**.
   A value that cannot say where it came from was not discovered, it was guessed.
3. **Asked** — put the question to the user, then **record the answer**, so the next session does
   not ask it again.

Discovery looks at whatever the project has, and some projects have nothing to read — no repository,
no instruction file, no code (§7). There the chain falls straight through to *ask*. That is a normal
outcome, not a failure, and **discovery must never require a repository, version control, or code.**

| Key | Source | Meaning | If not declared |
|---|---|---|---|
| `handoff_file` | project config | Path to the live handoff document | **Not discovered** — a path is a choice, not a fact about the project. Default `.handoff/HANDOFF.md` |
| `tracker` | project config | Active tracker binding (a file in `bindings/`), or `none` | Discover: the project's instruction file naming where tasks live, or a tracker-shaped folder or config. Two sources disagreeing is not a discovery — ask. Else `none` — every session is ad-hoc (§7) |
| `tracker_*` | project config | Binding-specific settings the active binding reads | per binding |
| `project_docs` | project config | Where durable project docs live (instructions, standards, guidelines) | Discover: the instruction files the agent already loads, and what they point at. Else ask |
| `language` | project config | Language for written artifacts | Not discovered — match the task / source |
| `reconcile_targets` | project config | **Extra** homes to sweep for staleness on Create / Close / Reconcile, on top of the ones the session touched — paths, globs, or named stores (tracker folder, memory files, index docs). A floor, not a ceiling (§3a) | **Neither discovered nor asked** — it is a judgement about which homes go stale silently, and nobody knows that at setup. Absent means sweep the durable homes the session touched (§3a); sessions add to it |
| `memory` | agent stub | The agent's persistent memory mechanism, or `none` | `none` — memory-bound items fall back to project docs |

**Recording what the chain answered.** An asked answer and a discovered one are both written to the
project config, so the chain does not re-run every session — the discovered ones **marked with where
they came from**: `tracker: github-issues (discovered: AGENTS.md, 2026-08-16)`. A marked value is a
**cache, not a second home**: Check (§9) re-derives it and reports drift, which is what keeps the
project's own statement authoritative. An unmarked value is declared, and nothing re-checks it.
Where no config exists, create one at `.handoff/config.md` — behind **one** confirmation covering
both the file and what goes in it, because a wrong tracker is written to silently.

Everything tracker-specific (how to find / read / create / update a work item) lives in
the active binding (§8), configured by its `tracker_*` keys.

**A key that is present but will not resolve is a config defect, not a session problem** — a
`tracker` naming a binding that isn't there, a `handoff_file` under a folder that was never created.
The chain above covers an *absent* key; it does not cover a wrong one. Say what failed and point
at **Check** (§9), which reports the lot at once. Working around it silently mid-run leaves the
project with the same broken config and one more session that quietly coped.

**A discovery that contradicts a declared value is not resolved at run time.** The declared value
wins and the run continues without comment. The disagreement is a **Check** finding, because it
usually means the project moved and the config did not — a reconcile-shaped problem (§3a), not
something to stop a Create over.

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

**Archived handoffs are records, not handoffs.** Consuming or discarding one **renames** it
(`processed_` / `discarded_`, §6.4) rather than deleting it, so archives accumulate — roughly one per
session, which is expected and not a leak. Three rules follow:

- **Archiving preserves the file's depth — it is a rename, never a move.** A handoff's body is
  written against the directory it sits in: §3 asks for repo-relative pointers, so a handoff at
  `.handoff/HANDOFF.md` reaches its project docs as `../docs/…`. Move it one level deeper and every
  such pointer resolves somewhere else — at the exact moment the document stops being editable and
  becomes a record. So the rename happens **in place, beside `handoff_file`**, which also keeps
  `processed_` and `discarded_` sorted together. **The skill never relocates records**: archives a
  project already keeps in a folder of their own stay exactly where they are, and no upgrade moves
  them. That is a limit on the skill, not an instruction to the project — moving such an archive
  back beside `handoff_file` restores the pointers that broke when it was moved there, and that
  repair is the project's to make.
- **Only `handoff_file` is live.** An archive is never a resume candidate, however recent.
- **Never delete one.** They are the project's records and the only evidence of what a past session
  claimed. Pruning is the project's decision, taken outside a handoff run; whether they are tracked
  at all is a setup choice made where `handoff_file` is chosen.

The rule is defined here rather than in a flow because `create.md` archives on Close and
`resume.md` archives on Resume and Discard, and the two never load in the same run (§4).

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
  - **derived values** — counts, durations, sizes, rates — carried as a *value* instead of as a
    pointer to what produces them (the §3 rule *Derived values decay*);
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
   **handoff file**. A **measured or counted value is not this**, however much it looks like it —
   see *Derived values decay*, below.
5. **Otherwise it already has a home** → in the handoff, only **point** to it — provided
   that home is reachable by whoever resumes (see *Portable references*). If the sole home
   is agent-private memory, the handoff can't rely on it: promote the shareable facet to
   task or project docs (per step 3) and point there, or omit it.

The golden rule: **the handoff points, it does not store.** If a fact has any durable
home (task, project, memory), it goes there; the handoff at most references it.

**Derived values decay, and they do not look like it.** A count, a duration, a size, a rate is
**produced** by something, and prose hides that: "the full run takes 7–11 minutes" reads as a
description, not as one measurement taken once. The next session has nothing to distrust, so the
value is copied forward untested — and a number is wrong silently, where a stale sentence usually
reads as odd. Route it by how hard it is to produce again:

- **cheap to re-derive** (a count, a status, anything a command or a view answers) → point at **what
  answers it**, never at the value. One line, and it cannot go stale;
- **expensive to re-derive** (a measurement, a timing) → it is a **finding**: send it to its durable
  home per steps 2–3, recorded with **what was measured and when**, then point there;
- **neither** → leave it out.

This is the golden rule applied where it is least obvious. A value feels like state rather than like
a fact with a home, so it passes step 4 honestly and lands in the handoff, where nothing will ever
check it again.

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

So before writing (Create) or closing (Close) a handoff — or whenever **Reconcile** (§10) is asked
for on its own, mid-session — **sweep the durable homes the session touched and reconcile them with
the new state**:

- **statuses** — mark finished work done and move it per the tracker binding; close umbrella /
  review items whose parts are all resolved; leave genuinely-paused work open (don't close what's
  only parked);
- **superseded content** — correct or remove statements a later verified fact overrode, including
  index / summary lines;
- **pointers** — every reference (in the handoff, task docs, project docs) still resolves.

The test: the tracker, the project docs, the memory, and the handoff must tell the **same, current**
story. Where two disagree, the most recent verified fact wins — fix the others.

**Always sweep the durable homes the session touched.** If the project config declares
`reconcile_targets` (§0), sweep those **as well** — a declared list is a **floor, never a ceiling**.
It exists to catch the homes that go stale *silently*, the ones a session invalidates without opening:
the index, the decisions or lessons file, the tracker. Being hand-kept, it is subject to exactly the
staleness it prevents, so it may never be read as the full extent of the sweep.

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
"done for good". So do sweep words: "reconcile", "sweep for stale", "tidy up stale statuses",
"make the tracker match reality". So do setup words: "check the config", "validate the config",
"handoff doctor", "is my config right", "did I set this up correctly".

### Create, resume, status, close, reconcile, or check

- User is **wrapping up**, stopping, or switching agents → **Create** (§5).
- User is **starting fresh** and a handoff exists at `handoff_file` → **Resume** (§6).
- User wants to **see what's in the handoff** without consuming it (preview / show /
  summarize / status) → **Status** (§6.5) — read-only, no changes.
- User wants to **wrap up without leaving a handoff** (explicit "close out", "done for
  good", "wrap up — no handoff") → **Close** (§5, *Close*).
- User wants the **durable homes corrected now**, mid-session, without wrapping up — stale statuses
  swept, docs and index lines brought back into line → **Reconcile** (§10). It runs the §3a sweep
  and stops.
- User wants to know whether the **config itself** is sound — at setup, after editing it, or
  because a run just failed on it → **Check** (§9). Read-only, like Status, but over the config
  rather than over the handoff.

**Reconcile sits between Status and Create, and the difference is which thing it writes.** Status
changes nothing. Reconcile changes the **durable homes** and leaves `handoff_file` untouched —
never written, never archived, never consumed. Create and Close change both. So a request to tidy
the tracker is not a reason to write a handoff, and a request to hand off is not satisfied by a
sweep.

When intent is ambiguous between resume and status, default to the **non-mutating**
path: summarize (Status), then offer to resume — never archive on a maybe.

A bare "wrap up" or "I'm done" is ambiguous between Create and Close — they leave
different end states (a resume pointer vs none), so **ask** ("leave a resume pointer
(handoff), or close out with none?") rather than guess.

### Explicit invocation and its argument

Note whether the mode was **explicitly requested** — the handoff keyword, or a mode word
(`create` / `resume` / `status` / `close` / `reconcile` / `check`), appears in the command or
arguments the user typed — or **inferred** from context. Flows may branch on this: an explicitly requested action may skip a
confirmation that exists only to check an inferred intent (see `flows/resume.md` §6.3).

When the skill is invoked **explicitly with trailing text** after the handoff keyword — e.g.
`handoff <text>`:

**A leading mode word always selects the mode** (`create` / `resume` / `status` / `close` /
`reconcile` / `check`), whether it stands alone or is followed by more text. What the remainder
means depends on which mode it opened:

- **after `create`** — the remainder is the **subject of the handoff to write**: a description of
  what the **next** session should do. Record it as the intended next action / resume target (the
  Create flow's write step) and **do not carry it out now** — `handoff create <text>` asks you to
  *write a handoff about* that work, not to do it. If the text names a work item, resolve it via the
  binding's *find* / *reference* (§8) for the pointer, but start no work on it;
- **after `resume`, `status`, `close`, `reconcile` or `check`** — the remainder is a **qualifier on
  this run**: how to do the thing, not a thing to do later. `resume, full lifecycle` is Resume,
  carried out with that instruction; `reconcile the tracker only` is Reconcile, scoped that way.
  These modes act on something that already exists — a handoff, the durable homes, or the config —
  so there is no subject for them to take;
- **with no leading mode word** — the whole argument is the subject, and the mode is **Create**, as
  above. A phrase that merely *mentions* `resume` / `status` / `close` / `reconcile` / `check`
  part-way through is a subject, not a mode switch.

**Ask when the qualifier is really a subject.** Text after `resume` / `status` / `close` /
`reconcile` / `check` that plainly describes work for a **later** session rather than guidance for
this one — `resume the migration next week` — fits both readings. Ask which was meant rather than guessing; this is the same rule the
ambiguity paragraph above applies to a bare *wrap up*, and it is the only case in this section that
warrants a question.

This does not change the ambiguity rule above: when intent is genuinely ambiguous, still default to
the non-mutating path.

*Corrected 2026-08-13 from an adopter's report. The rule previously read `just a mode word` selects
the mode and **otherwise** the whole argument is a Create subject — with a parenthesis granting
`create <text>` the mode-plus-subject reading and denying it to the other three. So `resume, full
lifecycle` selected Create and recorded "resume, full lifecycle" as the next session's task, which is
the opposite of what was asked. Mode word plus qualifier is ordinary phrasing and had no correct
path through the rule.*

### Load the relevant flow

Each mode's steps live in an on-demand flow file. Once you've picked the mode, load **only**
that file and follow it — a Create/Close run never needs the Resume/Status flow, and no mode
needs more than one:

- **Create** (§5) or **Close** (§5, *Close*) → `flows/create.md`.
- **Resume** (§6) or **Status** (§6.5) → `flows/resume.md`.
- **Reconcile** (§10) → `flows/reconcile.md`.
- **Check** (§9) → `flows/check.md`.

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
3. **They go under one section, named exactly** `## Untracked specifics (move into a task when
   one exists)`, and nowhere else in the file. That heading is the only thing carrying the
   obligation forward: without it the next session reads a handoff holding task content with no
   signal that it is the exception, and passes the shape on to the session after that.
4. Once a tracked item exists, move those specifics into it and delete the section.

The name is defined here rather than in a flow because `create.md` writes the section and
`resume.md` empties it, and the two never load in the same run (§4) — a name defined in either
would be invisible to the other.

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
