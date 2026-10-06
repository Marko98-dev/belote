// Design tokens from the Belot style guide (Claude Design handoff).

export const colors = {
  appBg: '#0A100F',
  bg: '#0E1514',
  surface: '#131D1C',
  table: '#134E4A',
  tableLight: '#175A55',
  tableDark: '#0F3E3A',
  accent: '#F5B544',
  accentHover: '#F8C062',
  accentPressed: '#D99A2B',
  onAccent: '#1F1606',
  text: '#F4F1EA',
  textMuted: '#9AA6A2',
  textSoft: '#C9D1CE',
  teamA: '#FF6B5B',
  teamB: '#4DA3FF',
  warning: '#FF8A3D',
  cardFace: '#FFFFFF',
  cardBackFill: '#18221F',
  suitBlack: '#1C2422',
  suitRed: '#D33A3A',
  // translucent surfaces
  chip: 'rgba(14,21,20,.55)',
  chipPressed: 'rgba(14,21,20,.85)',
  outline: 'rgba(244,241,234,.36)',
  outlineHover: 'rgba(244,241,234,.52)',
  ghostPressed: 'rgba(244,241,234,.10)',
  hairline: 'rgba(244,241,234,.08)',
};

export const radius = { card: 8, panel: 16, pill: 999 };

export const shadows = {
  soft: '0 2px 8px rgba(0,0,0,.16), 0 8px 24px rgba(0,0,0,.18)',
  panel: 'inset 0 0 0 1px rgba(244,241,234,.08), 0 16px 40px rgba(0,0,0,.36)',
  panelDrop: '0 16px 40px rgba(0,0,0,.36)',
  cardHand: '0 1px 2px rgba(0,0,0,.25), -2px 2px 10px rgba(0,0,0,.2)',
  cardHandSelected: '0 16px 32px rgba(0,0,0,.36)',
  cardTable: '0 1px 2px rgba(0,0,0,.25), 0 4px 10px rgba(0,0,0,.18)',
  cardJustPlayed: '0 2px 4px rgba(0,0,0,.2), 0 14px 28px rgba(0,0,0,.34)',
  cardWinner: '0 0 0 3px #F5B544, 0 10px 24px rgba(0,0,0,.3)',
  cardBack: '0 2px 6px rgba(0,0,0,.3)',
  offer: '0 0 0 2px rgba(245,181,68,.75), 0 0 24px rgba(245,181,68,.25), 0 10px 24px rgba(0,0,0,.3)',
  offerCalled: '0 0 0 3px #F5B544, 0 0 32px rgba(245,181,68,.45), 0 10px 24px rgba(0,0,0,.3)',
};

/** Safe area used by the design: 60 px left/right (notch on either side), 20 px bottom. */
export const SAFE = { side: 60, bottom: 20 };

/** Plus Jakarta Sans — each weight is a separate font family in React Native. */
export const font = {
  400: 'PlusJakartaSans_400Regular',
  500: 'PlusJakartaSans_500Medium',
  600: 'PlusJakartaSans_600SemiBold',
  700: 'PlusJakartaSans_700Bold',
  800: 'PlusJakartaSans_800ExtraBold',
} as const;
export type Weight = keyof typeof font;
