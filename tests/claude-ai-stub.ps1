#!/usr/bin/env pwsh
# The claude.ai stub must not act outside a claude.ai chat.
#
# Section 1 of agents/claude-ai.SKILL.md replaces the core's archive-by-rename rule with a delete
# through the Projects tool, which is right only for docs in a Claude Project. A skill uploaded to
# claude.ai is also loaded by the Claude desktop app's Code tab, where that rule would delete a
# handoff the core keeps. Three rules follow, each checked here:
#   1. the stub's first section sends every other harness to agents/claude.SKILL.md, before the
#      stub first names the delete tool;
#   2. the claude.ai package carries that stub, unchanged, as its top-level SKILL.md, and ships the
#      stub that rule 1 points to;
#   3. the Claude Code plugin's SKILL.md is not the claude.ai stub and never names the delete tool.
#
# Usage:  pwsh tests/claude-ai-stub.ps1
# Builds dist/handoff-claude-ai.skill, then exits 1 and names each broken rule.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root       = Split-Path -Parent $PSScriptRoot
$stubPath   = Join-Path $root 'agents/claude-ai.SKILL.md'
$pluginPath = Join-Path $root 'plugin/skills/handoff/SKILL.md'
$deleteTool = 'project_delete'          # the Projects tool's delete, named in the stub's section 1
$fallback   = 'agents/claude.SKILL.md'  # where the guard sends every other harness

function Read-Text($path) { [IO.File]::ReadAllText($path) -replace "`r`n", "`n" }
function Get-Hash($path) { (Get-FileHash -Algorithm SHA256 $path).Hash }

$failures = [Collections.Generic.List[string]]::new()

# ---------------------------------------------------------------- rule 1: the guard comes first
$stub = Read-Text $stubPath
$sections = [regex]::Matches($stub, '(?m)^## ')
if ($sections.Count -lt 2) {
    $failures.Add("rule 1: agents/claude-ai.SKILL.md has fewer than two '## ' sections")
}
else {
    $guard  = $stub.IndexOf($fallback)
    $delete = $stub.IndexOf($deleteTool)
    if ($guard -lt $sections[0].Index -or $guard -ge $sections[1].Index) {
        $failures.Add("rule 1: the first section of agents/claude-ai.SKILL.md does not send other harnesses to $fallback")
    }
    if ($delete -ge 0 -and ($guard -lt 0 -or $delete -lt $guard)) {
        $failures.Add("rule 1: agents/claude-ai.SKILL.md names $deleteTool before its guard")
    }
}

# ---------------------------------------------------------------- rule 2: the package carries it
& (Join-Path $root 'scripts/build-skill.ps1') -Stub claude-ai | Out-Host
$staging = Join-Path ([IO.Path]::GetTempPath()) ("handoff-test-" + [guid]::NewGuid())
try {
    New-Item -ItemType Directory -Path $staging -Force | Out-Null
    $zip = Join-Path $staging 'package.zip'
    Copy-Item (Join-Path $root 'dist/handoff-claude-ai.skill') $zip
    Expand-Archive -Path $zip -DestinationPath $staging
    $top = Join-Path $staging 'handoff/SKILL.md'
    if (-not (Test-Path $top)) {
        $failures.Add('rule 2: the claude.ai package has no handoff/SKILL.md')
    }
    elseif ((Get-Hash $top) -ne (Get-Hash $stubPath)) {
        $failures.Add("rule 2: the claude.ai package's SKILL.md differs from agents/claude-ai.SKILL.md")
    }
    if (-not (Test-Path (Join-Path $staging "handoff/$fallback"))) {
        $failures.Add("rule 2: the claude.ai package does not ship $fallback, where its guard points")
    }
}
finally { if (Test-Path $staging) { [IO.Directory]::Delete($staging, $true) } }

# ---------------------------------------------------------------- rule 3: the plugin is clean
if ((Get-Hash $pluginPath) -eq (Get-Hash $stubPath)) {
    $failures.Add("rule 3: the plugin's SKILL.md is the claude.ai stub")
}
if ((Read-Text $pluginPath).Contains($deleteTool)) {
    $failures.Add("rule 3: the plugin's SKILL.md names $deleteTool")
}

if ($failures.Count) {
    $failures | ForEach-Object { Write-Host "FAIL $_" }
    exit 1
}
Write-Host 'claude.ai stub: its guard comes first, its package carries it, and the plugin stays clean.'
