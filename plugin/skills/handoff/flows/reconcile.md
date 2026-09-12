# Handoff Skill — Reconcile flow

> On-demand flow file for the handoff **core**. Load this when the spine's §4 detection selects
> **Reconcile**; the write path (Create / Close) lives in `create.md`, the read path (Resume /
> Status) in `resume.md`, and the config check in `check.md`.
> Section references below (§0, §3a) point to the spine, `../handoff.core.md` — the sweep itself is
> defined there; this file follows it, it does not restate it.

## 10. Reconcile

Run the §3a backward sweep on its own, **mid-session**, and stop. No handoff is written, nothing is
archived, and no forward routing of new discoveries happens — that is Create's job.

Use it when the durable homes have drifted and you want them corrected now: a finished task still
marked open, an umbrella item whose parts are all resolved, a doc or memory line a later fact made
false, a pointer that no longer resolves.

### 10.1 Scope the sweep

The durable homes the session touched, **plus** `reconcile_targets` if the config declares it (§0).
A declared list is a **floor, never a ceiling** — it exists to catch the homes that go stale
silently, not to bound the sweep (§3a).

### 10.2 Sweep

Run §3a: statuses, superseded content, pointers. Nothing here differs from the pass Create and Close
run — same section, same test. Where two homes disagree, the most recent verified fact wins.

### 10.3 Report what changed

**Itemise every change.** This is the one obligation the mode has that Create does not, and it
follows from what Reconcile leaves behind: Create ends with a handoff recording what it did, and
Reconcile ends with no document at all. A sweep that quietly rewrote several durable homes and then
said "done" cannot be checked by anyone, including the next session.

**Finding nothing is a result.** Say so plainly. A clean sweep means the homes already agree — it is
not a failure, and it is not a reason to look for something to change.

### 10.4 Leave the handoff alone

Reconcile never touches `handoff_file`: it does not write one, does not archive one, and does not
consume one — including when a live handoff is sitting there.

Where the sweep finds that a **live handoff's claims are now false**, report that as a finding and
stop. Repairing it means writing a new snapshot, which is Create (§5), and doing it here would make
this a half-Create with none of Create's checks.

That boundary is what separates the three write-side behaviours:

| Mode | Durable homes | `handoff_file` |
|---|---|---|
| Status (§6.5) | unchanged | unchanged |
| **Reconcile (§10)** | **corrected** | **unchanged** |
| Create (§5) / Close (§5 *Close*) | corrected | written / archived |

### 10.5 No confirmation, and why

Do not ask permission before writing. The invocation is the consent: the user asked for the homes to
be corrected, and a prompt afterwards asks them to authorise the thing they just requested. This is
the same reasoning `resume.md` §6.3 applies to an explicit resume. §10.3's itemised report is what
makes that safe — the user sees exactly what changed, immediately after it changed.
