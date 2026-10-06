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

## Struktura

- `lib/theme.dart`: dizajn tokeni (boje, sjene, Plus Jakarta Sans, safe area 60/20 px)
- `lib/game/`: karte, pravila Belota (praćenje boje, inače sječenje adutom; bodovi + 10 za zadnji štih), `BelotController` (stanje, botovi, tajmeri 10 s / 15 s)
- `lib/widgets/`: karta (60×84, na stolu 52×72), poleđina (36×50), avatari s prstenom tima, pulsom i tajmerom, dugmad, staklena ploča
- `lib/screens/`: `HomeScreen` (scena stola + meni) i `GameScreen` (biranje aduta, štih, kraj runde)

Font Plus Jakarta Sans je u `assets/fonts/` (SIL Open Font License, `OFL.txt`).

## Pojednostavljenja iz prototipa (namjerno zadržana)

- Svaki štih otvara Ivke, pa ti uvijek igraš zadnji.
- Ponuđena karta za adut je iz Lukine ruke; ako kažeš „Dalje“, adut zove Luka.
- Nema zvanja ni bele; rezultat se resetuje svake runde.
