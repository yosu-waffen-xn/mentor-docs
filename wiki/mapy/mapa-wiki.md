# Mapa wiki - Szachowy mentor

Render interaktywny na GitHub Pages jest wymuszony skryptem na dole strony.

## 1) Struktura wiki (hierarchia)

```mermaid
mindmap
  root((Wiki))
    INDEX
      README
      Artykuly INDEX
      Mapy
      AI instrukcje
    Artykuly
      Profil
        szachowy-mentor.md
      Figle
        2026-02-kaciki-specjalne-cosplay-dobranocka-walentynki.md
        2025-12-08-13-szachy-banery-oranzzada.md
        2025-12-06-czolgi-na-ulicy-i-kolejne-figle.md
        2025-12-05-chlopa-zamrozilo.md
      Zwiazki
        2026-02-oda-do-koisuru-i-wywiad.md
        2025-12-13-czystki-rasowe-300-banitych-z-discorda.md
        2025-12-08-poradnik-jak-uniknac-banu-na-discordzie.md
        2025-12-08-merex-zbanowany-za-oblige-rodzicow.md
        2025-12-08-donosy-na-widzow-xn.md
      Odzywianie
        2026-02-kacik-beauty-platki-pod-oczy.md
        2025-12-08-promocja-oranzzada-hellena-analiza.md
      Inwestycje
        2025-12-plany-na-przyszlosc-mentora.md
        cele-finansowe-i-inwestycyjne-mentora.md
      Postacie
        postacie/INDEX.md
        postacie/waffenowcy/INDEX.md
        postacie/inne/INDEX.md
        postacie/sg/INDEX.md
        postacie/og/INDEX.md
        postacie/sw/INDEX.md
        postacie/waffenowcy/autorstwa-artykulow.md
```

## 2) Kluczowe powiazania artykulow (grudzien 2025 + konsekwencje)

```mermaid
flowchart LR
  PROF[profil/szachowy-mentor.md]
  HUB[figle/2025-12-08-13-szachy-banery-oranzzada.md]
  MASZ[figle/2025-12-08-maszynista-z-waffen-atakuje-na-lichessie.md]
  CZYS[zwiazki/2025-12-13-czystki-rasowe-300-banitych-z-discorda.md]
  MER[zwiazki/2025-12-08-merex-zbanowany-za-oblige-rodzicow.md]
  POR[zwiazki/2025-12-08-poradnik-jak-uniknac-banu-na-discordzie.md]
  DON[zwiazki/2025-12-08-donosy-na-widzow-xn.md]
  ORA[odzywianie/2025-12-08-promocja-oranzzada-hellena-analiza.md]
  ZAMR[figle/2025-12-05-chlopa-zamrozilo.md]
  CZOLG[figle/2025-12-06-czolgi-na-ulicy-i-kolejne-figle.md]
  ATOM[zwiazki/2025-12-06-atomowka-na-discordzie-i-wymog-50-wiadomosci.md]
  SPOR[zwiazki/2025-12-spory-z-moderacja.md]

  PROF --> HUB
  PROF --> ZAMR
  PROF --> SPOR

  HUB --> MASZ
  HUB --> CZYS
  HUB --> MER
  HUB --> POR
  HUB --> DON
  HUB --> ORA

  MASZ --> CZYS
  CZYS --> POR
  MER --> POR
  DON --> POR

  CZOLG --> ATOM
  ATOM --> SPOR
  ZAMR --> SPOR
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
