# Optional: proactive handoff reminders (Claude Code hooks)

> Optional, agent-specific add-on — **not** part of the portable core. The neutral core
> (`handoff.core.md` §4) defines *when* a handoff is worth offering; this file wires Claude
> Code's event hooks so a couple of those moments surface on their own. Skip it entirely if
> you don't want automated nudges.

These reminders are **soft, opt-in, and non-mutating**: they only surface a suggestion — they
never run a handoff or close unattended, and never block the session. Installing a hook *is*
the opt-in (there is no config key); removing the hook entry turns it off again.

Two moments are worth a nudge:

- **Session start** — if a prepared handoff is already waiting, point it out so you can resume
  or preview it (ties into Resume §6 / Status §6.5).
- **Before a compaction** — the core flags this as an easy-to-miss moment; remind yourself to
  save resume state (`handoff`) or wrap up (`close`) first.

## Where these go

Add the entries to your project's `.claude/settings.json` under `hooks`. Replace the example
path `.agents/handoff/HANDOFF.md` with **your** configured `handoff_file`, and pick whichever
shell form matches your environment (PowerShell or POSIX `sh`) — the behavior is identical.

## SessionStart — "a handoff is waiting"

Claude Code adds a `SessionStart` hook's stdout to the model's context before your first
prompt, so the nudge reaches Claude and it can offer to resume or preview. It prints only when
the handoff file exists, so a clean project stays quiet.

PowerShell:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "pwsh -NoProfile -Command \"if (Test-Path '.agents/handoff/HANDOFF.md') { 'A prepared handoff exists — say resume to continue or status to preview.' }\""
          }
        ]
      }
    ]
  }
}
```

POSIX `sh`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "sh -c 'test -f .agents/handoff/HANDOFF.md && echo \"A prepared handoff exists — say resume to continue or status to preview.\"'"
          }
        ]
      }
    ]
  }
}
```

## PreCompact — "save state before compacting"

A `PreCompact` hook can't add to Claude's context, but it **can** show *you* a one-line warning
through the universal `systemMessage` field — exactly the soft nudge we want. It runs on exit 0
and does **not** block compaction: we deliberately avoid `decision: "block"` / exit code 2, so
the reminder fires and compaction proceeds regardless. You can choose to `handoff` or `close`
first, but nothing is forced.

PowerShell:

```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "auto|manual",
        "hooks": [
          {
            "type": "command",
            "command": "pwsh -NoProfile -Command \"@{systemMessage='Context is about to compact — say handoff to save resume state, or close to wrap up.'} | ConvertTo-Json -Compress\""
          }
        ]
      }
    ]
  }
}
```

POSIX `sh`:

```json
{
  "hooks": {
    "PreCompact": [
      {
        "matcher": "auto|manual",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"systemMessage\":\"Context is about to compact — say handoff to save resume state, or close to wrap up.\"}'"
          }
        ]
      }
    ]
  }
}
```

## Turning them off

There's no setting to toggle — the hook entry itself is the switch. Delete the `SessionStart`
or `PreCompact` block from `.claude/settings.json` (or remove the one `command`) and the
reminders stop. Nothing else depends on them.

## Further optional

- **Post-compaction nudge:** a `SessionStart` hook with `"matcher": "compact"` fires *after* a
  compaction, so you can remind yourself to save state if you didn't beforehand.
- **End of session:** `SessionEnd` can carry a `systemMessage` too, though it can't prompt
  interactively (the session is already ending).

## Other agents

This wiring is Claude Code-specific. **GitHub Copilot CLI** has no comparable event-hook
mechanism today, so there's nothing to wire there — its stub relies on the core's §4 proactive
triggers surfacing in conversation instead.
