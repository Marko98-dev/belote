import { useCallback, useEffect, useReducer, useRef } from 'react';
import { CardId, Suit, suitOf } from './cards';
import {
  Hands, LAST_TRICK_BONUS, LEADER, NEXT, Seat, TEAM_A, Trick, deal, legalCards, ledSuit, pick, trickPoints, trickWinner,
} from './rules';

export const BID_MS = 10000;
export const PLAY_MS = 15000;

export type Screen = 'home' | 'bid' | 'play' | 'end';
/** mine: my turn to bid · called: I called · passed: I passed, Luka is deciding · luka: Luka called. */
export type BidPhase = 'mine' | 'called' | 'passed' | 'luka';

export interface GameState {
  screen: Screen;
  hands: Hands;
  offer: CardId;
  trump: Suit | null;
  bidPhase: BidPhase;
  trick: Trick;
  turn: Seat | null;
  selected: CardId | null;
  lastSeat: Seat | null;
  winSeat: Seat | null;
  scoreA: number;
  scoreB: number;
  round: number;
  /** Start of the current timed turn (ms). */
  t0: number;
}

type Action =
  | { type: 'startRound'; round: number; hands: Hands; offer: CardId }
  | { type: 'call' }
  | { type: 'pass' }
  | { type: 'lukaCalls' }
  | { type: 'startTrick' }
  | { type: 'play'; seat: Seat; card: CardId }
  | { type: 'select'; card: CardId }
  | { type: 'resolve' }
  | { type: 'end' }
  | { type: 'home' };

const empty: Hands = { me: [], top: [], left: [], right: [] };

const initial: GameState = {
  screen: 'home', hands: empty, offer: 'H-K', trump: null, bidPhase: 'mine', trick: {}, turn: null, selected: null,
  lastSeat: null, winSeat: null, scoreA: 0, scoreB: 0, round: 1, t0: 0,
};

export const playableCards = (s: GameState) => legalCards(s.hands.me, ledSuit(s.trick), s.trump);

function reducer(s: GameState, a: Action): GameState {
  switch (a.type) {
    case 'startRound':
      return { ...initial, screen: 'bid', hands: a.hands, offer: a.offer, round: a.round, t0: Date.now() };
    case 'call':
      return s.bidPhase === 'mine' ? { ...s, bidPhase: 'called', trump: suitOf(s.offer) } : s;
    case 'pass':
      return s.bidPhase === 'mine' ? { ...s, bidPhase: 'passed' } : s;
    case 'lukaCalls':
      return { ...s, bidPhase: 'luka', trump: suitOf(s.offer) };
    case 'startTrick':
      return { ...s, screen: 'play', trick: {}, turn: LEADER, selected: null, lastSeat: null, winSeat: null };
    case 'play': {
      if (s.turn !== a.seat) return s;
      const next = NEXT[a.seat] ?? null;
      return {
        ...s,
        hands: { ...s.hands, [a.seat]: s.hands[a.seat].filter(c => c !== a.card) },
        trick: { ...s.trick, [a.seat]: a.card },
        lastSeat: a.seat, turn: next, selected: null, t0: Date.now(),
      };
    }
    case 'select':
      return { ...s, selected: a.card };
    case 'resolve': {
      const win = trickWinner(s.trick, s.trump);
      const pts = trickPoints(s.trick, s.trump) + (s.hands.me.length === 0 ? LAST_TRICK_BONUS : 0);
      return TEAM_A[win] ? { ...s, winSeat: win, scoreA: s.scoreA + pts } : { ...s, winSeat: win, scoreB: s.scoreB + pts };
    }
    case 'end':
      return { ...s, screen: 'end', trick: {}, winSeat: null };
    case 'home':
      return { ...s, screen: 'home', turn: null };
  }
}

/**
 * Prototype game flow: home → trump bidding → 8 tricks → round end.
 * Bots (partner + opponents) play random legal cards. Every pending step is a single timeout
 * derived from the current state, so leaving the screen cancels everything automatically.
 */
export function useBelot() {
  const [state, dispatch] = useReducer(reducer, initial);
  const ref = useRef(state);
  ref.current = state;

  const { screen, bidPhase, turn, winSeat, trick, t0 } = state;
  const trickFull = Object.keys(trick).length === 4;

  useEffect(() => {
    const after = (ms: number, fn: () => void) => {
      const id = setTimeout(fn, Math.max(0, ms));
      return () => clearTimeout(id);
    };
    if (screen === 'bid') {
      if (bidPhase === 'mine') return after(t0 + BID_MS - Date.now(), () => dispatch({ type: 'pass' }));
      if (bidPhase === 'called') return after(1300, () => dispatch({ type: 'startTrick' }));
      if (bidPhase === 'passed') return after(1400, () => dispatch({ type: 'lukaCalls' }));
      if (bidPhase === 'luka') return after(1300, () => dispatch({ type: 'startTrick' }));
    }
    if (screen !== 'play') return;
    if (winSeat) {
      return after(1100, () => dispatch({ type: ref.current.hands.me.length === 0 ? 'end' : 'startTrick' }));
    }
    if (trickFull) return after(800, () => dispatch({ type: 'resolve' }));
    if (turn === 'me') {
      return after(t0 + PLAY_MS - Date.now(), () => dispatch({ type: 'play', seat: 'me', card: pick(playableCards(ref.current)) }));
    }
    if (turn) {
      const seat = turn;
      return after(seat === LEADER ? 800 : 650, () => {
        const s = ref.current;
        dispatch({ type: 'play', seat, card: pick(legalCards(s.hands[seat], ledSuit(s.trick), s.trump)) });
      });
    }
  }, [screen, bidPhase, turn, winSeat, trickFull, t0]);

  const startRound = useCallback((round: number) => {
    const hands = deal();
    // Prototype simplification: the offered trump card comes from Luka's hand.
    dispatch({ type: 'startRound', round, hands, offer: pick(hands.right) });
  }, []);

  const tapCard = useCallback((card: CardId) => {
    const s = ref.current;
    if (s.screen !== 'play' || s.turn !== 'me' || !playableCards(s).includes(card)) return;
    dispatch(s.selected === card ? { type: 'play', seat: 'me', card } : { type: 'select', card });
  }, []);

  return {
    state,
    startRound,
    call: useCallback(() => dispatch({ type: 'call' }), []),
    pass: useCallback(() => dispatch({ type: 'pass' }), []),
    tapCard,
    goHome: useCallback(() => dispatch({ type: 'home' }), []),
  };
}
