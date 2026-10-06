export type Suit = 'S' | 'H' | 'D' | 'C';
export type Rank = '7' | '8' | '9' | '10' | 'J' | 'Q' | 'K' | 'A';
/** Card id, e.g. "H-10". */
export type CardId = `${Suit}-${Rank}`;

export const SUIT_PATHS: Record<Suit, string> = {
  S: 'M12 2C9 6 4 9.5 4 13.6 4 16.3 6 18 8.4 18c1.3 0 2.5-.5 3.1-1.3L10.2 22h3.6l-1.3-5.3c.6.8 1.8 1.3 3.1 1.3 2.4 0 4.4-1.7 4.4-4.4C20 9.5 15 6 12 2z',
  H: 'M12 21.5C6.5 17.5 3 14 3 9.6 3 6.5 5.4 4 8.3 4c1.6 0 3 .8 3.7 2.1C12.7 4.8 14.1 4 15.7 4 18.6 4 21 6.5 21 9.6c0 4.4-3.5 7.9-9 11.9z',
  D: 'M12 2l7.5 10L12 22 4.5 12z',
  C: 'M12 2.5a4.3 4.3 0 0 1 3.9 6.1A4.3 4.3 0 1 1 13.3 16l1 6h-4.6l1-6a4.3 4.3 0 1 1-2.6-7.4A4.3 4.3 0 0 1 12 2.5z',
};

export const SUIT_NAME: Record<Suit, string> = { S: 'pik', H: 'herc', D: 'karo', C: 'tref' };

/** Geometric J/Q/K glyphs (34×44 viewBox) with the suit placed inside. */
export const FACE: Partial<Record<Rank, { d: string; tx: number; ty: number }>> = {
  J: { d: 'M14 2h6a8 8 0 0 1 8 8v24a8 8 0 0 1-8 8h-6a8 8 0 0 1-8-8V10a8 8 0 0 1 8-8z', tx: 11, ty: 16 },
  Q: { d: 'M17 6a15 15 0 1 1 0 30a15 15 0 1 1 0-30z', tx: 11, ty: 15 },
  K: { d: 'M2 40V14l8 8 7-14 7 14 8-8v26z', tx: 11, ty: 24 },
};

export const SUIT_COLOR: Record<Suit, string> = { S: '#1C2422', H: '#D33A3A', D: '#D33A3A', C: '#1C2422' };

export const RANKS: Rank[] = ['7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
/** Display order of suits in the hand. */
export const SUITS: Suit[] = ['S', 'H', 'C', 'D'];
/** Trick strength, weakest first. */
export const ORDER_PLAIN: Rank[] = ['7', '8', '9', 'J', 'Q', 'K', '10', 'A'];
export const ORDER_TRUMP: Rank[] = ['7', '8', 'Q', 'K', '10', 'A', '9', 'J'];
export const POINTS_PLAIN: Record<Rank, number> = { A: 11, '10': 10, K: 4, Q: 3, J: 2, '9': 0, '8': 0, '7': 0 };
export const POINTS_TRUMP: Record<Rank, number> = { J: 20, '9': 14, A: 11, '10': 10, K: 4, Q: 3, '8': 0, '7': 0 };

export const suitOf = (id: CardId) => id.split('-')[0] as Suit;
export const rankOf = (id: CardId) => id.split('-')[1] as Rank;

export const fullDeck = (): CardId[] => SUITS.flatMap(s => RANKS.map(r => `${s}-${r}` as CardId));
