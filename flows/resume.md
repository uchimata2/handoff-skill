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

### 6.2 Summarize

Give a brief summary (not the whole file):

```text
Resuming from handoff: <title>

<short summary>
```

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
3. Start the work as described.
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
