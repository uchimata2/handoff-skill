#!/usr/bin/env pwsh
# Build the installable `handoff.skill` artifact from the package.
#
# `handoff.skill` is just a zip of the portable package (the source of truth), laid out
# under a single top-level `handoff/` directory. Download it, unzip it into your project,
# then follow the install steps in README.md. The skill is plain Markdown and needs no
# build to use — this is purely a convenience for distribution. The artifact is
# regenerated on demand and is git-ignored (see .gitignore).
#
# Usage:  pwsh scripts/build-skill.ps1
# Runs anywhere PowerShell 7+ (pwsh) is available — Windows, macOS, or Linux.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Repo root = the parent of this script's directory.
$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root 'dist'
$out  = Join-Path $dist 'handoff.skill'

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

    New-Item -ItemType Directory -Path $dist -Force | Out-Null
    if (Test-Path $out) { Remove-Item $out -Force }

    # Compress-Archive expects a .zip destination; build there, then rename to .skill.
    $zip = Join-Path $dist 'handoff.zip'
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path $bundle -DestinationPath $zip
    Move-Item -Path $zip -Destination $out -Force

    $size = [math]::Round((Get-Item $out).Length / 1KB, 1)
    Write-Host "Built $out ($size KB)"
}
finally {
    if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
}
