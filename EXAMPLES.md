# Examples

Concrete, annotated examples of the Handoff skill in action. The point of every example below
is the routing discipline: **the handoff *points*, it does not *store*.** Each fact has exactly
one home; the handoff only references those homes. These examples follow the routing matrix and
procedure in [`handoff.core.md`](handoff.core.md) §2–§3.

> All names, ids, and paths here are illustrative. Never put real secrets, tokens, or
> credentials in a handoff or task doc.

---

## 1. A filled-in config

A minimal project config (copied from [`config.example.md`](config.example.md)) using the
zero-dependency `local-markdown` tracker:

```markdown
# Handoff config

- `handoff_file`: .agents/handoff/HANDOFF.md
- `tracker`: local-markdown
- `project_docs`: AGENTS.md

### tracker: local-markdown
- `tracker_file`: BACKLOG.md
```

The agent's stub supplies `memory` separately (e.g. `memory: claude` or `memory: none`).

---

## 2. A good handoff (pointer-only)

Setting: a ticketed development session, paused mid-way. The work item `ITEM-7` lives in
`BACKLOG.md`; its requirements, plan, decisions, and progress were updated **on the item**
before writing this handoff. The handoff itself carries only a pointer and ephemeral state:

```markdown
# Handoff

**Resume:** ITEM-7 (BACKLOG.md) — continue implementation.
**Next action:** finish step 3 of 5 (extract the parser), then run the test suite.

**Ephemeral state** (recorded nowhere else, not worth keeping):
- Uncommitted edits in the working tree for ITEM-7.
- A local preview process is still running from this session on port 5173.
```

Why it's good:

- It **names where to continue**, not what the task is.
- Requirements / plan / decisions / file lists are **not** here — they're on ITEM-7.
- The only stored content is genuinely ephemeral (uncommitted state, a transient process).
- It reads in well under a minute.

---

## 3. The same handoff done wrong (anti-pattern)

The same situation, but stuffed with content that already has a home. Each ✗ line shows where
that fact **should** have gone instead:

```markdown
# Handoff

Resume: ITEM-7.

Requirements: the parser must accept nested groups, ignore comments, and emit
positions for each token; edge cases include empty input and trailing commas.   ✗ task docs (ITEM-7)
Plan: 1) tokenizer 2) grammar 3) extract parser 4) error recovery 5) tests.      ✗ task docs (ITEM-7)
Decision: chose a recursive-descent parser over a table-driven one because the
grammar is small and readability matters more than raw speed.                    ✗ task docs (ITEM-7)
Files to touch: src/lexer.ts, src/parser.ts, tests/parser.test.ts.               ✗ task docs (ITEM-7)
Reminder: always run the linter with --fix before committing.                    ✗ project docs (a project-wide rule)
I like terse, imperative commit messages.                                        ✗ agent memory (personal preference)
Stopped mid step 3.                                                              ✓ ephemeral — this one stays
```

Everything marked ✗ duplicates a durable home, which breaks single source of truth: the next
session now has two copies that can drift. Route each fact to its home first, then the handoff
shrinks to the pointer-only version in §2.

---

## 4. Walkthroughs by session type

The routing rules are content-based, so they apply unchanged across session types.

### Ticketed development

1. As work proceeds, write each discovery to its home (core §3): task facts → the item
   (`ITEM-7`); a project-wide rule you uncovered → project docs; a personal preference →
   agent memory (or project docs if it's shareable and memory is unavailable).
2. When wrapping up, the handoff records only the resume pointer + ephemeral state — exactly
   §2 above.

### Ad-hoc, non-development (e.g. research, writing, ops)

No tracked item exists yet, so follow core §7.1:

1. **Offer to create one** via the active binding (e.g. append an `ITEM-<n>` section to the
   backlog) so the findings get a durable home.
2. If the user **declines**, the otherwise-task-specific specifics may live in the handoff
   snapshot — the single allowed exception, because there is no task home yet:

   ```markdown
   # Handoff

   **Resume:** continue the vendor comparison (ad-hoc; no tracked item — user declined).

   **Findings so far** (no durable home yet — move to a tracked item when created):
   - Vendor A meets the latency target; Vendor B is cheaper but lacks an EU region.
   - Open question: does Vendor A bill per request or per seat?
   ```
3. Once an item **is** created, move those specifics into it and reduce the handoff to a pointer.

### A second project using `local-markdown`

The same core drops into a different repo with **config changes only** — no tracker service
required. Point `tracker` at `local-markdown`, set `tracker_file: BACKLOG.md`, and items are
plain `## [ITEM-n] Title` sections (see [`bindings/local-markdown.md`](bindings/local-markdown.md)).
Handoffs look identical to §2; only the binding behind "task docs" differs.

---

## 5. Resuming from a handoff

Following core §6, a resume reads only the pointer and ephemeral state — never a duplicated
task body:

```text
Resuming from handoff: ITEM-7

Continue implementation — finish step 3 of 5 (extract the parser), then run the tests.
Heads-up: uncommitted edits and a preview process are left over from the previous session.
```

Then: **Resume / Keep it for later / Discard?** On resume, the agent opens the pointed-to homes
(the item in `BACKLOG.md`, plus project docs), archives the handoff so it isn't resumed twice,
and starts the work. The substance comes from the item — the handoff just said *where* to look.
