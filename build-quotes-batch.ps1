#!/usr/bin/env pwsh

param(
	[Parameter(Mandatory = $false)]
	[string]$Month = "2026-05",

	[Parameter(Mandatory = $false)]
	[string]$QuotesPath = "wiki/assets/tmp/quotes_cache.json",

	[Parameter(Mandatory = $false)]
	[int]$MinQuotesPerArticle = 15,

	[Parameter(Mandatory = $false)]
	[int]$MaxExamplesPerSection = 8
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

	$matches = [regex]::Matches($Text, "(Ã.|Â.|Ä.|Å.|Ĺ.|Ă.|â.|đ.)")
	return $matches.Count
}

function Repair-Mojibake {
	param([string]$Text)

	if ([string]::IsNullOrWhiteSpace($Text)) {
		return ""
	}

	$beforeScore = Get-MojibakeScore -Text $Text
	if ($beforeScore -eq 0) {
		return $Text
	}

	$candidate = $Text
	try {
		# Typical recovery path: UTF-8 bytes mis-decoded as Windows-1252.
		$bytes = $Win1252.GetBytes($Text)
		$candidate = $Utf8.GetString($bytes)
	}
	catch {
		return $Text
	}

	$afterScore = Get-MojibakeScore -Text $candidate
	if ($afterScore -lt $beforeScore) {
		return $candidate
	}

	return $Text
}

function Normalize-Text {
	param([string]$Text)

	if ([string]::IsNullOrWhiteSpace($Text)) {
		return ""
	}

	$decoded = Repair-Mojibake -Text $Text
	$normalized = $decoded -replace "\r", " " -replace "\n", " "
	$normalized = $normalized -replace "\s+", " "
	return $normalized.Trim()
}

function Is-LowSignal {
	param([string]$Text)

	if ([string]::IsNullOrWhiteSpace($Text)) {
		return $true
	}

	$trim = $Text.Trim()
	if ($trim.Length -lt 12) {
		return $true
	}

	# Mostly emoji/reaction/mentions/no lexical content.
	$letters = @($trim.ToCharArray() | Where-Object { [char]::IsLetter($_) }).Count
	return $letters -lt 4
}

function Get-TopicDefinitions {
	$definitions = @{
		"inwestycje" = @{
			Category = "inwestycje"
			ArticleSlug = "$Month-przeglad-dyskusji-inwestycyjnych"
			ArticleTitle = "$Month - przeglad dyskusji inwestycyjnych"
			Description = "Wnioski z cytatow o inwestycjach, akcjach i zarzadzaniu kapitalem."
			Keywords = @("inwest", "akcj", "spolka", "gield", "portfel", "roi", "ebitda", "piotros", "trading", "wasko", "lubawa", "srebro", "krypto", "zysk", "strat")
			Subsections = @(
				@{ Name = "Deklaracje inwestycyjne"; Keywords = @("inwest", "portfel", "spolka", "gield", "trading") },
				@{ Name = "Wyniki i metryki"; Keywords = @("roi", "ebitda", "zysk", "strat", "f-score", "piotros") },
				@{ Name = "Podejscie do ryzyka"; Keywords = @("hazard", "spadaj", "ryzyk", "cebul", "sprzed", "kup") }
			)
		}
		"figle" = @{
			Category = "figle"
			ArticleSlug = "$Month-streaming-ranking-i-bany"
			ArticleTitle = "$Month - streaming, ranking i bany"
			Description = "Wnioski z cytatow o streamingu, rankingach i konfliktach moderacyjnych."
			Keywords = @("stream", "live", "kick", "youtube", "lichess", "szach", "ranking", "ban", "discord", "mod", "moder", "haxball", "among", "us", "parti", "debiut", "mat", "arcymistrz", "lobby", "cheater", "grunfeld", "smok")
			Subsections = @(
				@{ Name = "Streaming i platformy"; Keywords = @("stream", "live", "kick", "youtube") },
				@{ Name = "Szachy i ranking"; Keywords = @("lichess", "szach", "ranking", "parti", "debiut", "mat", "arcymistrz", "otwar", "obron") },
				@{ Name = "Bany i moderacja"; Keywords = @("ban", "discord", "mod", "moder", "admin") }
			)
		}
		"zwiazki" = @{
			Category = "zwiazki"
			ArticleSlug = "$Month-relacje-i-konflikty-na-czacie"
			ArticleTitle = "$Month - relacje i konflikty na czacie"
			Description = "Wnioski z cytatow o relacjach interpersonalnych i konfliktach w rozmowach."
			Keywords = @("koisuru", "napoleon", "gg", "gadu", "dziewcz", "kobiet", "zwiazk", "romans", "seks", "milosc", "relac")
			Subsections = @(
				@{ Name = "Narracje o relacjach"; Keywords = @("zwiazk", "romans", "milosc", "dziewcz", "kobiet") },
				@{ Name = "Wypowiedzi o komunikatorach"; Keywords = @("gg", "gadu", "wiadom", "chat") },
				@{ Name = "Konflikty i uszczypliwosci"; Keywords = @("wyzyw", "incel", "atak", "drama", "konflikt") }
			)
		}
		"odzywianie" = @{
			Category = "odzywianie"
			ArticleSlug = "$Month-kacik-zakupowy-i-nawyki"
			ArticleTitle = "$Month - kacik zakupowy i nawyki"
			Description = "Wnioski z cytatow o zakupach, napojach i codziennych nawykach."
			Keywords = @("sodastream", "oran", "mandaryn", "jedz", "fryt", "dieta", "zakup", "agd", "sklep")
			Subsections = @(
				@{ Name = "Zakupy i AGD"; Keywords = @("zakup", "sodastream", "agd", "sklep") },
				@{ Name = "Napoje i jedzenie"; Keywords = @("oran", "mandaryn", "fryt", "jedz", "dieta") },
				@{ Name = "Nawyki dnia codziennego"; Keywords = @("gotuj", "pryszn", "rano", "wiecz", "dom") }
			)
		}
		"profil" = @{
			Category = "profil"
			ArticleSlug = "$Month-autoprezentacja-i-deklaracje"
			ArticleTitle = "$Month - autoprezentacja i deklaracje"
			Description = "Wnioski z cytatow o autoprezentacji, tozsamosci i planach osobistych."
			Keywords = @("prac", "zycie", "planuj", "musze", "cel", "rodzina", "angiel", "silown", "sen", "jestem", "chce", "bede", "moj", "moja")
			Subsections = @(
				@{ Name = "Autoprezentacja"; Keywords = @("jestem", "moje", "ja", "zawsze") },
				@{ Name = "Plany i cele"; Keywords = @("plan", "cel", "musze", "bede") },
				@{ Name = "Codzienne ograniczenia"; Keywords = @("praca", "sen", "czas", "zmecz") }
			)
		}
	}

	return $definitions
}

function Get-DefaultTopicForChannel {
	param([string]$ChannelName)

	$c = ($ChannelName | ForEach-Object { $_.ToLowerInvariant() })

	if ($c -match "inwest") { return "inwestycje" }
	if ($c -match "wariatkowa") { return "figle" }
	if ($c -match "ogol" -or $c -match "og") { return "figle" }
	return $null
}

function Get-TopicScore {
	param(
		[string]$Text,
		[string[]]$Keywords
	)

	$score = 0
	foreach ($k in $Keywords) {
		if ($Text -match [regex]::Escape($k)) {
			$score++
		}
	}
	return $score
}

function Pick-Subsection {
	param(
		[string]$Text,
		[object[]]$Subsections
	)

	$bestName = $Subsections[0].Name
	$bestScore = -1

	foreach ($sub in $Subsections) {
		$score = Get-TopicScore -Text $Text -Keywords $sub.Keywords
		if ($score -gt $bestScore) {
			$bestScore = $score
			$bestName = $sub.Name
		}
	}

	return $bestName
}

function Build-ArticleMarkdown {
	param(
		[hashtable]$TopicDef,
		[System.Collections.ArrayList]$TopicQuotes,
		[string]$Month,
		[int]$MaxExamplesPerSection,
		[hashtable]$CoverageStats
	)

	$title = $TopicDef.ArticleTitle
	$description = $TopicDef.Description
	$category = $TopicDef.Category

	$lines = New-Object System.Collections.Generic.List[string]
	$lines.Add("# $title")
	$lines.Add("")
	$lines.Add("## Co sie stalo")
	$lines.Add("")
	$lines.Add("W tym materiale zebrano cytaty z okresu $Month i pogrupowano je tematycznie na podstawie tresci wypowiedzi.")
	$lines.Add("Zakres partii obejmuje wypowiedzi przypisane automatycznie do kategorii: **$category**.")
	$lines.Add("")
	$lines.Add("## Pokrycie danych (batch)")
	$lines.Add("")
	$lines.Add("- Wszystkie wiadomosci w batchu: $($CoverageStats.total)")
	$lines.Add("- Przypisane do artykulow: $($CoverageStats.assigned)")
	$lines.Add("- Pominiete: $($CoverageStats.skipped)")
	$lines.Add("- Pokrycie: $($CoverageStats.coveragePercent)%")
	$lines.Add("")
	$lines.Add("## Przebieg")
	$lines.Add("")

	$grouped = $TopicQuotes | Group-Object subsection | Sort-Object Count -Descending
	foreach ($group in $grouped) {
		$lines.Add("### $($group.Name) ($($group.Count) wpisow)")
		$lines.Add("")

		$samples = $group.Group | Sort-Object timestamp -Descending | Select-Object -First $MaxExamplesPerSection
		foreach ($sample in $samples) {
			$snippet = $sample.text
			if ($snippet.Length -gt 280) {
				$snippet = $snippet.Substring(0, 280) + "..."
			}
			$lines.Add("- **$($sample.timestamp)** [$($sample.channel_name)]: $snippet")
		}
		$lines.Add("")
	}

	$lines.Add("## Metoda")
	$lines.Add("")
	$lines.Add("- Klasyfikacja oparta o slowa kluczowe i scoring tematyczny.")
	$lines.Add("- Kazda wiadomosc jest przypisywana do jednej kategorii z najwyzszym wynikiem.")
	$lines.Add("- Wiadomosci niskosygnaIowe lub bez dopasowania trafiaja do raportu pominiec.")
	$lines.Add("")
	$lines.Add("---")
	$lines.Add("")
	$lines.Add("Material wygenerowany automatycznie na bazie quotes_cache.json ($Month).")

	return ($lines -join "`n")
}

Write-Host "[1/5] Wczytywanie danych..." -ForegroundColor Cyan
if (-not (Test-Path $QuotesPath)) {
	throw "Brak pliku z cytatami: $QuotesPath"
}

$root = Get-Content -Path $QuotesPath -Raw | ConvertFrom-Json
$allQuotes = @($root.quotes)
$batchQuotes = @($allQuotes | Where-Object { $_.timestamp -like "$Month*" })

Write-Host "Wszystkie cytaty: $($allQuotes.Count)" -ForegroundColor DarkGray
Write-Host "Cytaty w batchu ${Month}: $($batchQuotes.Count)" -ForegroundColor Green

Write-Host "[2/5] Klasyfikacja i liczenie pominiec..." -ForegroundColor Cyan
$topicDefs = Get-TopicDefinitions
$assigned = New-Object System.Collections.Generic.List[object]
$skipped = New-Object System.Collections.Generic.List[object]

foreach ($q in $batchQuotes) {
	$rawText = [string]$q.text
	$rawChannel = [string]$q.channel_name
	$text = Normalize-Text -Text $rawText
	$channelName = Normalize-Text -Text $rawChannel

	if (Is-LowSignal -Text $text) {
		$skipped.Add([pscustomobject]@{
			timestamp = $q.timestamp
			channel_name = $channelName
			text = $text
			reason = "low_signal"
		})
		continue
	}

	$bestTopic = $null
	$bestScore = 0

	foreach ($topicName in $topicDefs.Keys) {
		$score = Get-TopicScore -Text $text.ToLowerInvariant() -Keywords $topicDefs[$topicName].Keywords
		if ($score -gt $bestScore) {
			$bestScore = $score
			$bestTopic = $topicName
		}
	}

	if ($bestScore -le 0 -or $null -eq $bestTopic) {
		$fallbackTopic = Get-DefaultTopicForChannel -ChannelName $channelName
		if ($null -ne $fallbackTopic -and $topicDefs.ContainsKey($fallbackTopic)) {
			$subsection = Pick-Subsection -Text $text.ToLowerInvariant() -Subsections $topicDefs[$fallbackTopic].Subsections
			$assigned.Add([pscustomobject]@{
				timestamp = $q.timestamp
			channel_name = $channelName
				text = $text
				topic = $fallbackTopic
				subsection = $subsection
				score = 0
				assignment_mode = "channel_fallback"
			})
			continue
		}

		$skipped.Add([pscustomobject]@{
			timestamp = $q.timestamp
			channel_name = $channelName
			text = $text
			reason = "no_topic_match"
		})
		continue
	}

	$subsection = Pick-Subsection -Text $text.ToLowerInvariant() -Subsections $topicDefs[$bestTopic].Subsections

	$assigned.Add([pscustomobject]@{
		timestamp = $q.timestamp
		channel_name = $channelName
		text = $text
		topic = $bestTopic
		subsection = $subsection
		score = $bestScore
		assignment_mode = "keyword_match"
	})
}

$total = $batchQuotes.Count
$assignedCount = $assigned.Count
$skippedCount = $skipped.Count
$coveragePercent = if ($total -gt 0) { [math]::Round(($assignedCount * 100.0) / $total, 2) } else { 0 }

$reasonCounts = $skipped | Group-Object reason | ForEach-Object {
	[pscustomobject]@{
		reason = $_.Name
		count = $_.Count
	}
}

$assignmentModeCounts = $assigned | Group-Object assignment_mode | ForEach-Object {
	[pscustomobject]@{
		mode = $_.Name
		count = $_.Count
	}
}

Write-Host "Przypisane: $assignedCount" -ForegroundColor Green
Write-Host "Pominiete: $skippedCount" -ForegroundColor Yellow
Write-Host "Pokrycie: $coveragePercent%" -ForegroundColor Cyan

Write-Host "[3/5] Zapis artykulow..." -ForegroundColor Cyan
$articlesRoot = "wiki/artykuly"
$writtenArticles = New-Object System.Collections.Generic.List[object]

foreach ($topicName in $topicDefs.Keys) {
	$def = $topicDefs[$topicName]
	$topicQuotes = @($assigned | Where-Object { $_.topic -eq $topicName })

	if ($topicQuotes.Count -lt $MinQuotesPerArticle) {
		continue
	}

	$categoryDir = Join-Path $articlesRoot $def.Category
	if (-not (Test-Path $categoryDir)) {
		New-Item -ItemType Directory -Path $categoryDir | Out-Null
	}

	$fileName = "$($def.ArticleSlug).md"
	$outPath = Join-Path $categoryDir $fileName

	$coverageStats = @{
		total = $total
		assigned = $assignedCount
		skipped = $skippedCount
		coveragePercent = $coveragePercent
	}

	$articleContent = Build-ArticleMarkdown -TopicDef $def -TopicQuotes ([System.Collections.ArrayList]$topicQuotes) -Month $Month -MaxExamplesPerSection $MaxExamplesPerSection -CoverageStats $coverageStats
	Set-Content -Path $outPath -Value $articleContent -Encoding UTF8

	$writtenArticles.Add([pscustomobject]@{
		topic = $topicName
		category = $def.Category
		file = $outPath.Replace("\\", "/")
		quotes = $topicQuotes.Count
	})

	Write-Host "[OK] $($def.Category)/$fileName ($($topicQuotes.Count) wpisow)" -ForegroundColor Green
}

Write-Host "[4/5] Zapis raportu pokrycia..." -ForegroundColor Cyan
$batchDir = "wiki/assets/tmp/batches/$Month"
if (-not (Test-Path $batchDir)) {
	New-Item -ItemType Directory -Path $batchDir -Force | Out-Null
}

$reportObj = [pscustomobject]@{
	month = $Month
	total = $total
	assigned = $assignedCount
	skipped = $skippedCount
	coverage_percent = $coveragePercent
	generated_articles = $writtenArticles
	assignment_mode_counts = $assignmentModeCounts
	skipped_reason_counts = $reasonCounts
	skipped_samples = @($skipped | Select-Object -First 40)
}

$reportJsonPath = Join-Path $batchDir "coverage-report.json"
$reportObj | ConvertTo-Json -Depth 7 | Set-Content -Path $reportJsonPath -Encoding UTF8

$reportMd = New-Object System.Collections.Generic.List[string]
$reportMd.Add("# Raport batch $Month")
$reportMd.Add("")
$reportMd.Add("- Wszystkie wiadomosci: $total")
$reportMd.Add("- Przypisane: $assignedCount")
$reportMd.Add("- Pominiete: $skippedCount")
$reportMd.Add("- Pokrycie: $coveragePercent%")
$reportMd.Add("")
$reportMd.Add("## Pominiecia wg powodow")
$reportMd.Add("")
foreach ($r in $reasonCounts | Sort-Object count -Descending) {
	$reportMd.Add("- $($r.reason): $($r.count)")
}

$reportMd.Add("")
$reportMd.Add("## Tryby przypisania")
$reportMd.Add("")
foreach ($m in ($assignmentModeCounts | Sort-Object count -Descending)) {
	$reportMd.Add("- $($m.mode): $($m.count)")
}

$reportMd.Add("")
$reportMd.Add("## Wygenerowane artykuly")
$reportMd.Add("")
foreach ($a in $writtenArticles) {
	$reportMd.Add("- $($a.file) - $($a.quotes) wpisow")
}

$reportMd.Add("")
$reportMd.Add("## Przykladowe pominiete wiadomosci")
$reportMd.Add("")
foreach ($s in ($skipped | Select-Object -First 25)) {
	$snippet = $s.text
	if ($snippet.Length -gt 180) {
		$snippet = $snippet.Substring(0, 180) + "..."
	}
	$reportMd.Add("- [$($s.reason)] $($s.timestamp) [$($s.channel_name)] $snippet")
}

$reportMdPath = Join-Path $batchDir "coverage-report.md"
Set-Content -Path $reportMdPath -Value ($reportMd -join "`n") -Encoding UTF8

Write-Host "Raport JSON: $($reportJsonPath.Replace('\\','/'))" -ForegroundColor Green
Write-Host "Raport MD:   $($reportMdPath.Replace('\\','/'))" -ForegroundColor Green

Write-Host "[5/5] Koniec" -ForegroundColor Cyan
Write-Host "Wygenerowano artykulow: $($writtenArticles.Count)" -ForegroundColor Green
