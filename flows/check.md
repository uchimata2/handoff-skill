# Handoff Skill — Check flow

> On-demand flow file for the handoff **core**. Load this when the spine's §4 detection
> selects **Check**; the write path (Create / Close) lives in `create.md` and the read path
> (Resume / Status) in `resume.md`. Section references below (§0, §7.1, §8) point to the spine,
> `../handoff.core.md` — the configuration table and the binding contract stay there; this file
> follows them, it does not restate them.

## 9. Check

Answer *"is this config sound?"* — before a session depends on it.

A config is prose read by an agent, not a parsed file, so nothing rejects a misspelled key, a
`tracker` naming a binding that does not exist, or a `handoff_file` under a folder nobody created.
Left alone, all three surface **during** a real run: usually a Create, at the moment the user is
trying to stop work. Check moves that failure to setup, where it is cheap.

**Check changes nothing.** It reads the config, inspects what the config points at, and reports. It
writes no handoff, archives nothing, and updates no durable home — the same guarantee Status (§6.5)
gives, over the config rather than over the handoff.

### Process

Work through all seven and collect the results. **Do not stop at the first failure** — a config that
has one thing wrong with it usually has two, and reporting them one per run is the slow way to fix
a setup.

1. **Resolve every key in the §0 table, and say which step of the chain answered it** — declared,
   cached from an earlier discovery, or a documented default. Report an absent key as **its
   default**, not as an error: `tracker: none` or an absent `memory` are ordinary configurations
   rather than defects. What is worth reporting is a key that is *present but unresolvable*, and a
   key name matching nothing in the table, which is usually a near-miss spelling of one that would.
2. **Re-derive the cached values and report drift.** A value marked `(discovered: …)` is a cache,
   and Check is what invalidates it: run its discovery again, report agreement in one line, and
   report a disagreement as a finding — the project usually moved and the config did not. **A
   *declared* value that a discovery contradicts is also a finding**, though the declared value goes
   on winning everywhere else (§0). Check reports; it does not re-resolve, and it does not rewrite
   the config.
3. **Confirm the active binding exists.** `tracker` names a file in `bindings/`; open it. A
   `tracker` value with no matching binding file is the config error with the widest blast radius,
   because every task operation routes through it. With `tracker: none`, record that every session
   will be ad-hoc (§7.1) and move on — that is a choice, not a fault.
4. **Confirm the handoff can actually be written.** `handoff_file` must be creatable at that path:
   its parent must exist and accept a write. This is the check that repays the whole mode, because
   the failure it prevents lands at the *end* of a Create, after all the routing work is done and
   with nowhere to put the result.
5. **Run the binding's invariant hook once, if it declares one.** Some bindings let a project
   declare a command that validates the tracker, and any index it keeps, after a write (§8). Where
   the active binding defines such a hook **and** the config sets it, run it once and report what it
   says. Where the binding defines no hook, there is nothing to run and nothing to report — most do
   not, and its absence is not a finding.
6. **Note any archives that are not where archiving would put them.** Archived handoffs are renamed
   in place, so they sit beside `handoff_file` (§1). A separate folder of them — most often
   `handoff-archive/`, which a `0.7.0` install created — means those records were moved a level
   deeper than the file they were written in, and the relative pointers in their bodies have not
   resolved since. Report the folder, say what it costs, and name the repair: moving them back
   beside `handoff_file` restores the pointers. **Report only** — Check never moves a file. This is
   the one step that lists a directory rather than only resolving a path; it still opens nothing,
   and it earns the extra look because the projects it warns are the ones that cannot know to look
   for themselves.
7. **Report, in the order above.** One line per key or check: what resolved and how, what fell back
   to a documented default, what drifted, and what could not be resolved at all. Finish with the
   only conclusion the user asked for — whether the config is usable as it stands.

**How to look is the environment's business, not this document's.** The steps above say *what* must
resolve — a file exists, a folder accepts a write, a declared command exits clean — and name no tool
for any of it. Same division as the arrival check in `resume.md` §6.2, and for the same reason: the
environments this runs in do not agree on how to ask.

### What Check does not do

- **It does not bootstrap a config.** §0's chain writes down what it discovered or asked, on the run
  that needed it. Check only reports what is there — so a project with no config gets a report of
  defaults, not a new file.
- **It does not fix anything.** A config defect is the project's to correct. A mode that quietly
  rewrote a config would leave the file saying something its author does not know it says, which is
  a worse failure than the one it repaired.
- **It does not open the homes**, only the paths to them. It does not read tracker contents, project
  docs, or `handoff_file`. Whether those can be *reached* is the question; what is in them is not.
- **It does not run inside Create or Resume.** Those resolve an absent key with §0's chain and send
  anything worse back here, by §0's pointer. Validation that ran on every wrap-up would add a step
  at precisely the moment this mode exists to protect.
