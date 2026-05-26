#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generuje README.md dla kategorii artykułów w wiki

.DESCRIPTION
    Skanuje foldery artykułów i tworzy README.md 
    zawierający opis i listę artykułów w każdej kategorii
#>

$Categories = @{
    'profil' = @{
        Title = "Profil i Biografia"
        Description = "Biografia streamera, wizerunek publiczny, modele biznesowe, samoopisy i kariera Aleksandra Radomskiego (Szachowego Mentora)"
    }
    'figle' = @{
        Title = "Figle, Akcje i Kontrowersje"
        Description = "Akcje społeczne, memy, kontrowersje, techniczne i osobowe spory, archiwa transmisji, kąciki tematyczne"
    }
    'zwiazki' = @{
        Title = "Relacje Interpersonalne"
        Description = "Relacje z innymi osobami, konflikty z moderacją i społecznością, dyskusje i wywiady"
    }
    'inwestycje' = @{
        Title = "Finanse i Inwestycje"
        Description = "Finanse, handlowe przedsięwzięcia, priorytety wydatkowe, plany rozwojowe, analiza portfela"
    }
    'odzywianie' = @{
        Title = "Lifestyle i Kąciki"
        Description = "Kąciki lifestyle'owe, sprawa AGD, beauty, zakupy, jedzenie i inne tematy nasze codzienne"
    }
}

$BaseDir = "$PSScriptRoot\wiki\artykuly"

Write-Host "Generuję README.md dla kategorii..." -ForegroundColor Cyan

foreach ($Category in $Categories.GetEnumerator()) {
    $CategoryName = $Category.Key
    $CategoryPath = Join-Path $BaseDir $CategoryName
    $ReadmePath = Join-Path $CategoryPath "README.md"
    
    if (-not (Test-Path $CategoryPath)) {
        Write-Host "[!] Katalog nie istnieje: $CategoryName" -ForegroundColor Yellow
        continue
    }
    
    # Pobierz listę artykułów w folderze
    $Files = Get-ChildItem -Path $CategoryPath -Filter "*.md" | 
             Where-Object { $_.Name -ne "README.md" } |
             Sort-Object Name -Descending
    
    if ($Files.Count -eq 0) {
        Write-Host "[!] Brak artykułów w: $CategoryName" -ForegroundColor Yellow
        continue
    }
    
    # Buduj zawartość README
    $ReadmeContent = @"
# $($Category.Value.Title)

$($Category.Value.Description)

## Artykuły $($Files.Count)

"@
    
    # Dodaj linki do artykułów
    foreach ($File in $Files) {
        $Filename = $File.Name
        $DisplayName = $Filename -replace '\.md$' -replace '^[0-9]{4}-[0-9]{2}-' -replace '^[0-9]{4}-[0-9]{2}-[0-9]{2}-'
        $ReadmeContent += "- [$DisplayName]($Filename)`n"
    }
    
    $ReadmeContent += "`n" + @"
---

[← Wróc do artykułów](../INDEX.md) | [← Główna wiki](../README.md)
"@
    
    # Zapisz README
    $ReadmeContent | Out-File -FilePath $ReadmePath -Encoding UTF8
    Write-Host "[OK] Utworzono: $CategoryName/README.md ($($Files.Count) artykułów)" -ForegroundColor Green
}

Write-Host "`n[*] Gotowe! Wszystkie kategorie mają teraz README.md" -ForegroundColor Cyan
