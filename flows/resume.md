# Handoff Skill — Resume / Status flow

> On-demand flow file for the handoff **core**. Load this when the spine's §4 detection
> selects **Resume** or **Status**; the write path (Create / Close) lives in `create.md`.
> Section references below (§2, §3, §7.1, §8) point to the spine, `../handoff.core.md` — the
> routing model, session types, and binding contract stay there; this file follows them, it
> does not restate them. (§5 is in `create.md`.)

## 6. Resume

### 6.1 Find and read

Look for the handoff at `handoff_file`. If absent, tell the user there's no prepared
session to continue. Read it fully.

### 6.2 Summarize — and check what arrived

Give a brief summary (not the whole file), plus anything the handoff claims that no longer holds:

```text
Resuming from handoff: <title>

<short summary>

Changed since it was written: <state claims that no longer hold — omit the line if none>
```

**A handoff is a message with latency.** It describes the workspace as it stood when a session
stopped, and the world keeps moving after that: another session, another person, or simply elapsed
time can make a claim false **without anyone having written it wrongly**. No rule on the writing side
can reach this — the resume side is the only side that can know what actually arrived.

So before going further, test the handoff's **checkable** claims about current state — the pure
ephemeral items §2 admits in the first place: what was left unfinished or unsaved, what was still
running, where the work stopped. The claim itself says what to look at; **how** to look is the
environment's business, not this document's.

- **Where the workspace disagrees with the handoff, the workspace wins.** Say so in the summary above
  and let it change the plan before work starts — never reconcile it silently.
- **Claims that cannot be checked** — intent, reasoning, the intended next action — are taken as
  written.
- The check is **read-only**: it inspects, it changes nothing. §6.4 is still the first step that
  writes anything.

Do this before §6.3, so a mismatch reaches the user while resuming is still a decision.

### 6.3 Confirm

If the user's invocation asked to resume **explicitly and adjacent to the handoff keyword**
("resume", "resume handoff", "handoff resume"), skip this step and go straight to §6.4 — no
prompt. The invocation *is* the consent, and the only pre-work state change is archiving the
handoff by rename (§6.4), which is recoverable. The §6.2 summary above still prints, so the user
sees what is being resumed. Otherwise (resume was inferred, not stated next to the keyword) ask:
"Resume / Keep it for later / Discard?".

- **Resume** → §6.4.
- **Keep** → leave it untouched.
- **Discard** → archive it (rename to a `discarded_<timestamp>` form alongside the file).

### 6.4 Continue

1. Open the pointed-to homes (task docs via the active binding, plan, project docs) and
   read them — the handoff intentionally does **not** duplicate them.
2. Archive the handoff (rename to a `processed_<timestamp>` form) so it isn't resumed twice.
3. Start the work as described — **as adjusted by §6.2's check**, where a claim no longer held.
4. If the handoff is unclear on something critical, ask the user rather than guess.

### 6.5 Status (read-only)

Answer *"what's in the current handoff?"* without consuming it — a non-mutating preview
alongside Create (§5) and Resume (§6).

1. **Find and read** the handoff at `handoff_file` (as §6.1). If none exists, say so and
   stop.
2. **Print a short summary** — title + short summary + the pointers it references (work
   item, plan, project docs):

   ```text
   Handoff present: <title>

   <short summary>

   Points to: <homes/pointers the handoff references>
   ```
3. **Stop. Make no changes.** Status does not archive (no `processed_` / `discarded_`
   rename), does not open or read the pointed-to homes, does not route or update task /
   project docs or memory, and does not overwrite the handoff. It may end with a one-line
   hint that the user can say *resume* to continue or *discard* to archive — but takes no
   such action unprompted.

Status reads only the handoff file — **no tracker / binding interaction** — which keeps it
cheap and side-effect-free.

It also does **not** run §6.2's arrival check, and that is deliberate rather than an oversight:
Status previews the document, it does not act on it, and the check exists to protect the moment of
acting. Someone who wants to know what still holds is asking to resume.
