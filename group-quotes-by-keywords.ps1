#!/usr/bin/env pwsh

param(
    [Parameter(Mandatory = $false)]
    [string]$Month = "2026-05",

    [Parameter(Mandatory = $false)]
    [string]$QuotesPath = "wiki/assets/tmp/quotes_cache.json",

    [Parameter(Mandatory = $false)]
    [string]$OutputRoot = "wiki/assets/tmp/batches"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Win1252 = [System.Text.Encoding]::GetEncoding(1252)
$Utf8 = [System.Text.Encoding]::UTF8

function Get-MojibakeScore {
    param([string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return 0
    }

    $markers = @(
        [string][char]0x00C3,
        [string][char]0x00C2,
        [string][char]0x00C4,
        [string][char]0x00C5,
        [string][char]0x00E2,
        [string][char]0x0111
    )

    $score = 0
    foreach ($m in $markers) {
        if ($Text.Contains($m)) {
            $score += 1
        }
    }

    return $score
}

function Repair-Mojibake {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    $before = Get-MojibakeScore -Text $Text
    if ($before -eq 0) {
        return $Text
    }

    try {
        $bytes = $Win1252.GetBytes($Text)
        $candidate = $Utf8.GetString($bytes)
        $after = Get-MojibakeScore -Text $candidate
        if ($after -lt $before) {
            return $candidate
        }
    }
    catch {
        return $Text
    }

    return $Text
}

function Normalize-Text {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    $decoded = Repair-Mojibake -Text $Text
    $line = $decoded -replace "\r", " " -replace "\n", " "
    $line = $line -replace "\s+", " "
    return $line.Trim()
}

function Get-TopicDefinitions {
    return @{
        "inwestycje" = @{
            Keywords = @("inwest", "akcj", "spolka", "gield", "portfel", "roi", "ebitda", "piotros", "trading", "wasko", "lubawa", "srebro", "krypto", "zysk", "strat")
            Groups = @(
                @{ Name = "deklaracje_inwestycyjne"; Keywords = @("inwest", "portfel", "spolka", "gield", "trading") },
                @{ Name = "wyniki_i_metryki"; Keywords = @("roi", "ebitda", "zysk", "strat", "f-score", "piotros") },
                @{ Name = "podejscie_do_ryzyka"; Keywords = @("hazard", "spadaj", "ryzyk", "cebul", "sprzed", "kup") }
            )
        }
        "figle" = @{
            Keywords = @("stream", "live", "kick", "youtube", "lichess", "szach", "ranking", "ban", "discord", "mod", "moder", "haxball", "among", "parti", "debiut", "mat", "arcymistrz", "lobby", "cheater", "grunfeld", "smok")
            Groups = @(
                @{ Name = "streaming_i_platformy"; Keywords = @("stream", "live", "kick", "youtube", "haxball") },
                @{ Name = "szachy_i_ranking"; Keywords = @("lichess", "szach", "ranking", "parti", "debiut", "mat", "arcymistrz") },
                @{ Name = "bany_i_moderacja"; Keywords = @("ban", "discord", "mod", "moder", "admin") }
            )
        }
        "zwiazki" = @{
            Keywords = @("koisuru", "napoleon", "gg", "gadu", "dziewcz", "kobiet", "zwiazk", "romans", "seks", "milosc", "relac")
            Groups = @(
                @{ Name = "narracje_o_relacjach"; Keywords = @("zwiazk", "romans", "milosc", "dziewcz", "kobiet") },
                @{ Name = "wypowiedzi_o_komunikatorach"; Keywords = @("gg", "gadu", "wiadom", "chat") },
                @{ Name = "konflikty_i_uszczypliwosci"; Keywords = @("incel", "atak", "drama", "konflikt") }
            )
        }
        "odzywianie" = @{
            Keywords = @("sodastream", "oran", "mandaryn", "jedz", "fryt", "dieta", "zakup", "agd", "sklep")
            Groups = @(
                @{ Name = "zakupy_i_agd"; Keywords = @("zakup", "sodastream", "agd", "sklep") },
                @{ Name = "napoje_i_jedzenie"; Keywords = @("oran", "mandaryn", "fryt", "jedz", "dieta") },
                @{ Name = "nawyki_codzienne"; Keywords = @("gotuj", "pryszn", "rano", "wiecz", "dom") }
            )
        }
        "profil" = @{
            Keywords = @("prac", "zycie", "planuj", "musze", "cel", "rodzina", "angiel", "silown", "sen", "jestem", "chce", "bede", "moj", "moja")
            Groups = @(
                @{ Name = "autoprezentacja"; Keywords = @("jestem", "moje", "ja", "zawsze") },
                @{ Name = "plany_i_cele"; Keywords = @("plan", "cel", "musze", "bede") },
                @{ Name = "codzienne_ograniczenia"; Keywords = @("praca", "sen", "czas", "zmecz") }
            )
        }
    }
}

function Get-Score {
    param(
        [string]$Text,
        [string[]]$Keywords
    )

    $score = 0
    foreach ($k in $Keywords) {
        if ($Text -match [regex]::Escape($k)) {
            $score += 1
        }
    }
    return $score
}

function Get-ChannelFallback {
    param([string]$ChannelName)

    $c = $ChannelName.ToLowerInvariant()
    if ($c -match "inwest") { return "inwestycje" }
    if ($c -match "wariatkowa") { return "figle" }
    if ($c -match "ogol" -or $c -match "og") { return "figle" }
    return $null
}

function Pick-Group {
    param(
        [string]$Text,
        [object[]]$Groups
    )

    $best = $Groups[0].Name
    $bestScore = -1

    foreach ($g in $Groups) {
        $s = Get-Score -Text $Text -Keywords $g.Keywords
        if ($s -gt $bestScore) {
            $bestScore = $s
            $best = $g.Name
        }
    }

    return $best
}

if (-not (Test-Path $QuotesPath)) {
    throw "Brak pliku: $QuotesPath"
}

$root = Get-Content -Path $QuotesPath -Raw | ConvertFrom-Json
$allQuotes = @($root.quotes)
$batchQuotes = @($allQuotes | Where-Object { $_.timestamp -like "$Month*" })
$defs = Get-TopicDefinitions

$assigned = New-Object System.Collections.Generic.List[object]
$skipped = New-Object System.Collections.Generic.List[object]

foreach ($q in $batchQuotes) {
    $text = Normalize-Text -Text ([string]$q.text)
    $channel = Normalize-Text -Text ([string]$q.channel_name)

    if ([string]::IsNullOrWhiteSpace($text)) {
        $skipped.Add([pscustomobject]@{ timestamp = $q.timestamp; channel_name = $channel; text = $text; reason = "empty" })
        continue
    }

    $bestTopic = $null
    $bestScore = 0

    foreach ($name in $defs.Keys) {
        $score = Get-Score -Text $text.ToLowerInvariant() -Keywords $defs[$name].Keywords
        if ($score -gt $bestScore) {
            $bestScore = $score
            $bestTopic = $name
        }
    }

    $mode = "keyword"
    if ($bestScore -eq 0 -or $null -eq $bestTopic) {
        $bestTopic = Get-ChannelFallback -ChannelName $channel
        if ($null -eq $bestTopic) {
            $skipped.Add([pscustomobject]@{ timestamp = $q.timestamp; channel_name = $channel; text = $text; reason = "no_match" })
            continue
        }
        $mode = "channel"
    }

    $groupName = Pick-Group -Text $text.ToLowerInvariant() -Groups $defs[$bestTopic].Groups

    $assigned.Add([pscustomobject]@{
        timestamp = $q.timestamp
        channel_name = $channel
        text = $text
        topic = $bestTopic
        group = $groupName
        assignment_mode = $mode
    })
}

$batchDir = Join-Path $OutputRoot $Month
$groupDir = Join-Path $batchDir "groups"
New-Item -ItemType Directory -Path $groupDir -Force | Out-Null

$summary = [ordered]@{
    month = $Month
    total = $batchQuotes.Count
    assigned = $assigned.Count
    skipped = $skipped.Count
    coverage_percent = if ($batchQuotes.Count -gt 0) { [math]::Round(($assigned.Count * 100.0) / $batchQuotes.Count, 2) } else { 0 }
    by_topic = @()
    assignment_modes = @($assigned | Group-Object assignment_mode | ForEach-Object { [pscustomobject]@{ mode = $_.Name; count = $_.Count } })
    skipped_reasons = @($skipped | Group-Object reason | ForEach-Object { [pscustomobject]@{ reason = $_.Name; count = $_.Count } })
}

foreach ($topicName in $defs.Keys) {
    $topicData = @($assigned | Where-Object { $_.topic -eq $topicName } | Sort-Object timestamp)
    if ($topicData.Count -eq 0) {
        continue
    }

    $topicPath = Join-Path $groupDir "$topicName.json"
    $topicData | ConvertTo-Json -Depth 6 | Set-Content -Path $topicPath -Encoding UTF8

    $byGroup = @($topicData | Group-Object group | Sort-Object Count -Descending | ForEach-Object { [pscustomobject]@{ group = $_.Name; count = $_.Count } })
    $summary.by_topic += [pscustomobject]@{
        topic = $topicName
        count = $topicData.Count
        groups = $byGroup
        file = "groups/$topicName.json"
    }
}

$summaryPath = Join-Path $batchDir "grouping-summary.json"
$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $summaryPath -Encoding UTF8

$skippedPath = Join-Path $batchDir "grouping-skipped.json"
$skipped | Select-Object -First 500 | ConvertTo-Json -Depth 5 | Set-Content -Path $skippedPath -Encoding UTF8

Write-Host "Grouped: $($assigned.Count) / $($batchQuotes.Count) (coverage $($summary.coverage_percent)%)" -ForegroundColor Green
Write-Host "Summary: $summaryPath" -ForegroundColor Green
Write-Host "Groups:  $groupDir" -ForegroundColor Green
