# Security policy

This project is a set of plain-Markdown instructions (a "skill") with one optional
PowerShell build script — there is no running service and a small classic-vulnerability
surface. The security considerations that matter here are about the **content of handoff
files**, plus the usual care with the build script.

## Handoff files must not capture private data

A handoff (and the task/project docs it points to) can capture whatever was in a working
session. The skill's routing procedure (`handoff.core.md` §3, step 1) is the source of truth for
what to exclude: **secrets, user-/machine-private data, and copied local-memory contents are
excluded and stored nowhere.** The Create flow carries the canonical **pre-write / commit
checklist** (`flows/create.md` §5); this policy references it rather than duplicating it. Before
committing or sharing a handoff:

- Run the Create flow's §5 pre-write checklist (`flows/create.md`) over it.
- For any secret, apply the core's redaction method (`handoff.core.md` §3, *Redacting secrets*):
  omit the value, reference it by location/name if its existence matters, and never store it —
  not even a truncated value or a "temporary" note.
- Review the result yourself — never paste passwords, tokens, API keys, or other credentials into
  a handoff or task doc, and watch for usernames, home directories, absolute local paths,
  hostnames, or IPs that slipped in.
- Treat handoff files in a shared repo as readable by everyone with repo access.

## Reporting a vulnerability

If you find a security issue — in the build script, the docs, or something that could cause an
agent to mishandle secrets — please report it privately:

- Preferred: open a private report via **GitHub Security → "Report a vulnerability"** on this
  repository (private vulnerability reporting is enabled).
- Alternatively, contact the maintainer through their GitHub profile
  [@uchimata2](https://github.com/uchimata2).

Please do not open a public issue for security-sensitive reports. We'll acknowledge the report
and follow up as quickly as we can.
