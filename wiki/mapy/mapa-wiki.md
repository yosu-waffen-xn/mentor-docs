# Mapa wiki - Szachowy mentor

```mermaid
flowchart TD
  ROOT[Wiki INDEX] --> AIDX[Artykuly INDEX]
  ROOT --> MAPY[Mapy]
  ROOT --> AI[AI instrukcje]

  AIDX --> PROFIL[profil/szachowy-mentor.md]

  AIDX --> FIGLE[figle]
  FIGLE --> ZAMR[2025-12-05-chlopa-zamrozilo.md]
  FIGLE --> WYD[2025-12-wydarzenia.md]
  FIGLE --> CZYT[2025-12-27-kacik-czytelniczy.md]
  FIGLE --> KAC26[2026-02-kaciki-specjalne-cosplay-dobranocka-walentynki.md]
  FIGLE --> MECZ26[2026-02-mentor-meczennik-czy-len.md]
  FIGLE --> BOTY[watki-botow-i-spamu.md]
  FIGLE --> RESTR[restreamy-i-archiwum.md]
  FIGLE --> PSEU[pseudonimy-szachowego-mentora.md]

  AIDX --> ODZ[odzywianie]
  ODZ --> AGD[2025-12-kacik-malego-agd.md]

  AIDX --> INW[inwestycje]
  INW --> FIN[cele-finansowe-i-inwestycyjne-mentora.md]

  AIDX --> ZWI[zwiazki]
  ZWI --> SPOR[2025-12-spory-z-moderacja.md]
  ZWI --> ODA26[2026-02-oda-do-koisuru-i-wywiad.md]

  AIDX --> WAF[waffenowcy]
  WAF --> YOS[yossarian.md]
  WAF --> ALS[alyson-stark.md]
  WAF --> JAD[jad.md]
  WAF --> JRZ[jr-zero.md]
  WAF --> JGPT[josugpt.md]
  WAF --> PRJ[prorok-z-jezdzieckiej.md]
  WAF --> ASZ[alk-szalwia.md]
  WAF --> POM[pomidor.md]
  WAF --> AUT[autorstwa-artykulow.md]

  PROFIL --> WYD
  PROFIL --> ZAMR
  PROFIL --> AGD
  PROFIL --> SPOR
  PROFIL --> FIN
  PROFIL --> BOTY
  PROFIL --> RESTR
  PROFIL --> PSEU
  PROFIL --> KAC26
  PROFIL --> MECZ26
  PROFIL --> ODA26
  PROFIL --> WAF

  ZAMR --> WYD
  WYD --> CZYT
  WYD --> SPOR
  BOTY --> WYD
  PSEU --> SPOR
  KAC26 --> ODA26
  MECZ26 --> FIN
  YOS --> ZAMR
  ALS --> CZYT
  JAD --> AGD
  JRZ --> SPOR
  JGPT --> KAC26
  PRJ --> MECZ26
  ASZ --> MECZ26
  POM --> ODA26
  AUT --> WAF
```
