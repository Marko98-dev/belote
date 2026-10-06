# Belot Design System

_Started 2026-10-06 20:54 UTC_

---

## User

Napravi mali style guide (design system) za mobilnu online kartašku igru Belot za iPhone i Android (4 igrača, 2 tima po 2, 32 karte). Aplikacija je ISKLJUČIVO landscape (ležeći položaj), portrait se ne podržava. Referentni okviri: iPhone 852×393 i Android 800×360. Cilj: moderan, čist, minimalistički izgled. Bez skeuomorfizma: nema drvenog stola, zlata, neona, kasino ukrasa ni tekstura.

Uključi:
1. Paleta: tamna pozadina aplikacije (#0E1514), površina stola mat zeleno-tirkizna (#134E4A) s jedva primjetnim gradijentom, topli akcent za primarna dugmad (#F5B544), tekst off-white (#F4F1EA), boja tima A (#FF6B5B), boja tima B (#4DA3FF), plus boje za stanja (uspjeh, upozorenje).
2. Tipografija: jedan geometrijski sans (Plus Jakarta Sans ili Inter), 4 veličine (naslov, podnaslov, tijelo, mala oznaka), tabularne cifre za rezultat.
3. Oblik: radijus 16 px, pilule 999, meke difuzne sjene, 8 px spacing sistem.
4. Dugmad: primarna (puna akcent boja), sekundarna (obris), ghost, u stanjima default / pressed / disabled. Min. visina 48 px. Ikon-dugmad 48×48 px.
5. Avatari: ravne vektorske ilustracije lica, kružni, 6 različitih primjera (raznolike frizure i boje kože, jedan s kapom, jedan s naočalama), prsten u boji tima 3 px. Veličine: 56 px (home ekran) i 40 px (u partiji). Stanja: neaktivan, na potezu (pulsirajući prsten), offline.
6. Špil: 32 karte (7, 8, 9, 10, J, Q, K, A u znakovima pik, herc, karo, tref). Bijela karta, veliki indeks (broj + znak) u gornjem lijevom uglu da se vidi i kad su karte preklopljene u lepezi, geometrijski minimalistički J/Q/K bez detaljnih portreta, jedan veliki znak u sredini. Dimenzije: karta u ruci 60×84 px, odigrana na stolu 52×72 px, zatvorena karta (poleđina) kod protivnika 36×50 px. Prikaži poleđinu (jednostavan uzorak u akcent boji) i stanja karte: normalna, odabrana (podignuta 16 px), onemogućena (zatamnjena).
Sve prikaži na jednoj ploči kao pregled.

## Assistant

_[tool: list_files]_

_[tool: dc_write]_

_[tool: show_html]_

_[tool: ready_for_verification]_

Style guide je na jednoj ploči (`Belot Style Guide.dc.html`). Ploča još prolazi automatsku provjeru. Sadrži:

- **00 Primjena:** interaktivan ekran partije. Dodirneš herc kartu i ona se podigne, drugim dodirom (ili tipkom „Odigraj“) je odigraš. Ostale boje su zatamnjene jer se mora pratiti boja.
- **01 Paleta:** zadane boje, uz dodane tokene za površine i stanja.
- **02 Tipografija:** Plus Jakarta Sans, 4 veličine i tabularne cifre za rezultat.
- **03 Oblik, sjene, razmak:** radijus 16 i pilule, dvije meke sjene i razmaci po 8 px.
- **04 Dugmad:** primarna, sekundarna, ghost i ikon-dugmad, svako u stanju default, pressed i disabled. Stupac „Uživo“ stvarno reagira na pritisak.
- **05 Avatari:** 6 lica, veličine 56 i 40 px, stanja neaktivan, na potezu (pulsirajući prsten) i offline.
- **06 Špil:** svih 32 karte, svaka boja i u lepezi, tri veličine, stanja karte i poleđina.

Odluke koje sam donio sam, a nisu bile u briefu:
- Karte imaju radijus 8 px jer je 16 px prevelik za kartu široku 60 px.
- Upozorenje je narančasto (#FF8A3D) da se ne miješa sa žutim akcentom.
- Elementi na ekranu partije drže se 56 px od lijevog i desnog ruba (sigurna zona za notch).

U Tweaks panelu možeš prebaciti ekran partije na Android okvir (800×360), uključiti prikaz sigurne zone i četverobojni špil.

## User

Save as standalone HTML: `Belot Style Guide.dc.html`

## Assistant

_[tool: copy_files]_

_[tool: grep]_

_[tool: str_replace_edit]_

_[tool: super_inline_html]_

The `{{a.src}}` miss is a template hole filled at runtime with inline data URIs — no external file needed.

_[tool: show_html]_

_[tool: get_webview_logs]_

_[tool: present_fs_item_for_download]_

`Belot Style Guide.html` je spreman za preuzimanje: jedna datoteka od 244 KB koja radi bez interneta. Otvorio sam je i stranica se učitala bez grešaka.

## User

Dizajniraj početni ekran (home) mobilne igre Belot prema style guideu iz prethodnog koraka.

Platforma: nativna mobilna aplikacija za iPhone i Android, ISKLJUČIVO landscape. Prikaži ekran u dva okvira: iPhone 852×393 i Android 800×360 (isti dizajn, različit sistemski okvir). Fullscreen, status bar skriven. Safe area: otprilike 60 px lijevo i desno (notch/Dynamic Island može biti na bilo kojoj strani) i oko 20 px dolje (home indicator/gesture bar). Nijedan bitan element ne smije biti u tim zonama ni uz sam rub ekrana. Tap-targeti min. 48×48 px. UI igre je custom i isti na obje platforme, ne imitiraj iOS ili Material komponente.

Koncept: ekran je "živa scena stola" s menijem u desnoj koloni.
- Lijevi dio (oko 60% širine): pogled odozgo na čist, mat zeleno-tirkizni sto (elipsa) s mekom vinjetom. 4 sjedišta (gore, dolje, lijevo, desno), na svakom kružni avatar (56 px) s prstenom boje tima i nadimkom. Partneri su naspram (gore/dolje = tim A, lijevo/desno = tim B). Dolje lepeza od 8 otvorenih karata s jasnim indeksima, ostala tri igrača imaju zatvorene karte (poleđina), u sredini stola 2 odigrane karte blago zarotirane. Cijela scena je zatamnjena/zamagljena oko 35% da meni ostane čitljiv, ali se jasno vidi da je to partija.
- Gore lijevo na sceni: wordmark "Bellote" (jednostavan tekstualni logo).
- Desna kolona (oko 40% širine): gore red od 4 ikon-dugmeta (48×48) s oznakama: Profil (mali avatar), Rang lista, Pravila, Postavke. Ispod u poluprozirnom panelu s blurom: veliko primarno dugme "Igraj online" (visina 56), te tri sekundarna dugmeta u koloni (visina 48): "Igra protiv botova", "Igraj s prijateljima", "Turniri".
Vertikalni budžet je mali (360–393 px): ništa se ne smije preklapati. Sav tekst na bosanskom. Puno praznog prostora, najviše 5 elemenata u meniju.

## Assistant

_[tool: dc_write]_

_[tool: ready_for_verification]_

Početni ekran je u `Belot Home.dc.html`, isti dizajn u okvirima iPhone 852×393 i Android 800×360. Ekran još prolazi automatsku provjeru.

- **Scena (lijevo, 60%):** sto u obliku elipse, 4 avatara od 56 px u bojama timova, tvoja lepeza od 8 karata, zatvorene karte kod ostalih i 2 zarotirane karte u sredini. Scena je zatamnjena 35% i blago zamućena, a prema meniju tamni do 90%.
- **Meni (desno, 40%):** gore red od 4 ikon-dugmeta s oznakama (Profil, Rang lista, Pravila, Postavke). Ispod je panel s blurom: „Igraj online“ (56 px) i tri sekundarna dugmeta (48 px).
- **Visina na Androidu:** sve stane točno u 360 px, s razmakom od 14 px između reda ikona i panela. Na iPhoneu ostaje više zraka.
- **Safe area:** ništa bitno nije u zonama od 60 px lijevo i desno ni u 20 px dolje.

U Tweaks panelu možeš uključiti prikaz safe area zona i podesiti zatamnjenje scene.

Na desnom igraču namjerno sam ostavio pulsirajući prsten da scena djeluje živo. Ako ti smeta, uklonit ću ga.

## User

Found issues — fixing…

## Assistant

_[tool: dc_html_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: ready_for_verification]_

Ispravio sam lepezu karata na Android okviru; ponovna provjera još traje.

- **Preklapanje s avatarom:** lepeza više ne prelazi preko avatara „Marko“. Pomaknuo sam je udesno, a razmak između karata smanjio s 30 na 28 px.
- **Safe zona dolje:** lepezu sam podigao na 36 px od donjeg ruba, pa ni zarotirane krajnje karte više ne ulaze u donju safe zonu od 20 px.

## User

Dizajniraj ekran partije Belota, isti stil kao u prethodnim koracima.

Platforma: nativna mobilna aplikacija za iPhone i Android, ISKLJUČIVO landscape. Prikaži ekran u dva okvira: iPhone 852×393 i Android 800×360 (isti dizajn, različit sistemski okvir). Fullscreen, status bar skriven. Safe area: otprilike 60 px lijevo i desno i oko 20 px dolje. Nijedan bitan element ne smije biti u tim zonama ni uz sam rub ekrana. Tap-targeti min. 48×48 px. UI igre je custom i isti na obje platforme.

Raspored (vertikalni budžet je mali, 360–393 px, ništa se ne smije preklapati):
- Dolje u sredini (ja): 8 karata (60×84) u blagoj lepezi, indeks vidljiv na svakoj, min. 32 px vidljivog ruba svake karte, podignuta najmanje 20 px od donjeg ruba. Jedna odabrana i podignuta 16 px, karte koje se ne smiju odigrati su zatamnjene. Moj avatar i nadimak lijevo od ruke, unutar safe area.
- Gore u sredini (partner), te lijevo i desno (protivnici, vertikalno centrirani, unutar safe area): avatar (40 px) + nadimak + broj karata u ruci kao mala oznaka uz poleđinu karte (bez lepeze, nema mjesta). Igrač na potezu ima pulsirajući prsten i tanak kružni timer oko avatara.
- Centar stola: 4 pozicije za odigrane karte (52×72) u obliku križa, svaka kod svog igrača, jedna tek odigrana s blagom sjenom.
- Gore lijevo: pill s rezultatom "Mi 0 | Vi 0", pored toga mala oznaka aduta (znak) i broj runde. Gore desno: dugme za meni i dugme za emoji/chat (48×48).
Sav tekst na bosanskom. Izbaci sve što ne služi igri.

## Assistant

_[tool: dc_write]_

_[tool: ready_for_verification]_

Ekran partije je u `Belot Partija.dc.html`, u okvirima iPhone 852×393 i Android 800×360. Još prolazi automatsku provjeru.

- **Ruka:** 8 karata u blagoj lepezi, 36 px vidljivog ruba po karti, 32 px od donjeg ruba. Herc 10 je odabran i podignut 16 px. Karte drugih boja su zatamnjene jer se mora pratiti herc.
- **Interakcija:** dodir na herc kartu je odabire, drugi dodir je odigra. Štih se zatim skupi i scena se vrati na početak.
- **Igrači:** partner gore, protivnici lijevo i desno, svaki s avatarom od 40 px, nadimkom i poleđinom karte s brojem karata u ruci.
- **Na potezu (ti):** pulsirajući prsten i kružni timer od 15 s, koji pred kraj postaje narančast.
- **Štih:** 4 pozicije u križu. Moja je prazna (isprekidan obrub) dok ne odigram. Zadnja odigrana karta ima jaču sjenu i blago je podignuta.
- **Gore:** lijevo „Mi 0 | Vi 0“, adut i „Runda 1“; desno dugmad za chat/emoji i meni (48×48).
- **Visina na Androidu:** partner zauzima 12–68 px, štih 74–222 px, ruka 244–328 px, pa se ništa ne preklapa.

U Tweaks panelu možeš uključiti prikaz safe area zona.

## User

Found issues — fixing…

## Assistant

_[tool: dc_html_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: ready_for_verification]_

Ispravio sam preklapanje na Android okviru: partnerov nadimak „AnaB“ prelazio je preko gornje odigrane karte. Sad stoji lijevo od avatara umjesto ispod, pa partnerov red završava oko 64 px visine, a gornja karta počinje na 74 px. Ponovna provjera još traje.

## User

Dizajniraj fazu biranja aduta u Belotu, isti raspored stola i isti stil kao na ekranu partije iz prethodnog koraka.

Platforma: nativna mobilna aplikacija za iPhone i Android, ISKLJUČIVO landscape. Prikaži ekran u dva okvira: iPhone 852×393 i Android 800×360. Fullscreen, safe area otprilike 60 px lijevo/desno i 20 px dolje. Tap-targeti min. 48×48 px, ništa uz sam rub.

- Moja ruka od 8 karata ostaje potpuno vidljiva u lepezi dolje, jer igrač mora vidjeti svoje karte dok odlučuje.
- U sredini stola je otkrivena karta (znak koji se nudi kao adut), s blagim isticanjem.
- Ne koristi bottom sheet (u landscapeu bi zaklonio karte). Umjesto toga kompaktan plutajući panel u desnom dijelu stola, iznad moje ruke, bez preklapanja s kartama i centrom: kratak naslov "Tvoj red", dva dugmeta u redu: "Zovi adut" (primarno, akcent boja) i "Dalje" (sekundarno), te tanki timer.
- Ostala tri igrača: avatar i nadimak, igrač na potezu ima pulsirajući prsten, a za one koji su već rekli "Dalje" mala oznaka s tim tekstom.
- Gore lijevo isti pill s rezultatom, gore desno meni i chat.
Sav tekst na bosanskom, bez ukrasa.

## Assistant

_[tool: read_file]_

_[tool: dc_write]_

_[tool: ready_for_verification]_

Faza biranja aduta je u `Belot Biranje aduta.dc.html`, isti raspored kao ekran partije, u okvirima iPhone i Android. Još prolazi automatsku provjeru.

- **Sredina:** ponuđena karta (K♥) s blagim žutim sjajem.
- **Panel:** „Tvoj red“ s preostalim sekundama, dugmad „Zovi adut“ i „Dalje“ u redu i tanki timer od 10 s koji pred kraj postaje narančast. Stoji desno od ponuđene karte i 12 px iznad ruke, lijevo od desnog igrača, pa ništa ne zaklanja.
- **Ruka:** svih 8 karata vidljivo, nijedna zatamnjena.
- **Igrači:** AnaB i Ivke imaju oznaku „Dalje“. Na potezu si ti, s pulsirajućim prstenom.
- **Gore:** isti pill s rezultatom i oznakom runde. Polje aduta pokazuje „?“ dok adut nije izabran.

Interakcija:
- **„Zovi adut“:** pojača se isticanje karte, herc se upiše kao adut, a pored tvog imena se pojavi „Zvao herc“.
- **„Dalje“:** dobiješ oznaku „Dalje“, a pulsirajući prsten prelazi na Luku.
- Scena se nakon oko 3 s vraća na početak.

Odluke koje sam donio sam:
- Igrači tokom biranja nemaju poleđinu s brojem karata, jer si tražio samo avatar i nadimak.
- Luka7 je zadnji u redu i još nije rekao „Dalje“.

## User

Razdvoji ovaj dizajn u dva potpuno odvojena projekta:
1. "Belot - iPhone": samo iPhone okvir (852×393), sve ploče koje sada postoje.
2. "Belot - Android": samo Android okvir (800×360), iste ploče.
U svakom projektu ostavi isključivo ploče te platforme, bez drugog okvira pored. Dizajn, tokeni i tekstovi ostaju identični, ne mijenjaj ništa osim razdvajanja. Ploče imenuj po ekranu ("Home", "Partija", "Biranje aduta").

## Assistant

_[tool: run_script]_

Files reference `./support.js`, so each folder needs its own copy.

_[tool: copy_files]_

_[tool: ready_for_verification]_

Nove projekte ne mogu napraviti, pa sam ploče razdvojio u dvije mape unutar ovog projekta. Otvorio sam ti Android verziju ekrana partije; provjera ostalih datoteka još traje.

- **`Belot - iPhone/`:** Home, Partija, Biranje aduta i Style guide, sve samo s okvirom 852×393.
- **`Belot - Android/`:** iste ploče, samo s okvirom 800×360.

Jedino što sam promijenio osim razdvajanja: u Android verziji Style guidea ekran partije se sada otvara u Android okviru. Dizajn, tokeni i tekstovi su identični. Originali s oba okvira ostali su u korijenu projekta.

Ako želiš prava dva projekta, napravi dva nova i preuzmi svaku mapu u njen projekt. Mogu i obrisati originale iz korijena.

## User

Spoji mi sve u jedan prototip ovo molim te

## Assistant

_[tool: dc_write]_

_[tool: dc_js_str_replace]_

_[tool: ready_for_verification]_

Spojio sam sve ekrane u jedan prototip koji se igra od početka do kraja runde: `Belot Prototip.dc.html`. Prototip još prolazi automatsku provjeru.

**Tok:**
- **Početna:** bilo koje dugme za igru dijeli nove karte i otvara biranje aduta.
- **Biranje aduta:** „Zovi adut“ ili „Dalje“. Ako kažeš „Dalje“, adut zove Luka. Nakon 10 s automatski se bira „Dalje“.
- **Partija:** odigra se 8 štihova. Partner i protivnici igraju sami i poštuju pravila (prate boju, inače sijeku adutom). Tebi su nedozvoljene karte zatamnjene. Bodovi se broje po pravilima Belota (zadnji štih +10), a dobitna karta se kratko istakne. Ako istekne tvojih 15 s, karta se odigra automatski.
- **Kraj runde:** rezultat, pa „Nova runda“ ili „Početna“. Dugme za meni tokom igre vraća na početnu.

**Pojednostavljenja:**
- Svaki štih uvijek otvara Ivke, da bi ti uvijek igrao zadnji, kako je raspored i dizajniran.
- Ponuđeni adut je jedna od Lukinih karata.
- Zvanja i bela nisu uključeni.

U Tweaks panelu biraš iPhone ili Android okvir i možeš uključiti prikaz safe area zona.

## User

Found issues — fixing…

## Assistant

_[tool: dc_html_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: dc_js_str_replace]_

_[tool: ready_for_verification]_

Ispravio sam preklapanje rezultata i partnera u prototipu: kad rezultat naraste na trocifrene brojeve, pill gore lijevo udarao je u AnaB-in avatar, a na Androidu već i s dvocifrenim. Ponovna provjera još traje.

- **Rezultat:** svaki broj sada ima fiksnu širinu od 3 cifre, pa se pill ne širi kako bodovi rastu.
- **Partner:** avatar je centriran na sredini ekrana, a nadimak i poleđina karte su desno od njega. Prema mom proračunu na Androidu ostaje oko 9 px razmaka do oznake runde i kod najvećeg rezultata. To je tijesno, a s trocifrenim rezultatom još nisam izmjerio.

Ista promjena važi i za fazu biranja aduta.

## User

Save as standalone HTML: `Belot Prototip.dc.html`

## Assistant

_[tool: run_script]_

_[tool: super_inline_html]_

_[tool: super_inline_html]_

Those are runtime template holes filled with inline data-URI avatars — nothing external to bundle.

_[tool: show_html]_

_[tool: get_webview_logs]_

_[tool: present_fs_item_for_download]_

`Belot Prototip.html` je spreman za preuzimanje: jedna datoteka od 237 KB koja radi bez interneta. Stranica se učitala bez grešaka.

