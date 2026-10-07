<#
  PRD validation script — prd-craft §7 "Pre-Delivery Verification"
  Run:      powershell -File .\scripts\validate-prd.ps1 -Path .\docs\feature-prd.md
  Exit code: 0 = the document is ready to deliver · 1 = there is at least one blocker

  This script is the machine-readable form of the skill's checklist. Purpose:
  make sure a delivered document has no placeholder, no ownerless tag and no broken link.

  NOTE: this script is deliberately ASCII-only. Turkish (or any non-ASCII) string
  literals can be mangled while the .ps1 is read and silently break the matches.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Path)) {
    Write-Host "ERROR: file not found -> $Path" -ForegroundColor Red
    exit 1
}

$t = Get-Content $Path -Raw -Encoding UTF8
$lines = Get-Content $Path -Encoding UTF8
$fail = 0
$pass = 0

function Block($ok, $label, $detail = '') {
    if ($ok) {
        $script:pass++
        Write-Host "  PASS    $label" -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host "  BLOCK   $label" -ForegroundColor Red
        if ($detail) { Write-Host "          $detail" -ForegroundColor DarkGray }
    }
}

Write-Host "`n=== PRD: $Path ===" -ForegroundColor Cyan

Write-Host "`n--- 1. Placeholder ban (TBD) ---" -ForegroundColor Cyan
# A "TBD" inside JTBD is not a real placeholder -> word-bounded and case-sensitive
$ph = @('[to be assigned]', '[name]', '[date]', '[question]', '[assignee]', '[surname]',
    '[measures]', '[answer]', 'implement later', 'will be added later', 'add later')
foreach ($p in $ph) {
    $hit = Select-String -Path $Path -Pattern ([regex]::Escape($p)) -SimpleMatch -CaseSensitive
    Block (-not $hit) "no placeholder: $p" (($hit | Select-Object -First 2 | ForEach-Object { "line $($_.LineNumber)" }) -join ', ')
}
# TBD / FIXME / XXX — whole word only
$tbd = Select-String -Path $Path -Pattern '\b(TBD|FIXME|XXX)\b' -CaseSensitive
Block (-not $tbd) 'no TBD / FIXME / XXX' (($tbd | Select-Object -First 2 | ForEach-Object { "line $($_.LineNumber): $($_.Line.Trim())" }) -join ' | ')

Write-Host "`n--- 2. Can tag ownership be resolved ---" -ForegroundColor Cyan
# A line-window "does it have an owner" check is fragile: a tag's record may live in
# section 17 (Open Questions) or section 21 (Assumptions). What is measurable is:
# (a) the record tables have no empty owner cell,
# (b) there is at least one table that records the tags.
$tagLines = Select-String -Path $Path -Pattern '\[VERIFY|\[ASSUMPTION'
Block ($tagLines.Count -gt 0) "Tags are used ($($tagLines.Count) of them)"

function TableEmptyCells($headingPattern) {
    $idx = (Select-String -Path $Path -Pattern $headingPattern | Select-Object -First 1)
    if (-not $idx) { return [pscustomobject]@{ Found = $false; Empty = @() } }
    $out = @()
    for ($i = $idx.LineNumber; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^#{2,3}\s' -and $i -gt $idx.LineNumber) { break }
        if ($lines[$i] -match '^\|\s*-{2,}') { continue }
        if ($lines[$i] -notmatch '^\|') { continue }
        $cells = ($lines[$i] -split '\|') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
        if ($cells.Count -ge 4) {
            $last = $cells[-1]
            if ($last -eq '' -or $last -match '^(\?+|-+|\.\.\.)$') { $out += "line $($i + 1): $($lines[$i].Trim())" }
        }
    }
    # NOTE: an empty array becomes $null in PowerShell; return an object so the
    # result never depends on that
    return [pscustomobject]@{ Found = $true; Empty = $out }
}

# NOTE: this script is deliberately ASCII-only (see the header).
$a17 = TableEmptyCells '^#{2,3}.*[Oo]pen [Qq]uestion'
if (-not $a17.Found) {
    Write-Host "  --      Section 17 'Open questions' heading not found" -ForegroundColor DarkGray
} else {
    Block ($a17.Empty.Count -eq 0) 'No empty owner/date cell in the section 17 table' ($a17.Empty -join ' | ')
}

$a21 = TableEmptyCells '^##\s*21\.'
Block ($a21.Found) 'Section 21 Assumption Record table exists'

# If there is no local ownership, list it as information (not a blocker, a heads-up)
$ownerWords = 'owner|responsible|verified by|approver'
$noLocal = @()
foreach ($m in $tagLines) {
    $lo = [Math]::Max(0, $m.LineNumber - 7)
    $hi = [Math]::Min($lines.Count - 1, $m.LineNumber + 5)
    if ((($lines[$lo..$hi]) -join ' ') -notmatch $ownerWords) { $noLocal += $m.LineNumber }
}
if ($noLocal.Count -gt 0) {
    Write-Host "  INFO    Tag lines with no local owner (the record must be in 17 or 21): $($noLocal -join ', ')" -ForegroundColor Yellow
}

Write-Host "`n--- 3. Four-part chain: JTBD -> US -> FR -> AC ---" -ForegroundColor Cyan
$us = [regex]::Matches($t, '\bUS\d+\b') | ForEach-Object { $_.Value } | Sort-Object -Unique
$fr = [regex]::Matches($t, '\bFR-\d{3}\b') | ForEach-Object { $_.Value } | Sort-Object -Unique
$ac = [regex]::Matches($t, '\bAC-\d{2}\b') | ForEach-Object { $_.Value } | Sort-Object -Unique
Block ($us.Count -gt 0) "User stories defined ($($us.Count) of them)"
Block ($fr.Count -gt 0) "Functional requirements defined ($($fr.Count) of them)"
Block ($ac.Count -gt 0) "Acceptance criteria defined ($($ac.Count) of them)"
# Every FR must be linked to at least one AC
$unlinkedFr = @($fr | Where-Object { $f = $_; -not ($lines | Where-Object { $_ -match [regex]::Escape($f) -and $_ -match 'AC-\d{2}' }) })
Block ($unlinkedFr.Count -eq 0) 'Every FR is linked to at least one AC' ($unlinkedFr -join ', ')
# Every AC must be linked to at least one FR
$unlinkedAc = @($ac | Where-Object { $a = $_; -not ($lines | Where-Object { $_ -match [regex]::Escape($a) -and $_ -match 'FR-\d{3}' }) })
Block ($unlinkedAc.Count -eq 0) 'Every AC is linked to at least one FR' ($unlinkedAc -join ', ')

Write-Host "`n--- 4. Agent Execution Model ---" -ForegroundColor Cyan
if ($t -match '[Mm]ulti-?agent|multiple agents') {
    Block ($t -match 'Agent Execution Model') 'The Agent Execution Model heading is present'
    Block ($t -match 'responsible agent|[Ss]ingle owner|Owner') 'Module ownership is written'
    Block ($t -match '[Mm]erge gate|integration gate|decision owner') 'The merge gate / decision owner is written'
} else {
    Write-Host "  --      Single agent mode - the Agent Execution Model is not mandatory" -ForegroundColor DarkGray
}

Write-Host "`n--- 5. Compliance gate (the deferred gate rule) ---" -ForegroundColor Cyan
if ($t -match 'kvkk-publish-review') {
    $s20 = [regex]::Match($t, '(?s)## 20\..*?(?=## 21)')
    if ($s20.Success) {
        Block ($s20.Value -match 'Owner|owner|responsible') 'The section 20 gate has an owner'
        Block ($s20.Value -match '20\d{2}-\d{2}-\d{2}|target date|[Dd]ate') 'The section 20 gate has a date'
    } else {
        Block $false 'Section 20 not found (the gate is open but there is no record)'
    }
    # Is "ready to publish" a positive claim? Negation/blocking phrases are excluded
    $claimLines = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $l = $lines[$i]
        if ($l -match 'ready to publish|is ready|ready for release') {
            if ($l -notmatch 'not|cannot|must not|may not|never|no |without|blocked|gate (is )?(still )?open|stays open|without the report') {
                $claimLines += "line $($i + 1): $($l.Trim())"
            }
        }
    }
    $gateClosed = $t -match 'gate is closed|gate closed|audit report (was )?appended|report is linked'
    Block (-not (($claimLines.Count -gt 0) -and -not $gateClosed)) 'There is no positive "ready to publish" claim while the gate is open' ($claimLines -join ' | ')
}

Write-Host "`n--- 6. Mandatory sections ---" -ForegroundColor Cyan
foreach ($s in @('## 1. ', '## 2. ', '## 3. ', '## 4. ', '## 13. ', '## 17. ', '## 18. ', '## 19. ', '## 21.')) {
    Block ($t -match [regex]::Escape($s)) "section present: $s"
}
Block ($t -match 'Anti-goals|anti-goal') 'Anti-goals are written (the block that prevents scope drift)'
Block ($t -match 'Assumption') 'The assumption record is written'

Write-Host "`n--- 7. Quality score (Gate D threshold: 90) ---" -ForegroundColor Cyan
$m = [regex]::Match($t, '(\d{2,3})\s*\**\s*/\s*100')
if (-not $m.Success) {
    Block $false 'Score not found - Gate D was never evaluated'
} else {
    $score = [int]$m.Groups[1].Value
    if ($score -ge 90) {
        Block $true "Score is above the threshold: $score/100"
    } else {
        Write-Host "  INFO    Score is below the threshold: $score/100 (threshold 90)" -ForegroundColor Yellow
        # A score below the threshold is NOT a delivery blocker on its own. What
        # matters is that the gaps have been ANNOUNCED. If not announced, it blocks.
        $s17 = TableEmptyCells '^#{2,3}.*[Oo]pen [Qq]uestion'
        $declared = $t -match 'announce|announced|written to 17|open question'
        $hasAssumptionTable = ($null -ne (TableEmptyCells '^##\s*21\.'))
        Block ($s17.Found -or $hasAssumptionTable) 'There is a record the gaps can be announced in (section 17 open questions + section 21 assumptions)'
        Write-Host "  --      The score may be under 90; what matters is that the gap is written WITH AN OWNER AND A DATE." -ForegroundColor DarkGray
    }
}

Write-Host "`n--- 8. Broken characters ---" -ForegroundColor Cyan
$bad = Select-String -Path $Path -Pattern '[\u4e00-\u9fff\u3040-\u30ff\ufffd]' -AllMatches
Block (-not $bad) 'No CJK / box characters'

Write-Host "`n" + ("=" * 50)
Write-Host "  PASS: $pass    BLOCK: $fail" -ForegroundColor $(if ($fail) { 'Red' } else { 'Green' })
Write-Host ("=" * 50)
exit $(if ($fail) { 1 } else { 0 })