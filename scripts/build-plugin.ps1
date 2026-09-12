#!/usr/bin/env pwsh
# Generate the Claude Code plugin shape from the sources that already carry the facts.
#
# Nothing here is authored except $keywords: the plugin's name, description, version and
# licence all have one home already, and this script renders that home into the three files
# a plugin install reads. The generated files are committed, because an install reads the
# repository tree — so `.github/workflows/checks.yml` regenerates them and fails on a diff.
#
# Usage:  pwsh scripts/build-plugin.ps1
# Sources:  agents/claude.SKILL.md frontmatter (name, description, argument-hint)
#           CHANGELOG.md latest released heading (version)
#           LICENSE (licence)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$repoUrl = 'https://github.com/uchimata2/handoff-skill'

# The one authored fact. Everything else below is read from an existing home.
$keywords = @('handoff', 'context', 'resume', 'session', 'continuity', 'tracker', 'reconcile')

function Read-Text($path) { ([IO.File]::ReadAllText($path)) -replace "`r`n", "`n" }
function Write-Generated($path, $text) {
    $dir = Split-Path -Parent $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [IO.File]::WriteAllText($path, ($text -replace "`r`n", "`n"))
    Write-Host "  wrote $($path.Substring($root.Length + 1).Replace('\', '/'))"
}
function ConvertTo-JsonString($s) { '"' + (($s -replace '\\', '\\') -replace '"', '\"') + '"' }

# ---------------------------------------------------------------- read the sources
$stubPath = Join-Path $root 'agents/claude.SKILL.md'
$stub = Read-Text $stubPath
if ($stub -notmatch "(?s)\A---\n(.*?)\n---\n(.*)\z") { throw "No frontmatter in agents/claude.SKILL.md" }
$frontmatter, $body = $Matches[1], $Matches[2]

$name = ([regex]::Match($frontmatter, '(?m)^name:\s*(.+)$').Groups[1].Value).Trim()
$description = ([regex]::Match($frontmatter, '(?m)^description:\s*(.+)$').Groups[1].Value).Trim()
if (-not $name -or -not $description) { throw "name/description missing from the stub frontmatter" }

$version = ([regex]::Match((Read-Text (Join-Path $root 'CHANGELOG.md')), '(?m)^## \[(\d+\.\d+\.\d+)\]').Groups[1].Value)
if (-not $version) { throw "No released version heading in CHANGELOG.md" }

$license = if ((Read-Text (Join-Path $root 'LICENSE')) -match '(?m)^MIT License') { 'MIT' } else { throw "Unrecognised LICENSE" }

# The marketplace blurb is the description's first sentence — derived, not a second description.
$short = ([regex]::Match($description, '^(.*?\.)(\s|$)').Groups[1].Value)
if (-not $short) { throw "Could not derive a short description" }

Write-Host "handoff plugin: name=$name version=$version license=$license"

# ---------------------------------------------------------------- the payload
# Build the release asset and expand it, so the plugin ships exactly the files `$items`
# ships. Anything else would be a second package manifest.
$pluginDir = Join-Path $root 'plugin'
$skillDir  = Join-Path $pluginDir "skills/$name"

& (Join-Path $PSScriptRoot 'build-skill.ps1') | Write-Host
$asset = Join-Path $root 'dist/handoff.skill'
if (-not (Test-Path $asset)) { throw "build-skill.ps1 produced no asset" }

$staging = Join-Path ([IO.Path]::GetTempPath()) ("handoff-plugin-" + [guid]::NewGuid())
try {
    New-Item -ItemType Directory -Path $staging -Force | Out-Null
    $zip = Join-Path $staging 'handoff.zip'
    Copy-Item $asset $zip
    Expand-Archive -Path $zip -DestinationPath $staging
    if (Test-Path $skillDir) { [IO.Directory]::Delete($skillDir, $true) }
    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    Get-ChildItem (Join-Path $staging 'handoff') | Copy-Item -Destination $skillDir -Recurse -Force
    Write-Host "  wrote plugin/skills/$name/ (the package payload)"
}
finally { if (Test-Path $staging) { [IO.Directory]::Delete($staging, $true) } }

# ---------------------------------------------------------------- render the skill
# `$HANDOFF` replaces {{package}}: a bare relative path would resolve against the user's
# project, so the skill reads its own location instead (§0 below).
$resolver = @'
## 0. Resolve `$HANDOFF` first, before following any path below

Every path in this skill is written from `$HANDOFF`, the directory this file sits in — the package
travels with the skill. A bare path would resolve against the user's project, which may have files
of these names itself.

**Read it off this file's own location.** A harness that loads a skill names the directory it loaded
it from, and `$HANDOFF` is that directory. That answer stays correct for a copy of this plugin
published under another name.

'@

# Drop the template banner: it tells a reader to copy this file and replace placeholders,
# which is exactly what this script has done for them.
$body = [regex]::Replace($body, "(?sm)^> Template —.*?(?=\n\n[^>])", '').TrimStart("`n")

# A plugin serves every project at once, so it has no single config path. The template's own
# shared-install wording is substituted here rather than rewritten.
$configPattern = 'reading the project config at `\{\{config\}\}` for the\s+handoff-file path, tracker, and project docs\.'
$discovery = @"
reading the project config for the handoff-file path, tracker, and project docs. Look first for a
project-local config in the current project (commonly ``.handoff/config.md``); if none exists,
resolve the missing keys by the core's §0 chain — discover them from the project, ask only what is
left, and record the result.
"@ -replace "`r`n", "`n"
if ($body -notmatch $configPattern) { throw "The stub's {{config}} sentence changed shape; update this script" }
$body = [regex]::Replace($body, $configPattern, { $discovery }, 1)

$body = $body.Replace('{{package}}', '$HANDOFF')
$body = $body -replace "(?m)^# Handoff\n", "# Handoff`n`n$resolver"
$body = $body -replace "\n{3,}", "`n`n"
if ($body -match '\{\{') { throw "Unsubstituted placeholder left in the rendered skill: $($Matches[0])" }

$skill = "---`n$frontmatter`n---`n`n" + $body.TrimStart("`n").TrimEnd() + "`n"
Write-Generated (Join-Path $skillDir 'SKILL.md') $skill

# ---------------------------------------------------------------- render the manifests
$kw = ($keywords | ForEach-Object { '    ' + (ConvertTo-JsonString $_) }) -join ",`n"
$kwInner = ($keywords | ForEach-Object { '        ' + (ConvertTo-JsonString $_) }) -join ",`n"

Write-Generated (Join-Path $pluginDir '.claude-plugin/plugin.json') @"
{
  "name": $(ConvertTo-JsonString $name),
  "version": $(ConvertTo-JsonString $version),
  "description": $(ConvertTo-JsonString $description),
  "author": {
    "name": "the handoff maintainers",
    "url": $(ConvertTo-JsonString $repoUrl)
  },
  "license": $(ConvertTo-JsonString $license),
  "keywords": [
$kw
  ]
}
"@

Write-Generated (Join-Path $root '.claude-plugin/marketplace.json') @"
{
  "`$schema": "https://json.schemastore.org/claude-code-marketplace-manifest.json",
  "name": $(ConvertTo-JsonString $name),
  "owner": {
    "name": "uchimata2",
    "url": "https://github.com/uchimata2"
  },
  "description": $(ConvertTo-JsonString $short),
  "plugins": [
    {
      "name": $(ConvertTo-JsonString $name),
      "source": "./plugin",
      "description": $(ConvertTo-JsonString $description),
      "license": $(ConvertTo-JsonString $license),
      "keywords": [
$kwInner
      ]
    }
  ]
}
"@

Write-Host "Done. These files are generated — edit the sources above, then re-run this script."
