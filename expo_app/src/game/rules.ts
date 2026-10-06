import {
  CardId, ORDER_PLAIN, ORDER_TRUMP, POINTS_PLAIN, POINTS_TRUMP, SUITS, Suit, fullDeck, rankOf, suitOf,
} from './cards';

export type Seat = 'me' | 'top' | 'left' | 'right';
export type Hands = Record<Seat, CardId[]>;
export type Trick = Partial<Record<Seat, CardId>>;

/** Play order. In the prototype every trick is led by Ivke (left), so "me" always plays last. */
export const LEADER: Seat = 'left';
export const NEXT: Partial<Record<Seat, Seat>> = { left: 'top', top: 'right', right: 'me' };
export const TEAM_A: Record<Seat, boolean> = { me: true, top: true, left: false, right: false };
export const LAST_TRICK_BONUS = 10;

export const shuffle = <T,>(a: T[]): T[] => {
  a = a.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
};

export const pick = <T,>(a: T[]): T => a[Math.floor(Math.random() * a.length)];

export const sortHand = (h: CardId[]) =>
  h.slice().sort((a, b) =>
    SUITS.indexOf(suitOf(a)) - SUITS.indexOf(suitOf(b)) ||
    ORDER_PLAIN.indexOf(rankOf(b)) - ORDER_PLAIN.indexOf(rankOf(a)));

export function deal(): Hands {
  const d = shuffle(fullDeck());
  return { me: sortHand(d.slice(0, 8)), top: d.slice(8, 16), left: d.slice(16, 24), right: d.slice(24, 32) };
}

/** Must follow the led suit; otherwise must trump; otherwise anything. */
export function legalCards(hand: CardId[], led: Suit | null, trump: Suit | null): CardId[] {
  if (!led) return hand;
  const follow = hand.filter(c => suitOf(c) === led);
  if (follow.length) return follow;
  const trumps = hand.filter(c => suitOf(c) === trump);
  return trumps.length ? trumps : hand;
}

export const ledSuit = (trick: Trick): Suit | null => (trick[LEADER] ? suitOf(trick[LEADER]!) : null);

export function trickWinner(trick: Trick, trump: Suit | null): Seat {
  let best: Seat = LEADER;
  (['top', 'right', 'me'] as Seat[]).forEach(seat => {
    const c = trick[seat], b = trick[best];
    if (!c || !b) return;
    const s = suitOf(c), bs = suitOf(b);
    if (s === trump && bs !== trump) best = seat;
    else if (s === bs) {
      const order = s === trump ? ORDER_TRUMP : ORDER_PLAIN;
      if (order.indexOf(rankOf(c)) > order.indexOf(rankOf(b))) best = seat;
    }
  });
  return best;
}

export const trickPoints = (trick: Trick, trump: Suit | null) =>
  Object.values(trick).reduce((n, id) => n + (suitOf(id!) === trump ? POINTS_TRUMP : POINTS_PLAIN)[rankOf(id!)], 0);
