# Belote

Mobilna online kartaška igra Belot za iPhone i Android, isključivo u landscape (ležećem) položaju.

## Sadržaj

| Mapa | Šta je |
|---|---|
| `flutter_app/` | Flutter verzija aplikacije (glavna, nastavlja se razvijati) |
| `expo_app/` | Prva implementacija u Expo / React Native (referenca) |
| `design/` | Dizajn iz Claude Designa: prototipi (`project/`), style guide i razgovor o dizajnu (`chats/`) |

Glavni prototip je `design/project/Belot Prototip.dc.html`. Opisuje tok početna → biranje aduta → partija → kraj runde.

## Probaj na Android telefonu

Svaki push na `main` pokreće GitHub Actions (`.github/workflows/flutter.yml`): analizu, testove i build Android APK-a.
APK preuzimaš iz kartice **Actions** → zadnji uspješan run → **Artifacts** → `belot-android-apk`. Raspakuj ga na telefonu i instaliraj (dozvoli instalaciju iz nepoznatih izvora).
Taj APK je potpisan debug ključem: dobar je za probu, ali ne za Google Play.

Za iPhone treba Mac s Xcodeom: `cd flutter_app && flutter run`.
