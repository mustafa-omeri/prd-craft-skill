<#
  prd-craft / kvkk-publish-review — structural validation script
  Run:         pwsh -File ./validate.ps1     (or powershell -File ./validate.ps1)
  Exit code:   0 = every check passed · 1 = at least one check is outstanding

  ⛔ This file must be UTF-8 **with BOM**, and every Get-Content must use
     -Encoding UTF8. Otherwise PowerShell 5.1 (`powershell`) reads files as ANSI
     and mangles non-ASCII comparisons — checks then report KALDI for the wrong
     reason. pwsh 7 defaults to UTF-8, so it gives the right answer even without
     a BOM, which is exactly why running only one engine hides the bug.

  ⛔ This script measures STRUCTURE, not correctness. Green means "the rules are
     consistent with each other". It does not mean "the rules are right".
#>

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$fail = 0
$pass = 0

function Check($ok, $label, $detail = '') {
    if ($ok) {
        $script:pass++
        Write-Host "  PASS    $label" -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host "  KALDI   $label" -ForegroundColor Red
        if ($detail) { Write-Host "          $detail" -ForegroundColor DarkGray }
    }
}

# ⛔ This list scans the SKILL SET ONLY. The script used to live inside yeni/, so
#    "-Recurse $root" happened to be narrow. After moving to the repository root
#    the same pattern also picked up knowledge-base.md, HANDOFF.md, docs/ and
#    testProject/, and the "broken character" check went red on the user's own
#    notes. The scope is now stated explicitly.
$md = @()
foreach ($d in @((Join-Path $root 'prd-craft'), (Join-Path $root 'kvkk-publish-review'))) {
    if (Test-Path $d) { $md += Get-ChildItem -Recurse $d -File -Filter *.md }
}
$md += Get-Item (Join-Path $root 'ROUTING.md') -ErrorAction SilentlyContinue
$md = $md | Where-Object { $_ }
$prd = Join-Path $root 'prd-craft'
$kvkk = Join-Path $root 'kvkk-publish-review'

Write-Host "`n=== 1. Directory structure ===" -ForegroundColor Cyan
foreach ($d in @(
    "$prd\references", "$prd\templates",
    "$kvkk\references", "$kvkk\templates"
)) { Check (Test-Path $d) $d.Replace("$root\", '') }

Write-Host "`n=== 2. Frontmatter ===" -ForegroundColor Cyan
foreach ($s in @("$prd\SKILL.md", "$kvkk\SKILL.md")) {
    $dir = Split-Path (Split-Path $s -Parent) -Leaf
    # ⛔ With $ErrorActionPreference='Stop' a bare Get-Content kills the script on a
    #    missing file and every remaining check is silently skipped. Ask existence first.
    if (-not (Test-Path $s)) { Check $false "$dir : SKILL.md exists" 'file missing'; continue }
    $l = Get-Content $s -Encoding UTF8
    $name = ($l | Select-String '^name:\s*(\S+)').Matches.Groups[1].Value
    Check ($l[0] -eq '---') "$dir : line 1 is '---'"
    Check ($name -eq $dir) "$dir : the name field matches the folder name ($name)"
    Check ([bool]($l | Select-String '^description:')) "$dir : description is present"
    Check ([bool]($l | Select-String '^argument-hint:')) "$dir : argument-hint is present"

    # ⛔ The 1536 character limit: the official documentation states that the merged
    #    "description" + "when_to_use" form is TRUNCATED at 1536 characters in the
    #    skill list. What gets cut is the end of the trigger — the part that decides
    #    whether the skill fires. Ambiguity is not reduced, it is increased.
    #    This check was added on 2026-10-06; prd-craft was 1596 characters before
    #    and WAS BEING TRUNCATED, and nobody had noticed.
    $desc = ($l | Select-String '^description:\s*(.+)$').Matches.Groups[1].Value
    Check ($desc.Length -gt 0 -and $desc.Length -le 1536) `
        "$dir : description is $($desc.Length) characters (at most 1536)"

    # ⛔ Second person scan — narrowed with a 25 case sample (2026-10-06).
    #    ⛔ THE FIRST VERSION PRODUCED A FALSE ALARM and the check said "KALDI": in
    #    "yazılmış bir PRD'yi" the "yazılmış" is 3rd person, not "yaz" + "ıl-mış".
    #    The mirror image of that trap: the check went red because of its own
    #    scanning error, not because of the behaviour.
    #
    #    Rules:
    #      1) Only the pronoun plus an unambiguous 2nd person verb ending.
    #         -In/-Un (imperative) and -In (3rd person possessive: yay-ın,
    #         bas-ın, referans-ın) COLLIDE -> not detectable, deliberately out of
    #         scope.
    #      2) The verb endings are anchored to a stem-final -r/-z so that nouns like
    #         "insan", "kesin" are not caught.
    #      3) The body is not scanned, ONLY description: — the body addresses the
    #         user and is allowed to.
    #
    # ⛔ The pattern below is DELIBERATELY in Turkish, and the Turkish characters in
    #    this comment are deliberate too. The shipped skills are English, but a user
    #    may well write the description in Turkish, and then the same rule applies:
    #    the description addresses the user. Do not "translate" this regex.
    $sp = '(?i)\b(sen|sana|seni|senin|seninle|siz|sizi|sizin|sizinle)\b' +
          '|\w+[rz]s[ae]n\b' +
          '|\w+[rz]s[ıiu]n[ıiu]z\b' +
          '|\w+[rz]s[ıiu]nd[ıiu]r\b' +
          '|\w+[rz]s[ıiu]n\b'
    $hits = [regex]::Matches($desc, $sp)
    Check ($hits.Count -eq 0) `
        "$dir : description has no second person ($($hits.Count) matches)"
}

Write-Host "`n=== 3. SKILL.md 500 line limit (progressive disclosure) ===" -ForegroundColor Cyan
foreach ($s in @("$prd\SKILL.md", "$kvkk\SKILL.md")) {
    $dir = Split-Path (Split-Path $s -Parent) -Leaf
    if (-not (Test-Path $s)) { Check $false "$dir : SKILL.md exists" 'file missing'; continue }
    $n = (Get-Content $s -Encoding UTF8).Count
    Check ($n -le 500) "$dir : $n lines (at most 500)"
}

Write-Host "`n=== 3b. Is the heading structure intact ===" -ForegroundColor Cyan
# ⛔ When an edit deletes an H2 heading, the following section falls INSIDE it and
#    no check notices. The line count stays at 500 and the file looks "valid".
#    Protection: numbered H2 headings start at 0, with no gaps and no duplicates.
foreach ($s in @("$prd\SKILL.md", "$kvkk\SKILL.md")) {
    $dir = Split-Path (Split-Path $s -Parent) -Leaf
    if (-not (Test-Path $s)) { continue }
    $lines = Get-Content $s -Encoding UTF8
    $nums = @()
    foreach ($l in $lines) {
        if ($l -match '^## (\d+)\.') { $nums += [int]$Matches[1] }
    }
    if ($nums.Count -eq 0) {
        Check $false "$dir : numbered H2 headings exist" 'no "## N." heading was found'
        continue
    }
    $expected = 0..($nums.Count - 1)
    $seqOk = -not (Compare-Object $expected $nums -SyncWindow 0)
    $uniqOk = ($nums | Sort-Object -Unique).Count -eq $nums.Count
    Check ($seqOk -and $uniqOk) `
        "$dir : the H2 heading structure is intact (0-$($nums[-1]), $($nums.Count) headings)" `
        "the order is broken or there is a duplicate: $($nums -join ',')"
}

Write-Host "`n=== 4. Do the cross references resolve ===" -ForegroundColor Cyan
$broken = @()
foreach ($f in $md) {
    $base = $f.FullName.Substring($root.Length + 1).Split('\')[0]
    $t = Get-Content $f.FullName -Raw -Encoding UTF8
    # ⛔ Verified bug: only group 1 (the folder name) was used when building the
    #    path; the FILE NAME never entered it. Test-Path therefore always asked
    #    about the FOLDER, never the file -> this check could never return KALDI.
    foreach ($m in [regex]::Matches($t, '`(references|templates)/([a-z0-9\-\.]+\.md)`')) {
        $rel = "$($m.Groups[1].Value)\$($m.Groups[2].Value)"
        $target = Join-Path $root "$base\$rel"
        if (-not (Test-Path $target)) {
            $broken += "$($f.Name) -> $($m.Value)"
        }
    }
}
Check ($broken.Count -eq 0) 'Every reference resolves' ($broken -join '; ')

Write-Host "`n=== 5. No content loss (key terms from the previous version) ===" -ForegroundColor Cyan
# ⛔ This list is a "content loss" guard: if a file is rewritten or translated and
#    one of these terms silently disappears, it reports KALDI. The terms are
#    written against the English SKILL.md/references version.
$all = ($md | Get-Content -Raw -Encoding UTF8) -join "`n"
$must = @(
    'Ubiquitous', 'Scenario Outline', 'RFC 2119', 'INVEST', '60%', 'so I can',
    'Anti-goals', 'llms.txt', 'soft-404', 'hreflang', 'Core Web Vitals', 'art. 11',
    'cross-border', 'To be verified', 'AI Build Summary', 'Component Inventory',
    'State Management', 'Evaluation strategy', 'Concept Glossary',
    'deep module', 'Independent test', 'Definition of Ready', 'WIP', 'Change Request',
    'Tracer', 'Merge gate', 'Delivery Gate', 'Agent Execution Model',
    'Multi-agent', 'ail-fast', 'stderr', 'project root', 'could not verify', 'cron'
)
$allLower = $all.ToLowerInvariant()
foreach ($m in $must) {
    Check ($allLower.Contains($m.ToLowerInvariant())) $m
}

Write-Host "`n=== 6. Are YL-01..YL-33 and KV-01..KV-06 complete ===" -ForegroundColor Cyan
$pubPath = "$kvkk\references\publishing-and-compliance-blocks.md"
if (-not (Test-Path $pubPath)) {
    Check $false 'publishing-and-compliance-blocks.md exists' 'file missing - 39 checklist rows cannot be scanned'
} else {
    $pub = Get-Content $pubPath -Raw -Encoding UTF8
    $missing = @()
    1..33 | ForEach-Object { $id = 'YL-{0:D2}' -f $_; if ($pub -notmatch $id) { $missing += $id } }
    1..6 | ForEach-Object { $id = 'KV-{0:D2}' -f $_; if ($pub -notmatch $id) { $missing += $id } }
    Check ($missing.Count -eq 0) 'All 39 checklist rows are present' ($missing -join ', ')
}

Write-Host "`n=== 7. Broken characters (CJK / boxes) ===" -ForegroundColor Cyan
$bad = Select-String -Path $md.FullName -Pattern '[\u4e00-\u9fff\u3040-\u30ff\ufffd]' -AllMatches
Check (-not $bad) 'No CJK or replacement characters' (($bad | Select-Object -First 3 | ForEach-Object { "$($_.Filename):$($_.LineNumber)" }) -join ', ')

Write-Host "`n=== 8. Design rules ===" -ForegroundColor Cyan
# ⛔ When the file is missing an empty string is used, so the .Contains() checks
#    below report KALDI on their own. Assigning $null instead would kill the script.
$skillPath = "$prd\SKILL.md"
$skill = if (Test-Path $skillPath) { Get-Content $skillPath -Raw -Encoding UTF8 } else { '' }
Check ([bool]$skill) 'prd SKILL.md was read' 'file missing - the content checks below ran against empty text'
Check ($skill.Contains('Gate 0.6')) 'Gate 0.6 (execution model) is in SKILL.md'
Check ($skill.Contains('Gate 0.2')) 'Gate 0.2 (brownfield pre-scan) is in SKILL.md'
Check ($skill.Contains('kvkk-publish-review')) 'The compliance gate is routed to the other skill'
Check ($skill.Contains('Channel C')) 'The non-interactive channel is defined'
Check ($skill.Contains('Gate B') -and $skill.Contains('Gate D')) 'There are two separate quality gates (B: brief, D: document)'
Check ($skill.Contains('Skip deliberately')) 'The unanswered question protocol is defined (2.1)'
Check ($skill.Contains('Deferred Gate Rule')) 'The deferred gate rule is defined'
Check (-not $skill.Contains('[owner will decide]')) 'There is no placeholder in SKILL.md'
Check (Test-Path "$prd\scripts\validate-prd.ps1") 'The PRD validation script exists'
$tplPath = "$prd\templates\prd-template.md"
$prdTpl = if (Test-Path $tplPath) { Get-Content $tplPath -Raw -Encoding UTF8 } else { '' }
Check ([bool]$prdTpl) 'prd-template.md was read' 'file missing'
Check (-not $prdTpl.Contains('VARIANT 1')) 'The PRD template does not carry all 4 methodology variants together'
Check ($prdTpl.Contains('60%')) 'The PRD template has the scope threshold rule'
Check ($prdTpl.Contains('Agent Execution Model')) 'The PRD template has an Agent Execution Model section'
Check ($prdTpl.Contains('[VERIFY]') -or $prdTpl.Contains('Owner')) 'The PRD template has the tag ownership rule'
$hoPath = "$prd\templates\handoff-template.md"
$hoRaw = if (Test-Path $hoPath) { Get-Content $hoPath -Raw -Encoding UTF8 } else { '' }
$handoff = $hoRaw.ToLowerInvariant()
Check ([bool]$hoRaw) 'handoff-template.md was read' 'file missing'
Check ($handoff.Contains('does not exist') -and $handoff.Contains('is stale') -and
       $handoff.Contains('still a template')) `
    'The HANDOFF template covers the absent/empty/filled/stale states'
Check ($handoff.Contains('no verified trap occurred in this session')) 'The HANDOFF template has the "do not invent traps" rule'
Check ($handoff.Contains('fixture')) 'The HANDOFF template has the fixture/other-job rule'

Write-Host "`n=== 9. Does SKILL.md route to the 4 delivery methodologies ===" -ForegroundColor Cyan
foreach ($m in @('delivery-mvp', 'delivery-agile', 'delivery-kanban', 'delivery-waterfall')) {
    Check ($skill.Contains($m)) $m
    Check (Test-Path "$prd\references\$m.md") "$m.md exists"
}

Write-Host "`n=== 10. Are the past-gate lessons recorded ===" -ForegroundColor Cyan
$errPath = "$prd\references\common-mistakes.md"
$errs = if (Test-Path $errPath) { Get-Content $errPath -Raw -Encoding UTF8 } else { '' }
Check ([bool]$errs) 'common-mistakes.md was read' 'file missing'
foreach ($e in @('methodology was locked before the code scan',
        'The score was given for what was going to be written',
        'Effort was fabricated', 'A deferred gate was left unowned',
        'A placeholder was left behind')) {
    Check ($errs.Contains($e)) "lesson recorded: $e"
}

Write-Host "`n=== 11. Eval files (at least 3 positive + 2 negative + 1 behavioural per skill) ===" -ForegroundColor Cyan
foreach ($s in @($prd, $kvkk)) {
    $n = Split-Path $s -Leaf
    $f = Join-Path $s 'evals\evals.json'
    if (-not (Test-Path $f)) { Check $false "$n : evals/evals.json exists" 'the skill has no eval cases'; continue }
    Check $true "$n : evals/evals.json exists"
    try {
        $j = Get-Content $f -Raw -Encoding UTF8 | ConvertFrom-Json
        $all = @($j | ForEach-Object { $_.evals })
        $pos = @($all | Where-Object { $_.type -eq 'positive' })
        $neg = @($all | Where-Object { $_.type -eq 'negative' })
        $beh = @($all | Where-Object { $_.type -eq 'behavioral' })
        Check ($pos.Count -ge 3) "$n : positive triggers >= 3" "found: $($pos.Count)"
        Check ($neg.Count -ge 2) "$n : negative triggers >= 2" "found: $($neg.Count)"
        Check ($beh.Count -ge 1) "$n : behavioural cases >= 1" "found: $($beh.Count)"
        $noExpect = @($all | Where-Object { -not $_.expected_behavior -or $_.expected_behavior.Count -eq 0 })
        Check ($noExpect.Count -eq 0) "$n : expected_behavior is filled for every eval case" `
            (($noExpect | ForEach-Object { $_.id }) -join ', ')
        $dup = @($all | Group-Object id | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
        Check ($dup.Count -eq 0) "$n : eval ids are unique" ($dup -join ', ')
    } catch {
        Check $false "$n : evals.json is valid JSON" $_.Exception.Message
    }
}

Write-Host "`n=== 12. Is the skill set tied to a fixture (the global principle) ===" -ForegroundColor Cyan
# The patterns are assembled piecewise so the script does not catch its own source.
# ⛔ The list was widened (4 -> 9): the goal is not a coarse pattern but only that
#    the project name has not leaked in any form. It passes for double variables
#    (link-checker-prd, com\.orca).
$pats = @('test' + 'Project', 'com\.orca', 'link-checker', 'task-notification',
    'task-notification-prd', 'link-checker-prd', 'com/orca', 'TaskService',
    'JpaRepository')
$scan = Get-ChildItem -Recurse $root -File -Include *.md, *.ps1 |
    Where-Object { $_.FullName -ne $MyInvocation.MyCommand.Path }
$leak = Select-String -Path $scan.FullName -Pattern $pats -AllMatches
Check (-not $leak) 'No test fixture name has leaked into the skills' `
    ((($leak | Select-Object -First 3) | ForEach-Object { "$($_.Filename):$($_.LineNumber)" }) -join ', ')

# ⛔ GLOBALITY: the skill set must not be tied to ONE stack. The pre-scan file has
#    to recognise several stacks; with only one, the skill does not work elsewhere.
$ksPath = Join-Path $root 'prd-craft\references\codebase-scan.md'
if (Test-Path $ksPath) {
    $ks = (Get-Content $ksPath -Raw -Encoding UTF8).ToLowerInvariant()
    $stacks = @{
        'java' = 'pom.xml'; 'node' = 'package.json'; 'python' = 'pyproject.toml'
        'go' = 'go.mod'; 'rust' = 'cargo.toml'; 'dotnet' = '.csproj'
        'flutter/mobile' = 'pubspec.yaml'; 'php' = 'composer.json'
    }
    $found = @($stacks.Keys | Where-Object { $ks.Contains($stacks[$_]) })
    Check ($found.Count -ge 5) `
        "the skill set recognises several stacks ($($found.Count)/8: $($found -join ', '))" `
        'a skill tied to one stack does not work in another project'
} else {
    Check $false 'codebase-scan.md exists' 'the stack detection table cannot be read'
}

Write-Host "`n=== 12b. Are the routing rules reachable ===" -ForegroundColor Cyan
# ⛔ Live measurement: a skill cannot MANAGE whether the agent enters it. If the
#    decision is made in the SKILL.md body, that body is never read. Three
#    independent runs failed 3/3. This lint stops the routing / out-of-scope rule
#    from living ONLY in a body.
$routing = Join-Path $root 'ROUTING.md'
Check (Test-Path $routing) 'ROUTING.md exists (the single point where the decision is made)'
if (Test-Path $routing) {
    $rt = [IO.File]::ReadAllText($routing)
    $rtL = $rt.ToLowerInvariant()
    # In ROUTING.md the declaration is written in a code block, without backticks.
    Check ($rtL.Contains('skill: <')) 'ROUTING.md defines the declaration format'
    # ⛔ When no line matches, `none` must not be produced — in live measurement
    #    this pushed the agent outside the skill to invent its own rule
    #    (behavior-cli-type-ssrf).
    # ⛔ Weak patterns produce fake checks. 'audit' and 'rationale' each occur in 8
    #    separate places in ROUTING.md, so looking at the single WORD always
    #    passes. These rows were mutation-tested: deleting one word did not report
    #    KALDI. Below, the full LINE text is searched.
    Check ($rtL.Contains('undecided')) `
        'ROUTING.md offers the undecided option for an unmatched request'
    Check ($rtL.Contains('kv-01..kv-06')) `
        'ROUTING.md covers the behaviour audit of an existing tool'
    Check ($rtL.Contains('rationale: <one sentence>')) `
        'ROUTING.md requires a rationale field in the declaration'
    Check ($rtL.Contains('prd-craft') -and $rtL.Contains('kvkk-publish-review')) `
        'ROUTING.md names both skills in the routing table'
}

Write-Host "`n=== 12c. Is the KVKK jurisdiction warning visible ===" -ForegroundColor Cyan
# ⛔ The skill is tied to Turkish law (KVKK 6698). When published in a global
#    repository, projects outside Turkey use it for its mechanics; so the warning
#    must be in BOTH the description and the body. Without it the skill reads as
#    if it were only for Turkish users.
$kDesc = if (Test-Path "$kvkk\SKILL.md") { (Get-Content "$kvkk\SKILL.md" -Encoding UTF8 | Select-String -Pattern '^description:' | Select-Object -First 1) } else { $null }
Check ([bool]$kDesc -and $kDesc.Line.ToLowerInvariant().Contains('jurisdiction warning')) `
    'kvkk-publish-review : the description carries the jurisdiction warning'
$kBody = if (Test-Path "$kvkk\SKILL.md") { (Get-Content "$kvkk\SKILL.md" -Raw -Encoding UTF8) } else { '' }
Check ($kBody.Contains('JURISDICTION')) `
    'kvkk-publish-review : the body carries the jurisdiction warning'

# ⛔ One derived fact, one source: SKILL.md says "7-type matrix", so the matrix
#    must really have 7 rows. It used to say 6 while the matrix had 7 rows.
$mxPath = Join-Path $root 'kvkk-publish-review\references\kvkk-compliance-audit.md'
if (Test-Path $mxPath) {
    $mx = Get-Content $mxPath -Encoding UTF8
    $hdr = ($mx | Select-String -Pattern '^\|\s*Application type\s*\|' | Select-Object -First 1)
    $rows = 0
    if ($hdr) {
        # LineNumber is 1-based, the array is 0-based -> the heading's real index
        $start = $hdr.LineNumber - 1
        for ($i = $start + 1; $i -lt $mx.Count; $i++) {
            if ($mx[$i] -notmatch '^\|') { break }               # the table ended
            if ($mx[$i] -match '^\|\s*-{2,}') { continue }       # separator row
            $rows++
        }
    }
    # ⛔ Trap: verify not only the ROW COUNT but also the NUMBER SKILL.md states.
    #    With 7 rows "7-type" looks consistent, but SKILL.md saying "6-type"
    #    while the matrix has 7 rows is a FALSE statement. A leftover ("6-type"
    #    or "8-type") must also report KALDI.
    $declared = if ($kBody -match '(\d+)-type matrix') { [int]$Matches[1] } else { -1 }
    Check ($declared -eq $rows) `
        "kvkk type matrix: SKILL.md says $declared-type, the matrix has $rows rows" `
        "SKILL.md and the matrix must agree (SKILL.md: $declared, matrix: $rows)"
    Check ($rows -eq 7) "the kvkk application type matrix has 7 rows ($rows)" `
        "expected 7 rows, found $rows"
}

# Every SKILL.md: (a) carries the declaration rule, (b) does not delegate the
# routing decision into the body
foreach ($sp in @("$prd\SKILL.md", "$kvkk\SKILL.md")) {
    $d = Split-Path (Split-Path $sp -Parent) -Leaf
    if (-not (Test-Path $sp)) { Check $false "$d : SKILL.md exists" 'file missing'; continue }
    $spL = (Get-Content $sp -Raw -Encoding UTF8).ToLowerInvariant()
    # ⛔ 'skill:' alone is misleading: the Turkish phrase "Ayrı skill:" also
    #    satisfies it. The pattern shows the declaration FORMAT: backtick plus
    #    the opening angle bracket.
    Check ($spL.Contains('`skill: <')) "$d : the decision declaration is mandatory and its format is written"
    Check ($spL.Contains('routing.md')) "$d : it points at the declaration table"
    # The routing decision is made in ROUTING.md, not in the body
    Check ($spL.Contains('decision declaration')) `
        "$d : it is written that the decision is made in ROUTING.md, not in the body"
}

Write-Host "`n=== 13. Does the eval runner work (L0) ===" -ForegroundColor Cyan
$runner = Join-Path $root 'evals\run-evals.mjs'
if (-not (Test-Path $runner)) {
    Check $false 'evals/run-evals.mjs exists' 'no runner - the eval definitions are never verified'
} elseif (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Check $false 'node was found (needed by the runner)' 'Node.js is not installed'
} else {
# The runner prints an ASCII summary line so it survives any encoding.
    $out = & node $runner --selftest 2>&1 | Out-String
    if ($out -match 'L0_SUMMARY passed=(\d+) failed=(\d+)') {
        $p = [int]$Matches[1]; $f2 = [int]$Matches[2]
        Check ($f2 -eq 0) "the eval runner reports zero L0 failures ($($p + $f2) checks)" `
            (($out -split "`n" | Select-String 'KALDI' | Select-Object -First 3) -join ' | ')
    } else {
        Check $false 'the eval runner produced the L0 summary line' 'L0_SUMMARY could not be parsed'
    }
    Check ($out -match 'not verified') 'the runner warns that the skill is not verified' `
        'if the runner does not say that L1 was not run after L0, it creates an impression of evidence'
}

Write-Host "`n" + ("=" * 46)
Write-Host "  PASS: $pass    KALDI: $fail" -ForegroundColor $(if ($fail) { 'Red' } else { 'Green' })
Write-Host ("=" * 46)
exit $(if ($fail) { 1 } else { 0 })