<#
  prd-craft / kvkk-publish-review — yapı doğrulama betiği
  Çalıştırma:  pwsh -File .\validate.ps1     (veya powershell -File .\validate.ps1)
  Çıkış kodu:  0 = tüm kontroller geçti · 1 = en az bir kontrol kaldı

  ⛔ Bu dosya UTF-8 BOM'lu olmalı ve her Get-Content -Encoding UTF8 ile okumalı.
     Aksi halde PowerShell 5.1 (`powershell`) dosyaları ANSI sanıp Türkçe metin
     karşılaştırmalarını bozar — 17 kontrol yanlış KALDI verir. pwsh 7 varsayılan
     olarak UTF-8 okuduğu için BOM olmasa da doğru sonucu verir.
#>

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$fail = 0
$pass = 0

function Check($ok, $label, $detail = '') {
    if ($ok) {
        $script:pass++
        Write-Host "  GECTI   $label" -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host "  KALDI   $label" -ForegroundColor Red
        if ($detail) { Write-Host "          $detail" -ForegroundColor DarkGray }
    }
}

# ⛔ Tuzak: bu liste yalniz SKILL SETINI tarar. Betik eskiden yeni/ icinde
#    yasidiigi icin "-Recurse $root" kendiliginden dar kaldi. Repo kokune
#    tasindiktan sonra ayni desen knowledge-base.md, HANDOFF.md, docs/ ve
#    testProject/ dosyalarini da kapsadi ve "bozuk karakter" kontrolu
#    kullaniciya ait notlardan kirmizi verdi. Kapsam ACIKCA yazilir.
$md = @()
foreach ($d in @((Join-Path $root 'prd-craft'), (Join-Path $root 'kvkk-publish-review'))) {
    if (Test-Path $d) { $md += Get-ChildItem -Recurse $d -File -Filter *.md }
}
$md += Get-Item (Join-Path $root 'ROUTING.md') -ErrorAction SilentlyContinue
$md = $md | Where-Object { $_ }
$prd = Join-Path $root 'prd-craft'
$kvkk = Join-Path $root 'kvkk-publish-review'

Write-Host "`n=== 1. Dizin yapisi ===" -ForegroundColor Cyan
foreach ($d in @(
    "$prd\references", "$prd\templates",
    "$kvkk\references", "$kvkk\templates"
)) { Check (Test-Path $d) $d.Replace("$root\", '') }

Write-Host "`n=== 2. Frontmatter ===" -ForegroundColor Cyan
foreach ($s in @("$prd\SKILL.md", "$kvkk\SKILL.md")) {
    $dir = Split-Path (Split-Path $s -Parent) -Leaf
    # ⛔ $ErrorActionPreference='Stop' yuzunden eksik dosyada Get-Content betigi
    #    oldurur ve kalan tum kontroller sessizce atlanir. Once varligini sor.
    if (-not (Test-Path $s)) { Check $false "$dir : SKILL.md mevcut" 'dosya yok'; continue }
    $l = Get-Content $s -Encoding UTF8
    $name = ($l | Select-String '^name:\s*(\S+)').Matches.Groups[1].Value
    Check ($l[0] -eq '---') "$dir : satir 1 '---'"
    Check ($name -eq $dir) "$dir : name alani dizin adiyla ayni ($name)"
    Check ([bool]($l | Select-String '^description:')) "$dir : description var"
    Check ([bool]($l | Select-String '^argument-hint:')) "$dir : argument-hint var"

    # ⛔ 1536 karakter siniri: resmi dokuman "description" + "when_to_use" birlestirilmis
    #    halinin skill listesinde 1536 karakterde KIRPILDIGINI yaziyor. Kirpilan kisim
    #    tetikleyicinin sonu — yani skill'i tetikleyen mi belirsizlesir, belirsizlesmez.
    #    Bu kontrol 2026-10-06'da eklendi; onceden prd-craft 1596 karakterti ve
    #    KIRPILIYORDU, kimse fark etmisti.
    $desc = ($l | Select-String '^description:\s*(.+)$').Matches.Groups[1].Value
    Check ($desc.Length -gt 0 -and $desc.Length -le 1536) `
        "$dir : description $($desc.Length) karakter (en fazla 1536)"

    # ⛔ Ikinci tekil sahis taramasi — 25 vakalik sinama ile daraltildi (2026-10-06).
    #    ⛔ ILK YAZIM YANLIS ALARM URETTI ve kontrol "KALDI" dedi: "yazılmış bir PRD'yi"
    #    ifadesindeki "yazılmış" 3. sahis edilidir, "yaz" + "ıl-mış" degil. Tuzak 20'nin
    #    ters yonu: kontrol kirmizi verdi ama davranistan degil, kendi tarama hatasindan.
    #
    #    Kurallar:
    #      1) Yalniz zarf + belirgin 2.tekil fiil cekimi. -In/-Un (zorunlu emir) ve -In
    #         (3.tekil iyelik: yay-ın, bas-ın, referans-ın) ORTUSIR -> tespit edilemez,
    #         bilincli olarak kapsam disi birakildi.
    #      2) "insan", "kesin" gibi isimleri yakalamamak icin fiil ekleri kok sonu -r/-z
    #         tasma ekine baglanir.
    #      3) Govde taranmaz, YALNIZCA description: govde kullaniciya hitap eder ve
    #         etmemiz gerekir.
    $sp = '(?i)\b(sen|sana|seni|senin|seninle|siz|sizi|sizin|sizinle)\b' +
          '|\w+[rz]s[ae]n\b' +
          '|\w+[rz]s[ıiu]n[ıiu]z\b' +
          '|\w+[rz]s[ıiu]nd[ıiu]r\b' +
          '|\w+[rz]s[ıiu]n\b'
    $hits = [regex]::Matches($desc, $sp)
    Check ($hits.Count -eq 0) `
        "$dir : description ikinci tekil sahis yok ($($hits.Count) eslesme)"
}

Write-Host "`n=== 3. SKILL.md 500 satir siniri (progressive disclosure) ===" -ForegroundColor Cyan
foreach ($s in @("$prd\SKILL.md", "$kvkk\SKILL.md")) {
    $dir = Split-Path (Split-Path $s -Parent) -Leaf
    if (-not (Test-Path $s)) { Check $false "$dir : SKILL.md mevcut" 'dosya yok'; continue }
    $n = (Get-Content $s -Encoding UTF8).Count
    Check ($n -le 500) "$dir : $n satir (en fazla 500)"
}

Write-Host "`n=== 3b. Baslik yapisi butun mu (tuzak 1) ===" -ForegroundColor Cyan
# ⛔ Tuzak 1: bir edit bir H2 basligini sildiginde, sonraki bolum onun ICINE girer ve
#    hicbir kontrol bunu yakalamaz. Satir sayisi 500'de kalir, dosya "gecerli" gorunur.
#    Koruma: numarali H2 basliklar 0'dan baslar, araliksiz ve tekilsiz olmak zorundadir.
foreach ($s in @("$prd\SKILL.md", "$kvkk\SKILL.md")) {
    $dir = Split-Path (Split-Path $s -Parent) -Leaf
    if (-not (Test-Path $s)) { continue }
    $lines = Get-Content $s -Encoding UTF8
    $nums = @()
    foreach ($l in $lines) {
        if ($l -match '^## (\d+)\.') { $nums += [int]$Matches[1] }
    }
    if ($nums.Count -eq 0) {
        Check $false "$dir : numarali H2 basligi var" 'hicbir "## N." basligi bulunamadi'
        continue
    }
    $expected = 0..($nums.Count - 1)
    $seqOk = -not (Compare-Object $expected $nums -SyncWindow 0)
    $uniqOk = ($nums | Sort-Object -Unique).Count -eq $nums.Count
    Check ($seqOk -and $uniqOk) `
        "$dir : H2 basligi yapisi butun (0-$($nums[-1]), $($nums.Count) baslik)" `
        "sira bozuk veya tekrar var: $($nums -join ',')"
}

Write-Host "`n=== 4. Capraz referanslar cozuluyor mu ===" -ForegroundColor Cyan
$broken = @()
foreach ($f in $md) {
    $base = $f.FullName.Substring($root.Length + 1).Split('\')[0]
    $t = Get-Content $f.FullName -Raw -Encoding UTF8
    # ⛔ Dogrulanmis hata: yol kurulurken yalnizca Grup 1 (dizin adi) kullaniliyordu,
    #    dosya adi hicbir yere girmiyordu. Test-Path her zaman KLASORUN varligini
    #    soruyordu, dosyaninkini degil -> bu kontrol hicbir zaman KALDI veremiyordu.
    foreach ($m in [regex]::Matches($t, '`(references|templates)/([a-z0-9\-\.]+\.md)`')) {
        $rel = "$($m.Groups[1].Value)\$($m.Groups[2].Value)"
        $target = Join-Path $root "$base\$rel"
        if (-not (Test-Path $target)) {
            $broken += "$($f.Name) -> $($m.Value)"
        }
    }
}
Check ($broken.Count -eq 0) "Tum referanslar cozuluyor" ($broken -join '; ')

Write-Host "`n=== 5. Icerik kaybi yok mu (eski surum anahtar ogeleri) ===" -ForegroundColor Cyan
# ⛔ Bu liste "icerik kaybi" korumasidir: bir dosya yeniden yazildiginda ya da
#    cevrildiginde bu terimlerden biri sessizce kaybolursa KALDI verir.
#    Terimler ingilizce SKILL.md/references sürümüne gore yazilmistir.
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

Write-Host "`n=== 6. YL-01..YL-33 ve KV-01..KV-06 tam mi ===" -ForegroundColor Cyan
$pubPath = "$kvkk\references\publishing-and-compliance-blocks.md"
if (-not (Test-Path $pubPath)) {
    Check $false 'publishing-and-compliance-blocks.md mevcut' 'dosya yok - 39 kontrol satiri taranamaz'
} else {
    $pub = Get-Content $pubPath -Raw -Encoding UTF8
    $missing = @()
    1..33 | ForEach-Object { $id = 'YL-{0:D2}' -f $_; if ($pub -notmatch $id) { $missing += $id } }
    1..6 | ForEach-Object { $id = 'KV-{0:D2}' -f $_; if ($pub -notmatch $id) { $missing += $id } }
    Check ($missing.Count -eq 0) '39 kontrol satiri eksiksiz' ($missing -join ', ')
}

Write-Host "`n=== 7. Bozuk karakter (CJK / kutuciklari) ===" -ForegroundColor Cyan
$bad = Select-String -Path $md.FullName -Pattern '[\u4e00-\u9fff\u3040-\u30ff\ufffd]' -AllMatches
Check (-not $bad) 'CJK veya bozuk karakter yok' (($bad | Select-Object -First 3 | ForEach-Object { "$($_.Filename):$($_.LineNumber)" }) -join ', ')

Write-Host "`n=== 8. Tasarim kurallari ===" -ForegroundColor Cyan
# ⛔ Dosya yoksa bos metin kullanilir: asagidaki .Contains() kontrolleri kendiliginden
#    KALDI verir. Bos string atanmasaydi Get-Content betigi oldururdu.
$skillPath = "$prd\SKILL.md"
$skill = if (Test-Path $skillPath) { Get-Content $skillPath -Raw -Encoding UTF8 } else { '' }
Check ([bool]$skill) 'prd SKILL.md okundu' 'dosya yok - sonraki icerik kontrolleri bos metin uzerinde calisti'
Check ($skill.Contains('Gate 0.6')) 'Gate 0.6 (yurutme modeli) SKILL.md icinde'
Check ($skill.Contains('Gate 0.2')) 'Gate 0.2 (brownfield on kesfi) SKILL.md icinde'
Check ($skill.Contains('kvkk-publish-review')) 'Uyumluluk kapisi ayri skille yonlendiriliyor'
Check ($skill.Contains('Channel C')) 'Etkilesimsiz ortam kanali tanimli'
Check ($skill.Contains('Gate B') -and $skill.Contains('Gate D')) 'Iki ayri kalite kapisi var (B: brief, D: belge)'
Check ($skill.Contains('Skip deliberately')) 'Cevaplanmayan soru protokolu tanimli (2.1)'
Check ($skill.Contains('Deferred Gate Rule')) 'Ertelenen kapi kurali tanimli'
Check (-not $skill.Contains('[owner will decide]')) 'SKILL.md icinde placeholder yok'
Check (Test-Path "$prd\scripts\validate-prd.ps1") 'PRD dogrulama betigi mevcut'
$tplPath = "$prd\templates\prd-template.md"
$prdTpl = if (Test-Path $tplPath) { Get-Content $tplPath -Raw -Encoding UTF8 } else { '' }
Check ([bool]$prdTpl) 'prd-template.md okundu' 'dosya yok'
Check (-not $prdTpl.Contains('VARIANT 1')) 'PRD sablonunda 4 metodoloji varyanti birlikte degil'
Check ($prdTpl.Contains('60%')) 'PRD sablonunda kapsam baraji kurali var'
Check ($prdTpl.Contains('Agent Execution Model')) 'PRD sablonunda Agent Execution Model bolumu var'
Check ($prdTpl.Contains('[VERIFY]') -or $prdTpl.Contains('Owner')) 'PRD sablonunda etiket sahipligi kurali var'
$hoPath = "$prd\templates\handoff-template.md"
$hoRaw = if (Test-Path $hoPath) { Get-Content $hoPath -Raw -Encoding UTF8 } else { '' }
$handoff = $hoRaw.ToLowerInvariant()
Check ([bool]$hoRaw) 'handoff-template.md okundu' 'dosya yok'
Check ($handoff.Contains('does not exist') -and $handoff.Contains('is stale') -and
       $handoff.Contains('still a template')) `
    'HANDOFF sablonunda yok/bos/dolu/bayat durumlari var'
Check ($handoff.Contains('no verified trap occurred in this session')) 'HANDOFF sablonunda sahte tuzak yazma kurali var'
Check ($handoff.Contains('fixture')) 'HANDOFF sablonunda fixture/baska ise ait dosya kurali var (N10)'

Write-Host "`n=== 9. SKILL.md 4 teslimat metodolojisine yonlendiriyor mu ===" -ForegroundColor Cyan
foreach ($m in @('delivery-mvp', 'delivery-agile', 'delivery-kanban', 'delivery-waterfall')) {
    Check ($skill.Contains($m)) $m
    Check (Test-Path "$prd\references\$m.md") "$m.md mevcut"
}

Write-Host "`n=== 10. Kapilara gore gecmis hata dersleri kayitli mi ===" -ForegroundColor Cyan
$errPath = "$prd\references\common-mistakes.md"
$errs = if (Test-Path $errPath) { Get-Content $errPath -Raw -Encoding UTF8 } else { '' }
Check ([bool]$errs) 'common-mistakes.md okundu' 'dosya yok'
foreach ($e in @('methodology was locked before the code scan',
        'The score was given for what was going to be written',
        'Effort was fabricated', 'A deferred gate was left unowned',
        'A placeholder was left behind')) {
    Check ($errs.Contains($e)) "ders kayitli: $e"
}

Write-Host "`n=== 11. Eval dosyalari (skill basina en az 3 pozitif + 2 negatif + 1 davranissal) ===" -ForegroundColor Cyan
foreach ($s in @($prd, $kvkk)) {
    $n = Split-Path $s -Leaf
    $f = Join-Path $s 'evals\evals.json'
    if (-not (Test-Path $f)) { Check $false "$n : evals/evals.json mevcut" 'skill icin eval case yok'; continue }
    Check $true "$n : evals/evals.json mevcut"
    try {
        $j = Get-Content $f -Raw -Encoding UTF8 | ConvertFrom-Json
        $all = @($j | ForEach-Object { $_.evals })
        $pos = @($all | Where-Object { $_.type -eq 'positive' })
        $neg = @($all | Where-Object { $_.type -eq 'negative' })
        $beh = @($all | Where-Object { $_.type -eq 'behavioral' })
        Check ($pos.Count -ge 3) "$n : pozitif tetikleyici >= 3" "bulunan: $($pos.Count)"
        Check ($neg.Count -ge 2) "$n : negatif tetikleyici >= 2" "bulunan: $($neg.Count)"
        Check ($beh.Count -ge 1) "$n : davranissal degerlendirme >= 1" "bulunan: $($beh.Count)"
        $noExpect = @($all | Where-Object { -not $_.expected_behavior -or $_.expected_behavior.Count -eq 0 })
        Check ($noExpect.Count -eq 0) "$n : her eval case icin expected_behavior dolu" `
            (($noExpect | ForEach-Object { $_.id }) -join ', ')
        $dup = @($all | Group-Object id | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
        Check ($dup.Count -eq 0) "$n : eval id benzersiz" ($dup -join ', ')
    } catch {
        Check $false "$n : evals.json gecerli JSON" $_.Exception.Message
    }
}

Write-Host "`n=== 12. SKILL seti fixture'a bagli mi (global ilke) ===" -ForegroundColor Cyan
# Desenler parca parca birlestirilir: betigin kendi kaynagi kendini yakalamasin.
# ⛔ Liste genistirildi (4 -> 9): amac "kaba" desen degil, yalniz proje adinin hic
#    bicimde sizmamis olmak. Cift degiskende (link-checker-prd, com\.orca) gecer.
$pats = @('test' + 'Project', 'com\.orca', 'link-checker', 'task-notification',
    'task-notification-prd', 'link-checker-prd', 'com/orca', 'TaskService',
    'JpaRepository')
$scan = Get-ChildItem -Recurse $root -File -Include *.md, *.ps1 |
    Where-Object { $_.FullName -ne $MyInvocation.MyCommand.Path }
$leak = Select-String -Path $scan.FullName -Pattern $pats -AllMatches
Check (-not $leak) 'skill a hicbir test fixture adi sizmamis' `
    ((($leak | Select-Object -First 3) | ForEach-Object { "$($_.Filename):$($_.LineNumber)" }) -join ', ')

# ⛔ GLOBALITE: skill seti TEK bir yigina baglanabilir. On kesif dosyasi birden
#    cok yigini taniyor olmali; tek yigin varsa skill baska projede calismaz.
$ksPath = Join-Path $root 'prd-craft\references\codebase-scan.md'
if (Test-Path $ksPath) {
    $ks = (Get-Content $ksPath -Raw -Encoding UTF8).ToLowerInvariant()
    $stacks = @{
        'java' = 'pom.xml'; 'node' = 'package.json'; 'python' = 'pyproject.toml'
        'go' = 'go.mod'; 'rust' = 'cargo.toml'; 'dotnet' = '.csproj'
        'flutter/mobil' = 'pubspec.yaml'; 'php' = 'composer.json'
    }
    $found = @($stacks.Keys | Where-Object { $ks.Contains($stacks[$_]) })
    Check ($found.Count -ge 5) `
        "skill seti cok yigini taniyor ($($found.Count)/8: $($found -join ', '))" `
        'tek yigina baglanmis bir skill baska projede calismaz'
} else {
    Check $false 'codebase-scan.md mevcut' 'yigin tespit tablosu okunamadi'
}

Write-Host "`n=== 12b. Yonlendirme kurallari erisilebilir mi (F3) ===" -ForegroundColor Cyan
# ⛔ Canli olcum: skill, ajanin girip girmeme kararini YONETEMEZ. Karar SKILL.md
#    govdesinde verilirse o govde hic okunmaz. 3 bagimsiz kosumda 3/3 basarisiz oldu.
#    Bu lint, yonlendirme/kapsam disi kuralinin YALNIZCA govdede yazilmasini engeller.
$routing = Join-Path $root 'ROUTING.md'
Check (Test-Path $routing) 'ROUTING.md mevcut (kararin verildigi tek nokta)'
if (Test-Path $routing) {
    $rt = [IO.File]::ReadAllText($routing)
    $rtL = $rt.ToLowerInvariant()
    # ROUTING.md'de beyan bir kod blogunda yazar, backtick icermez.
    Check ($rtL.Contains('skill: <')) 'ROUTING.md beyan formatini tanimliyor'
    # ⛔ Eslesen satir yoksa 'yok' uretilmemeli — canli olcumde ajani skill disina
    #    itip kuralini uydurmasina yol acti (behavior-cli-type-ssrf).
    # ⛔ Tuzak 20: zayif desen sahte kontrol uretir. 'audit' ve 'rationale'
    #    ROUTING.md'de 8 ayri yerde gecigi icin TEK KELIME bakmak her zaman
    #    gecer verir. Bu satirlar mutasyonla sinandi: tek kelimeyi silmek KALDI
    #    vermiyordu. Asagida tam SATIR metni aranir.
    Check ($rtL.Contains('undecided')) `
        'ROUTING.md eslesmeyen istek icin kararsiz secenegi sunuyor'
    Check ($rtL.Contains('kv-01..kv-06')) `
        'ROUTING.md mevcut arac davranis denetimini kapsiyor'
    Check ($rtL.Contains('rationale: <one sentence>')) `
        'ROUTING.md beyan icin gerekce alani istiyor'
    Check ($rtL.Contains('prd-craft') -and $rtL.Contains('kvkk-publish-review')) `
        'ROUTING.md her iki skilli de yonlendirme tablosunda sayiyor'
}

Write-Host "`n=== 12c. KVKK yargi bolgesi uyarisi acik mi ===" -ForegroundColor Cyan
# ⛔ Skill Turk hukukuna (KVKK 6698) bagli. Global bir repoda yayimlanirken
#    yargi disi projeler bu skill'i mekanigi icin kullanir; bu yuzden uyari
#    hem description'da hem govdede bulunmalidir. Uyarinin kalkmasi, skill'i
#    yalniz Turkler icin oldugu izlenimi verir.
$kDesc = if (Test-Path "$kvkk\SKILL.md") { (Get-Content "$kvkk\SKILL.md" -Encoding UTF8 | Select-String -Pattern '^description:' | Select-Object -First 1) } else { $null }
Check ([bool]$kDesc -and $kDesc.Line.ToLowerInvariant().Contains('jurisdiction warning')) `
    'kvkk-publish-review : description yargi bolgesi uyarisi tasiyor'
$kBody = if (Test-Path "$kvkk\SKILL.md") { (Get-Content "$kvkk\SKILL.md" -Raw -Encoding UTF8) } else { '' }
Check ($kBody.Contains('JURISDICTION')) `
    'kvkk-publish-review : govdede yargi bolgesi uyarisi var'

# ⛔ Turetilmis durumun tek kaynagi: SKILL.md "7-type matrix" diyor, matriste
#    gercekten 7 satir olmali. Once 6 diyordu ve matriste 7 satir vardi.
$mxPath = Join-Path $root 'kvkk-publish-review\references\kvkk-compliance-audit.md'
if (Test-Path $mxPath) {
    $mx = Get-Content $mxPath -Encoding UTF8
    $hdr = ($mx | Select-String -Pattern '^\|\s*Application type\s*\|' | Select-Object -First 1)
    $rows = 0
    if ($hdr) {
        # LineNumber 1-based, dizi 0-based -> basligin gercek indeksi
        $start = $hdr.LineNumber - 1
        for ($i = $start + 1; $i -lt $mx.Count; $i++) {
            if ($mx[$i] -notmatch '^\|') { break }               # tablo bitti
            if ($mx[$i] -match '^\|\s*-{2,}') { continue }       # ayirici satir
            $rows++
        }
    }
    # ⛔ Tuzak: yalniz SATIR SAYISI degil, SKILL.md'nin SAYISINI da dogrula.
    #    Satir sayisi 7 oldugu icin "7-type" yazmak tutarli gorunur; ama
    #    SKILL.md "6-type" derken matris 7 satirliktir ve bu bir YANLIS
    #    ifadedir. Kalan bosluk ("6-type" veya "8-type") de KALDI vermelidir.
    $declared = if ($kBody -match '(\d+)-type matrix') { [int]$Matches[1] } else { -1 }
    Check ($declared -eq $rows) `
        "kvkk tip matrisi: SKILL.md $declared-type diyor, matriste $rows satir var" `
        "SKILL.md ile matrisin satir sayisi ayni olmali (SKILL.md: $declared, matris: $rows)"
    Check ($rows -eq 7) "kvkk uygulama tipi matrisinde 7 satir var ($rows)" `
        "beklenen 7 satir, gercek $rows"
}

# Her SKILL.md: (a) beyan kuralini tasiyor, (b) yonlenderme kararini govdeye devretmiyor
foreach ($sp in @("$prd\SKILL.md", "$kvkk\SKILL.md")) {
    $d = Split-Path (Split-Path $sp -Parent) -Leaf
    if (-not (Test-Path $sp)) { Check $false "$d : SKILL.md mevcut" 'dosya yok'; continue }
    $spL = (Get-Content $sp -Raw -Encoding UTF8).ToLowerInvariant()
    # ⛔ 'skill:' tek basina yanilticidir: Turkce "Ayrı skill:" ifadesi de onu saglar.
    #    Desen, beyan FORMATINI gosterir: backtick + acilis parantezi.
    Check ($spL.Contains('`skill: <')) "$d : karar beyani zorunlu ve formati yazili"
    Check ($spL.Contains('routing.md')) "$d : beyan tablosuna yonlendiriyor"
    # Yonlendirme karari govdede degil, ROUTING.md'de verilir
    Check ($spL.Contains('decision declaration') -or $spL.Contains('decision declaration')) `
        "$d : kararin govde icinde degil ROUTING.md'de verildigi yazili"
}

Write-Host "`n=== 13. Eval kosucusu calisiyor mu (L0) ===" -ForegroundColor Cyan
$runner = Join-Path $root 'evals\run-evals.mjs'
if (-not (Test-Path $runner)) {
    Check $false 'evals/run-evals.mjs mevcut' 'kosucu yok - eval tanimlari hicbir zaman dogrulanmaz'
} elseif (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Check $false 'node bulundu (kosucu icin)' 'Node.js kurulu degil'
} else {
# Kosucu ASCII bir ozet satiri basar; Turkce metin encoding'e gore bozulabilir.
    $out = & node $runner --selftest 2>&1 | Out-String
    if ($out -match 'L0_SUMMARY passed=(\d+) failed=(\d+)') {
        $p = [int]$Matches[1]; $f2 = [int]$Matches[2]
        Check ($f2 -eq 0) "eval kosucusu L0 sifir hata ($($p + $f2) kontrol)" `
            (($out -split "`n" | Select-String 'KALDI' | Select-Object -First 3) -join ' | ')
    } else {
        Check $false 'eval kosucusu L0 ozet satiri uretti' 'L0_SUMMARY parse edilemedi'
    }
    Check ($out -match 'not verified') 'kosucu "skill kanitlanmadi" uyarisini basiyor' `
        'kosucu L0 sonrasi da L1 yapilmadigini soylemiyorsa kanit izlenimi yaratir'
}

Write-Host "`n" + ("=" * 46)
Write-Host "  GECTI: $pass    KALDI: $fail" -ForegroundColor $(if ($fail) { 'Red' } else { 'Green' })
Write-Host ("=" * 46)
exit $(if ($fail) { 1 } else { 0 })
