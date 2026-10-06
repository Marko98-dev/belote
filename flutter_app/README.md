# Belot (Flutter)

Flutter implementacija prototipa `design/project/Belot Prototip.dc.html`: početna → biranje aduta → 8 štihova → kraj runde.
Jedan kod za iPhone i Android, samo landscape, status bar skriven.

## Pokretanje

```bash
flutter pub get
flutter run              # spojen telefon ili emulator / simulator
flutter run -d chrome    # brza proba u pregledniku
flutter test             # testovi pravila i cijele runde na 852×393 i 800×360
```

Za iPhone treba Mac s Xcodeom. Za Android je dovoljan Android Studio (ili samo Android SDK) na Windowsu, macOS-u ili Linuxu.

## Šta igra zna

- **Pravila Bele:** djelitelj se mijenja svake runde. Adut se bira u dva kruga: prvo se nudi djeliteljeva otkrivena karta, zatim bilo koja druga boja, a djelitelj u drugom krugu mora zvati. Mora se pratiti boja i igrati jača karta, sjeći adutom i prebiti jači adut.
- **Bodovanje:** karte (162), zvanja (nizovi i četiri iste), bela, štiglja i pad. Igra se do 501, 701 ili 1001.
- **Botovi:** zovu adut prema snazi ruke, štih uzimaju najjeftinijom kartom, partneru dodaju bodove, a inače bacaju najslabiju kartu.
- **Ekrani:** početna (pravila, postavke, „Uskoro“ za online), biranje aduta, partija s oznakama (zvanje, bela, ko je zvao), emoji, potvrda prije izlaska i pregled bodova na kraju runde.

## Struktura

- `lib/theme.dart`: dizajn tokeni (boje, sjene, Plus Jakarta Sans, safe area 60/20 px)
- `lib/game/cards.dart`, `rules.dart`: karte, pravila, zvanja i bodovanje runde
- `lib/game/bots.dart`: logika botova za zvanje i igru
- `lib/game/belot_controller.dart`: tok igre (djelitelj, licitacija, štihovi, rezultat, tajmeri 10 s / 15 s)
- `lib/widgets/`: karta (60×84, na stolu 52×72), poleđina (36×50), avatari, dugmad, staklena ploča, modalni prozor
- `lib/screens/`: `HomeScreen`, `home_panels.dart` (pravila, postavke), `GameScreen`

Font Plus Jakarta Sans je u `assets/fonts/` (SIL Open Font License, `OFL.txt`). Ikonica aplikacije je u `assets/icon/`. Ponovo se generiše s `dart run flutter_launcher_icons`, a splash s `dart run flutter_native_splash:create`.

## Još nije urađeno

- **Online igra:** online igra, igra s prijateljima, turniri, profil i rang lista. Za sve to treba server.
- **Zvanja:** zvanja se prijavljuju automatski. Nema ručnog prijavljivanja ni „visi“ kod neriješenog rezultata, jer tim koji je zvao pada već kad je izjednačeno.
- **Postavke:** ne pamte se nakon zatvaranja aplikacije.
