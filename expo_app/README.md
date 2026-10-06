# Belot (Expo / React Native)

Implementation of the Claude Design prototype `design/project/Belot Prototip.dc.html`:
home → trump bidding → 8 tricks → round end. One codebase for iPhone and Android, landscape only.

```bash
npm install
npx expo start          # Expo Go / dev build
npx tsc --noEmit        # typecheck
```

## Structure

- `src/theme.ts`: design tokens (colours, radii, shadows, Plus Jakarta Sans weights, 60/20 px safe area)
- `src/game/`: cards, Belot rules (follow suit, otherwise trump; scoring with +10 for the last trick) and the `useBelot` state machine with bots and timers (10 s bid, 15 s turn)
- `src/components/`: playing card (60×84, table 52×72), card back (36×50), avatars with team ring, pulse and turn timer, buttons, glass panel
- `src/screens/`: `HomeScreen` (table scene plus menu) and `GameScreen` (bidding, trick, end of round)

Layout follows the prototype's pixel values. The side and bottom insets are the design's 60 px and 20 px,
or larger when the device's safe-area insets need more.

## Prototype simplifications (kept intentionally)

- Ivke always leads each trick, so you always play last.
- The offered trump card comes from Luka's hand. If you pass, Luka calls it.
- No declarations (zvanja) or bela. The score resets each round.
