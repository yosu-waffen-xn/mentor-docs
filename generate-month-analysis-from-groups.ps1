#!/usr/bin/env pwsh

param(
	[Parameter(Mandatory = $false)]
	[string]$Month = "2026-04",

	[Parameter(Mandatory = $false)]
	[string]$BatchesRoot = "wiki/assets/tmp/batches"
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

function Topic-Meta {
	return @{
		"inwestycje" = @{
			Category = "inwestycje"
			Slug = "$Month-przeglad-dyskusji-inwestycyjnych"
			Title = "$Month - przeglad dyskusji inwestycyjnych"
			Intro = "Kwiecien pokazuje bardzo intensywny rytm komentarzy inwestycyjnych: szybkie decyzje, porownywanie scenariuszy i nacisk na wynik." 
			AnalysisPoints = @(
				"Dominuje podejscie reaktywne: wiele wypowiedzi jest osadzonych w ruchu ceny tu i teraz.",
				"Wiedza wskaznikowa (ROI, ROE, C/Z) pojawia sie regularnie, ale czesto wspiera decyzje podjete szybciej niz klasyczna analiza fundamentalna.",
				"Widac silna warstwe psychologii ryzyka: frustracje, FOMO i porownywanie alternatyw po fakcie."
			)
			Conclusion = @(
				"Temat inwestycji jest jednym z glownych filarow dyskusji w miesiacu.",
				"Kompetencje analityczne sa widoczne, ale dyscyplina procesu bywa nierowna.",
				"Warto monitorowac rozdzielenie: plan strategiczny vs decyzje impulsywne."
			)
			Source = "wiki/assets/tmp/batches/$Month/groups/inwestycje.json"
		}
		"figle" = @{
			Category = "figle"
			Slug = "$Month-streaming-ranking-i-bany"
			Title = "$Month - streaming, ranking i bany"
			Intro = "W kwietniu dominowal material zwiazany ze streamingiem, szachami i moderacja. To glowny strumien aktywnosci calego miesiaca."
			AnalysisPoints = @(
				"Najsilniejszy segment to komunikacja okoostreamowa: zapowiedzi, podsumowania i reakcje na widownie.",
				"Druga warstwa to szachy i ranking: regularne raportowanie wynikow i komentarz turniejowy.",
				"Trzecia warstwa to moderacja i bany, co wskazuje na stale zarzadzanie konfliktem spolecznosciowym."
			)
			Conclusion = @(
				"Streaming i szachy napedzaja wiekszosc aktywnosci miesiecznej.",
				"Narracja ma charakter ciagly: codzienny, operacyjny i silnie personalny.",
				"Koszt uboczny to wysoka konfliktowosc i presja moderacyjna."
			)
			Source = "wiki/assets/tmp/batches/$Month/groups/figle.json"
		}
		"zwiazki" = @{
			Category = "zwiazki"
			Slug = "$Month-relacje-i-konflikty-na-czacie"
			Title = "$Month - relacje i konflikty na czacie"
			Intro = "Watek relacyjny w kwietniu jest mniejszy wolumenowo, ale zawiera gesta retoryke oceniania kobiet i relacji damsko-meskich."
			AnalysisPoints = @(
				"Wypowiedzi czesto operuja uogolnieniami i spolaryzowanym jezykiem wobec kobiet.",
				"Pojawiaja sie deklaracje norm i zasad relacyjnych, ale z duza domieszka emocjonalnej reaktywnosci.",
				"Nawet przy mniejszej liczbie wpisow to obszar o podwyzszonym ryzyku eskalacji konfliktow."
			)
			Conclusion = @(
				"Temat relacji nie jest ilosciowo dominujacy, ale jest jakosciowo wyrazisty.",
				"Widoczne sa elementy myslenia zyczeniowego i generalizacji.",
				"Wartosc analityczna rosnie, gdy oddziela sie fakty od deklaracji tozsamosciowych."
			)
			Source = "wiki/assets/tmp/batches/$Month/groups/zwiazki.json"
		}
		"profil" = @{
			Category = "profil"
			Slug = "$Month-autoprezentacja-i-deklaracje"
			Title = "$Month - autoprezentacja i deklaracje"
			Intro = "Kwiecien przynosi duzo komunikatow o sobie: cele, samoopis, granice interpersonalne i biezace deklaracje stylu zycia."
			AnalysisPoints = @(
				"Dominuje autoprezentacja: mocne komunikaty tozsamosciowe i pozycjonowanie wobec grupy.",
				"Mniej liczne sa wpisy o planach i celach, ale spina je motyw kontroli i sprawczosci.",
				"W warstwie codziennej widac presje czasu i ograniczen organizacyjnych."
			)
			Conclusion = @(
				"Profil komunikacyjny jest wyrazisty i stale wzmacniany.",
				"Wypowiedzi buduja obraz sprawczosci, ale nie zawsze sa domkniete planem wykonawczym.",
				"Dla dalszej analizy kluczowe jest sledzenie spojnosci deklaracji z praktyka."
			)
			Source = "wiki/assets/tmp/batches/$Month/groups/profil.json"
		}
		"odzywianie" = @{
			Category = "odzywianie"
			Slug = "$Month-kacik-zakupowy-i-nawyki"
			Title = "$Month - kacik zakupowy i nawyki"
			Intro = "Watek odzywiania i zakupow jest niszowy wolumenowo, ale regularnie wraca jako praktyczny komentarz do codziennosci."
			AnalysisPoints = @(
				"Najwiecej wpisow dotyczy zakupow i porownywania cen.",
				"Pojawiaja sie wzmianki o napojach i jedzeniu, zwykle w kontekscie szybkich decyzji konsumenckich.",
				"To temat pomocniczy wobec glownych osi miesiaca, ale uzyteczny do mapowania nawykow."
			)
			Conclusion = @(
				"Niska skala, ale stabilna obecna sygnalow zakupowych.",
				"Przewaza tryb praktyczny: co kupic, gdzie taniej, co jest dostepne.",
				"W kolejnych batchach warto sprawdzac sezonowosc i powtarzalne wzorce zakupowe."
			)
			Source = "wiki/assets/tmp/batches/$Month/groups/odzywianie.json"
		}
	}
}

function Get-SharePercent {
	param(
		[int]$Part,
		[int]$Whole
	)

	if ($Whole -eq 0) {
		return "0.00"
	}

	return [math]::Round((100.0 * $Part / $Whole), 2).ToString("0.00")
}

$monthDir = Join-Path $BatchesRoot $Month
$summaryPath = Join-Path $monthDir "grouping-summary.json"

if (-not (Test-Path $summaryPath)) {
	throw "Brak pliku podsumowania: $summaryPath"
}

$summary = Get-Content -Path $summaryPath -Raw | ConvertFrom-Json
$meta = Topic-Meta

foreach ($topicStat in $summary.by_topic) {
	$topic = [string]$topicStat.topic
	if (-not $meta.ContainsKey($topic)) {
		continue
	}

	$m = $meta[$topic]
	$groupPath = Join-Path $monthDir ("groups/{0}.json" -f $topic)
	if (-not (Test-Path $groupPath)) {
		continue
	}

	$items = Get-Content -Path $groupPath -Raw | ConvertFrom-Json
	$total = [int]$summary.total
	$topicCount = [int]$topicStat.count
	$share = Get-SharePercent -Part $topicCount -Whole $total

	$lines = New-Object System.Collections.Generic.List[string]
	$lines.Add("# $($m.Title)")
	$lines.Add("")
	$lines.Add("## Co sie stalo")
	$lines.Add("")
	$lines.Add($m.Intro)
	$lines.Add("")
	$lines.Add("## Skala materialu")
	$lines.Add("")
	$lines.Add("- Wszystkie wiadomosci batcha ${Month}: $total")
	$lines.Add("- Wiadomosci przypisane do tematu '$topic': $topicCount")
	$lines.Add("- Udzial tematu '$topic' w calym batchu: $share%")
	$lines.Add("")
	$lines.Add("Podzial wewnatrz tematu:")
	$lines.Add("")
	foreach ($g in $topicStat.groups) {
		$lines.Add("- $($g.group): $($g.count)")
	}

	$lines.Add("")
	$lines.Add("## Szczegolowa analiza")
	$lines.Add("")
	$idx = 1
	foreach ($p in $m.AnalysisPoints) {
		$lines.Add("### $idx. $p")
		$lines.Add("")
		$idx += 1
	}

	$lines.Add("## Cytaty reprezentatywne")
	$lines.Add("")
	$lines.Add("Ponizej cytaty z grup roboczych; pisownia zostala technicznie oczyszczona z artefaktow kodowania.")
	$lines.Add("")

	foreach ($g in $topicStat.groups) {
		$groupName = [string]$g.group
		$sample = @(
			$items |
				Where-Object { $_.group -eq $groupName } |
				Sort-Object timestamp -Descending |
				Select-Object -First 3
		)

		foreach ($row in $sample) {
			$txt = Normalize-Text -Text ([string]$row.text)
			if ($txt.Length -gt 260) {
				$txt = $txt.Substring(0, 260) + "..."
			}
			$lines.Add("- [$($row.timestamp)] [$($row.channel_name)] `"$txt`"")
		}
	}

	$lines.Add("")
	$lines.Add("## Wnioski")
	$lines.Add("")
	foreach ($w in $m.Conclusion) {
		$lines.Add("- $w")
	}

	$lines.Add("")
	$lines.Add("## Ocena krytyczna")
	$lines.Add("")
	$lines.Add("### Czy widac wiedze?")
	$lines.Add("")
	$lines.Add("- Tak, w warstwie regularnosci i znajomosci kontekstu tematu.")
	$lines.Add("- Najwiekszy atut: ciaglosc wypowiedzi i duza ilosc materialu porownawczego.")
	$lines.Add("")
	$lines.Add("### Czy widac myslenie zyczeniowe?")
	$lines.Add("")
	$lines.Add("- Tak, miejscami: czesc tez ma charakter deklaratywny, bez pelnego dowodzenia.")
	$lines.Add("- Glowny sygnal ryzyka: mieszanie opisu faktow z emocjonalna ocena sytuacji.")
	$lines.Add("")
	$lines.Add("### Werdykt roboczy")
	$lines.Add("")
	$lines.Add("- Profil merytoryczny: nierowny, ale czytelny tematycznie.")
	$lines.Add("- Profil komunikacyjny: intensywny i silnie nacechowany stylem autora.")
	$lines.Add("- Rekomendacja: utrzymac ten sam schemat analizy w kolejnych miesiacach dla porownywalnosci.")

	$lines.Add("")
	$lines.Add("## Metoda")
	$lines.Add("")
	$lines.Add("- 1) Grupowanie po keywordach do plikow roboczych.")
	$lines.Add("- 2) Reczny przeglad grup i ich liczebnosci.")
	$lines.Add("- 3) Synteza opisowa + cytaty reprezentatywne.")
	$lines.Add("")
	$lines.Add("---")
	$lines.Add("")
	$lines.Add("Zrodlo robocze: $($m.Source)")

	$articlePath = Join-Path "wiki/artykuly/$($m.Category)" ("{0}.md" -f $m.Slug)
	$articleDir = Split-Path -Parent $articlePath
	if (-not (Test-Path $articleDir)) {
		New-Item -ItemType Directory -Path $articleDir -Force | Out-Null
	}

	Set-Content -Path $articlePath -Value ($lines -join "`n") -Encoding UTF8
	Write-Host "Generated: $articlePath"
}

Write-Host "Done for month: $Month"
