#!/usr/bin/env pwsh
# Build the installable `handoff.skill` artifact from the package.
#
# `handoff.skill` is just a zip of the portable package (the source of truth), laid out
# under a single top-level `handoff/` directory. Download it, unzip it into your project,
# then follow the install steps in README.md. The skill is plain Markdown and needs no
# build to use — this is purely a convenience for distribution. The artifact is
# regenerated on demand and is git-ignored (see .gitignore).
#
# Usage:  pwsh scripts/build-skill.ps1                  -> dist/handoff.skill
#         pwsh scripts/build-skill.ps1 -Stub claude-ai  -> dist/handoff-claude-ai.skill
# Runs anywhere PowerShell 7+ (pwsh) is available — Windows, macOS, or Linux.
#
# -Stub names an agent stub, agents/<stub>.SKILL.md, to place at the top of the package as
# SKILL.md, unchanged. That is the shape for a harness that loads the package folder itself as
# the skill, such as a claude.ai upload. A stub with {{...}} placeholders is a template that must
# be rendered first (build-plugin.ps1 renders claude.SKILL.md), so it is refused here.

param(
    [string]$Stub
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Repo root = the parent of this script's directory.
$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root 'dist'
$name = if ($Stub) { "handoff-$Stub" } else { 'handoff' }
$out  = Join-Path $dist "$name.skill"

$stubPath = $null
if ($Stub) {
    $stubPath = Join-Path $root "agents/$Stub.SKILL.md"
    if (-not (Test-Path $stubPath)) {
        throw "-Stub '$Stub': no agent stub at agents/$Stub.SKILL.md"
    }
    if ([IO.File]::ReadAllText($stubPath) -match '\{\{[^}]*\}\}') {
        throw "-Stub '$Stub': agents/$Stub.SKILL.md has the placeholder $($Matches[0]); a template stub cannot ship unrendered"
    }
}

# Canonical package manifest: the files and directories that make up the distributable
# package. This array is the single source of truth for "what ships" — README.md and
# CONTRIBUTING.md describe the package but point here rather than maintaining their own
# file lists. Keep this list authoritative; update it when the package layout changes.
$items = @(
    'handoff.core.md',
    'flows',
    'config.example.md',
    'bindings',
    'agents',
    'EXAMPLES.md',
    'README.md',
    'LICENSE'
)

# Stage the package under a clean `handoff/` directory so the archive unzips to a single
# self-named folder regardless of where it's extracted.
$staging = Join-Path ([System.IO.Path]::GetTempPath()) ("handoff-build-" + [guid]::NewGuid())
$bundle  = Join-Path $staging 'handoff'
New-Item -ItemType Directory -Path $bundle -Force | Out-Null

try {
    foreach ($item in $items) {
        $src = Join-Path $root $item
        if (-not (Test-Path $src)) {
            throw "Missing package item: $item"
        }
        Copy-Item -Path $src -Destination $bundle -Recurse -Force
    }
    if ($stubPath) { Copy-Item -Path $stubPath -Destination (Join-Path $bundle 'SKILL.md') }

    New-Item -ItemType Directory -Path $dist -Force | Out-Null
    if (Test-Path $out) { Remove-Item $out -Force }

    # Compress-Archive expects a .zip destination; build there, then rename to .skill.
    $zip = Join-Path $dist "$name.zip"
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path $bundle -DestinationPath $zip
    Move-Item -Path $zip -Destination $out -Force

    $size = [math]::Round((Get-Item $out).Length / 1KB, 1)
    Write-Host "Built $out ($size KB)"
}
finally {
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
}
