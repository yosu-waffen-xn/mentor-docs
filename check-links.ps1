#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Sprawdza aktywność linków w plikach markdown wiki.

.DESCRIPTION
    Parsuje markdown linki [text](path) i weryfikuje czy wskazywane pliki/foldery istnieją.
    Generuje raport brakujących oraz nieaktywnych zasobów.

.EXAMPLE
    ./check-links.ps1
    
.PARAMETER ReportFile
    Ścieżka do pliku raport (domyślnie: check-links-report.txt)
#>

param(
    [string]$ReportFile = "check-links-report.txt",
    [string[]]$FilesToCheck = @("README.md", "wiki/README.md", "wiki/artykuly/INDEX.md")
)

$BaseDir = (Get-Location)
$MissingLinks = @()
$BrokenLinks = @()
$ValidLinks = @()

Write-Host "Sprawdzam linki wiki..." -ForegroundColor Cyan
Write-Host "Katalog bazowy: $BaseDir`n" -ForegroundColor Gray

foreach ($file in $FilesToCheck) {
    $FilePath = Join-Path $BaseDir $file
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "[!] Plik nie istnieje: $file" -ForegroundColor Yellow
        $MissingLinks += $file
        continue
    }
    
    Write-Host "[*] Parsowanie: $file" -ForegroundColor Green
    
    $Content = Get-Content $FilePath -Raw
    
    # Regex dla link markdown: [text](path)
    $LinkPattern = '\[([^\]]+)\]\(([^)]+)\)'
    $Matches = [System.Text.RegularExpressions.Regex]::Matches($Content, $LinkPattern)
    
    foreach ($Match in $Matches) {
        $Text = $Match.Groups[1].Value
        $Path = $Match.Groups[2].Value
        
        # Pomiń linki zewnętrzne (http, https, mailto)
        if ($Path -match '^(https?://|mailto:|#)') {
            continue
        }
        
        # Normalizuj ścieżkę względem lokalizacji pliku
        if ($Path -match '^/?wiki/') {
            # Ścieżka względem repo root
            $FullPath = Join-Path $BaseDir $Path
        } else {
            # Ścieżka względem obecnego pliku
            $Dir = Split-Path $FilePath
            $FullPath = Join-Path $Dir $Path
        }
        
        # Usuń anchor (#section)
        $FullPath = $FullPath -replace '#.*$'
        
        # Sprawdź czy istnieje
        if (Test-Path $FullPath) {
            $ValidLinks += @{
                File = $file
                Text = $Text
                Path = $Path
                Exists = $true
            }
            Write-Host "  [OK] $Text -> $Path" -ForegroundColor Green
        } else {
            $BrokenLinks += @{
                File = $file
                Text = $Text
                Path = $Path
                FullPath = $FullPath
            }
            Write-Host "  [XX] $Text -> $Path (NOT FOUND)" -ForegroundColor Red
        }
    }
}

# Generuj raport
$Report = @"
=========================================================
RAPORT WERYFIKACJI LINKOW WIKI
Wygenerowano: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
=========================================================

PODSUMOWANIE
-----------
[OK] Aktywne linki:    $($ValidLinks.Count)
[XX] Brakujace linki:  $($BrokenLinks.Count)
[!] Brakujace pliki:   $($MissingLinks.Count)

"@

if ($BrokenLinks.Count -gt 0) {
    $Report += "`n[!] BRAKUJACE ZASOBY (do naprawy):`n"
    $Report += "-" * 65 + "`n"
    
    foreach ($Link in $BrokenLinks) {
        $Report += "`n📄 Źródło: $($Link.File)`n"
        $Report += "   Tekst: $($Link.Text)`n"
        $Report += "   Ścieżka: $($Link.Path)`n"
        $Report += "   Pełna: $($Link.FullPath)`n"
    }
}

if ($MissingLinks.Count -gt 0) {
    $Report += "`n[!] PLIKI GLOWNE NIEZNALEZIONE:`n"
    $Report += "-" * 65 + "`n"
    foreach ($MissingFile in $MissingLinks) {
        $Report += "   - $MissingFile`n"
    }
}

if ($ValidLinks.Count -gt 0) {
    $Report += "`n[OK] AKTYWNE LINKI (probka):`n"
    $Report += "-" * 65 + "`n"
    
    $Sample = $ValidLinks | Select-Object -First 10
    foreach ($Link in $Sample) {
        $Report += "   [$($Link.Text)] → $($Link.Path)`n"
    }
    
    if ($ValidLinks.Count -gt 10) {
        $Report += "`n   ... i $($ValidLinks.Count - 10) więcej`n"
    }
}

$Report += "`n" + "=" * 65

# Zapisz raport
$Report | Out-File -FilePath $ReportFile -Encoding UTF8
Write-Host "`n[*] Raport zapisany: $ReportFile" -ForegroundColor Cyan

# Pokaż podsumowanie
$ReportLines = $Report -split "`n"
for ($i = 0; $i -lt [Math]::Min(15, $ReportLines.Count); $i++) {
    Write-Host $ReportLines[$i] -ForegroundColor White
}
