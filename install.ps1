<#
.SYNOPSIS
    Installs the prd-craft skill set into a project or into your user-level agent
    skills directory.

.DESCRIPTION
    The skill set is platform independent: every agent that can read a folder with a
    SKILL.md can use it. This script only copies files; it never edits your agent
    configuration.

    Targets:
      project   -> <project>/.agents/skills/        (checked into the project, shared with the team)
      user      -> ~/.agents/skills/                (available in every project)
      claude    -> <project>/.claude/skills/        (Claude Code project scope)
      claudeuser-> ~/.claude/skills/               (Claude Code user scope)

.EXAMPLE
    pwsh -File ./install.ps1 -Target project
    pwsh -File ./install.ps1 -Target user
    pwsh -File ./install.ps1 -Target project -Destination C:\work\my-app
#>
[CmdletBinding()]
param(
    [ValidateSet('project', 'user', 'claude', 'claudeuser')]
    [string]$Target = 'project',

    # Where the project root is. Defaults to the current directory.
    [string]$Destination,

    # Report what would be copied without touching anything.
    [switch]$WhatIfOnly
)

$ErrorActionPreference = 'Stop'

$srcRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$skills = @('prd-craft', 'kvkk-publish-review')
$extraFiles = @('ROUTING.md')

function Resolve-Target {
    param([string]$t, [string]$dest)
    if ($t -eq 'user')      { return (Join-Path $HOME '.agents/skills') }
    if ($t -eq 'claudeuser'){ return (Join-Path $HOME '.claude/skills') }
    $root = if ($dest) { (Resolve-Path -LiteralPath $dest).Path } else { (Get-Location).Path }
    if ($t -eq 'claude') { return (Join-Path $root '.claude/skills') }
    return (Join-Path $root '.agents/skills')
}

$dstRoot = Resolve-Target -t $Target -dest $Destination

Write-Host ''
Write-Host '  prd-craft skill set installer' -ForegroundColor Cyan
Write-Host "  source : $srcRoot"
Write-Host "  target : $dstRoot"
Write-Host ''

$copied = 0
$failed = @()

foreach ($s in $skills) {
    $from = Join-Path $srcRoot $s
    if (-not (Test-Path $from)) {
        $failed += "$s (missing in source: $from)"
        continue
    }
    $to = Join-Path $dstRoot $s
    if ($WhatIfOnly) {
        Write-Host "  WOULD COPY  $s  ->  $to" -ForegroundColor DarkGray
        $copied++
        continue
    }
    if (Test-Path $to) {
        Write-Host "  EXISTS      $s (overwriting)" -ForegroundColor Yellow
    }
    if (Test-Path $to) { Remove-Item -Recurse -Force $to }
    Copy-Item -Recurse -Path $from -Destination $to
    $n = (Get-ChildItem -Recurse -File $to | Measure-Object).Count
    Write-Host "  COPIED      $s  ($n files)" -ForegroundColor Green
    $copied++
}

foreach ($f in $extraFiles) {
    $from = Join-Path $srcRoot $f
    if (-not (Test-Path $from)) { continue }
    $to = Join-Path $dstRoot $f
    if ($WhatIfOnly) {
        Write-Host "  WOULD COPY  $f  ->  $to" -ForegroundColor DarkGray
        $copied++
        continue
    }
    Copy-Item -Path $from -Destination $to -Force
    Write-Host "  COPIED      $f" -ForegroundColor Green
    $copied++
}

# ROUTING.md is the single routing point and both skills reference it. A copy that
# is not next to the skills would break the routing decision.
$skillRootNote = @'

  ROUTING.md is the single routing point: it decides which skill answers a request,
  and both skills must be able to read it. Keep it next to the skill folders.
'@

if ($WhatIfOnly) {
    Write-Host ''
    Write-Host "  Nothing was written (WhatIfOnly). $copied item(s) would be copied." -ForegroundColor Yellow
} elseif ($failed.Count -gt 0) {
    Write-Host ''
    Write-Host '  INSTALL INCOMPLETE:' -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    exit 1
} else {
    Write-Host $skillRootNote
    Write-Host "  Done. $copied item(s) installed." -ForegroundColor Green
    Write-Host ''
    Write-Host '  Next:' -ForegroundColor Cyan
    Write-Host "    1. Restart your agent session so it picks the skills up."
    Write-Host "    2. Ask something like 'I want an app that finds broken links in my docs'"
    Write-Host "       and check that the first line of the answer is a decision declaration:"
    Write-Host "       skill: prd-craft | none | undecided  .  rationale: <one sentence>"
}

exit 0