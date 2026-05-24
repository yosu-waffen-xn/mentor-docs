# Mapa wiki - Szachowy mentor

Render interaktywny na GitHub Pages jest wymuszony skryptem na dole strony.

```mermaid
flowchart TD
  ROOT[Wiki INDEX] --> AIDX[Artykuly INDEX]
  ROOT --> MAPY[Mapy]
  ROOT --> AI[AI instrukcje]

  AIDX --> PROFIL[profil/szachowy-mentor.md]

  AIDX --> FIGLE[figle]
  FIGLE --> ZAMR[2025-12-05-chlopa-zamrozilo.md]
  FIGLE --> CZOLG[2025-12-06-czolgi-na-ulicy-i-kolejne-figle.md]
  FIGLE --> SONG[2025-12-06-song-requesty-trollerskie-i-dwie-piosenki.md]
  FIGLE --> HAXB[2025-12-06-ban-mentora-z-wlasnego-lobby-haxball.md]
  FIGLE --> AUM[2025-12-06-koniec-among-us-na-streamach-mentora.md]
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
  ZWI --> ATOM[2025-12-06-atomowka-na-discordzie-i-wymog-50-wiadomosci.md]
  ZWI --> SPOR[2025-12-spory-z-moderacja.md]
  ZWI --> ODA26[2026-02-oda-do-koisuru-i-wywiad.md]

  AIDX --> POS[postacie]
  POS --> SG[postacie/srebrna-gwardia]
  POS --> OG[postacie/starokurwy]
  POS --> SW[postacie/sekta-wulfhuda]
  POS --> WAF[postacie/waffenowcy]
  POS --> INN[postacie/inne]
  SG --> ALEXP[aleksander-radomski.md]
  OG --> OPER[operatorkosiarki.md]
  SW --> WULF[wulfhud.md]
  WAF --> YOS[yossarian.md]
  WAF --> LEG[legwus.md]
  WAF --> TOR[tori.md]
  WAF --> FIK[fiko.md]
  WAF --> PUSZ[puszmen12.md]
  WAF --> UN4[un4given.md]
  WAF --> BOS[bosman.md]
  WAF --> BUB[buba.md]
  WAF --> ALS[alyson-stark.md]
  WAF --> HIK[hikki.md]
  WAF --> BEU[beudzik.md]
  WAF --> THREE[3rrr0r.md]
  WAF --> FLA[flaminga.md]
  WAF --> VIT[vitas.md]
  WAF --> JAD[jad.md]
  WAF --> JRZ[jr-zero.md]
  WAF --> JGPT[josugpt.md]
  WAF --> PRJ[prorok-z-jezdzieckiej.md]
  WAF --> ASZ[alk-szalwia.md]
  WAF --> POM[pomidor.md]
  WAF --> AUT[autorstwa-artykulow.md]
  INN --> SLO[slownik-postaci-spolecznosci.md]

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
  PROFIL --> POS

  ZAMR --> WYD
  CZOLG --> SONG
  CZOLG --> HAXB
  CZOLG --> AUM
  CZOLG --> ATOM
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

<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function () {
  if (typeof mermaid === "undefined") {
    return;
  }

  mermaid.initialize({
    startOnLoad: false,
    securityLevel: "loose",
    theme: "default"
  });

  const blocks = document.querySelectorAll("pre > code.language-mermaid, pre > code.mermaid");
  blocks.forEach((code, idx) => {
    const pre = code.parentElement;
    const wrapper = document.createElement("div");
    wrapper.className = "mermaid";
    wrapper.id = "mermaid-diagram-" + idx;
    wrapper.textContent = code.textContent;
    pre.replaceWith(wrapper);
  });

  mermaid.run({ querySelector: ".mermaid" });
});
</script>
