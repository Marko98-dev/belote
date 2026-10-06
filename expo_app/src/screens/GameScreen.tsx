import { ReactNode, useEffect, useState } from 'react';
import { Animated, Pressable, StyleSheet, View } from 'react-native';
import { SeatAvatar, LookKey } from '../components/Avatar';
import { PrimaryButton, SecondaryButton, IconButton } from '../components/Buttons';
import { BackWithCount } from '../components/CardBack';
import { ChatIcon, MenuIcon } from '../components/Icons';
import { CARD_H, PlayingCard, TableCard } from '../components/PlayingCard';
import { GlassPanel } from '../components/Surfaces';
import { SuitIcon } from '../components/SuitIcon';
import { Txt } from '../components/Txt';
import { FadeIn, useTween } from '../components/anim';
import { CardId, SUIT_COLOR, SUIT_NAME, suitOf } from '../game/cards';
import { Seat } from '../game/rules';
import { BID_MS, GameState, PLAY_MS, playableCards } from '../game/useBelot';
import { Layout } from '../layout';
import { colors, shadows } from '../theme';

type Props = {
  layout: Layout;
  state: GameState;
  onCall: () => void;
  onPass: () => void;
  onCard: (id: CardId) => void;
  onMenu: () => void;
  onNextRound: () => void;
};

/** Hand: 36 px of each card visible, gentle arc, selected card lifted 16 px. */
const HAND_STEP = 36;

/** Fraction of time left (1 → 0), ticking every 100 ms while `active`. */
function useCountdown(t0: number, ms: number, active: boolean) {
  const [now, setNow] = useState(Date.now);
  useEffect(() => {
    if (!active) return;
    setNow(Date.now());
    const iv = setInterval(() => setNow(Date.now()), 100);
    return () => clearInterval(iv);
  }, [active, t0]);
  return Math.max(0, Math.min(1, 1 - (now - t0) / ms));
}
const timerColor = (left: number) => (left < 0.3 ? colors.warning : colors.accent);

export function GameScreen({ layout, state: s, onCall, onPass, onCard, onMenu, onNextRound }: Props) {
  const { W, H, side, bottom } = layout;
  const isBid = s.screen === 'bid';
  const isPlay = s.screen === 'play' || s.screen === 'end';
  const handBottom = bottom + 12;
  const cyPlay = Math.round((68 + (H - handBottom - CARD_H - 16)) / 2);
  const cyBid = Math.round((68 + (H - handBottom - CARD_H)) / 2);
  const bp = s.bidPhase;
  const calledLabel = 'Zvao ' + SUIT_NAME[suitOf(s.offer)];

  return (
    <FadeIn style={StyleSheet.absoluteFill}>
      <TopBar layout={layout} state={s} onMenu={onMenu} />

      {/* Players */}
      <View style={[styles.row, { position: 'absolute', top: 12, left: W / 2 - 26, gap: 8 }]}>
        <View style={[styles.row, { gap: isBid ? 8 : 6 }]}>
          <SeatAvatar who="top" ring={colors.teamA} turn={isPlay && s.turn === 'top'} />
          <Labels name="AnaB" align="flex-start" passed={isBid} />
        </View>
        {isPlay && <BackWithCount count={s.hands.top.length} />}
      </View>

      <SideSeat layout={layout} side="left" who="left" name="Ivke" state={s} passed={isBid} />
      <SideSeat layout={layout} side="right" who="right" name="Luka7" state={s}
        turn={isBid ? bp === 'passed' : s.turn === 'right'} called={isBid && bp === 'luka' ? calledLabel : undefined} />

      {isBid ? (
        <View style={[styles.row, { position: 'absolute', left: side + 12, top: H - handBottom - 72, gap: 8 }]}>
          <SeatAvatar who="me" ring={colors.teamA} turn={bp === 'mine'} />
          <Labels name="Marko" align="flex-start" passed={bp === 'passed' || bp === 'luka'} called={bp === 'called' ? calledLabel : undefined} />
        </View>
      ) : (
        <View style={[styles.col, { position: 'absolute', left: side + 12, top: H - handBottom - 68, gap: 2 }]}>
          <MyTimerAvatar state={s} />
          <Txt size={12} lineHeight={14} weight={700}>Marko</Txt>
        </View>
      )}

      {/* Offered trump card */}
      {isBid && (
        <FadeIn scale style={{ position: 'absolute', left: W / 2 - 30, top: cyBid - 42 }}>
          <PlayingCard id={s.offer} shadow={bp === 'called' || bp === 'luka' ? shadows.offerCalled : shadows.offer} />
        </FadeIn>
      )}

      {/* Trick: four slots in a cross, each next to its player */}
      {isPlay && (
        <View style={{ position: 'absolute', left: W / 2, top: cyPlay }}>
          <TrickSlot state={s} seat="top" x={-26} y={-74} />
          <TrickSlot state={s} seat="left" x={-88} y={-36} />
          <TrickSlot state={s} seat="right" x={36} y={-36} />
          <TrickSlot state={s} seat="me" x={-26} y={2} />
        </View>
      )}

      <Hand state={s} bottom={handBottom} onCard={onCard} />

      {isBid && bp === 'mine' && (
        <View style={{ position: 'absolute', left: W / 2 + 48, bottom: handBottom + 96, width: 212 }}>
          <BidPanel t0={s.t0} onCall={onCall} onPass={onPass} />
        </View>
      )}

      {s.screen === 'end' && <EndOverlay state={s} onHome={onMenu} onNext={onNextRound} />}
    </FadeIn>
  );
}

function TopBar({ layout, state: s, onMenu }: { layout: Layout; state: GameState; onMenu: () => void }) {
  return (
    <>
      <View style={[styles.row, { position: 'absolute', left: layout.side + 12, top: 12, gap: 8 }]}>
        <View style={[styles.pill, { gap: 10, paddingHorizontal: 14 }]}>
          <Score dot={colors.teamA} label="Mi" value={s.scoreA} />
          <View style={{ width: 1, height: 16, backgroundColor: 'rgba(244,241,234,.2)' }} />
          <Score dot={colors.teamB} label="Vi" value={s.scoreB} />
        </View>
        <View style={[styles.pill, { gap: 8, paddingLeft: 8, paddingRight: 12 }]}>
          {s.trump ? (
            <View style={styles.trumpChip}><SuitIcon suit={s.trump} size={14} color={SUIT_COLOR[s.trump]} /></View>
          ) : (
            <View style={[styles.trumpChip, styles.trumpUnknown]}><Txt size={12} weight={800} color={colors.textMuted}>?</Txt></View>
          )}
          <Txt size={12} weight={700} em={0.04} tabular>Runda {s.round}</Txt>
        </View>
      </View>
      <View style={[styles.row, { position: 'absolute', right: layout.side, top: 8, gap: 8 }]}>
        <IconButton label="Emoji i chat"><ChatIcon /></IconButton>
        <IconButton label="Meni" onPress={onMenu}><MenuIcon /></IconButton>
      </View>
    </>
  );
}

/** Each score has a fixed 3-digit width so the pill never grows into the partner's seat. */
function Score({ dot, label, value }: { dot: string; label: string; value: number }) {
  return (
    <View style={[styles.row, { gap: 6 }]}>
      <View style={[styles.dot, { backgroundColor: dot }]} />
      <Txt size={15} weight={600}>{label}</Txt>
      <Txt size={15} weight={800} tabular style={{ minWidth: 28 }}>{value}</Txt>
    </View>
  );
}

function Labels({ name, align, passed, called }: { name: string; align: 'center' | 'flex-start'; passed?: boolean; called?: string }) {
  return (
    <View style={{ alignItems: align, gap: 4 }}>
      <Txt size={12} lineHeight={14} weight={700} numberOfLines={1}>{name}</Txt>
      {passed && <View style={[styles.badge, { backgroundColor: 'rgba(14,21,20,.6)' }]}><Txt size={12} lineHeight={20} weight={600} color={colors.textSoft}>Dalje</Txt></View>}
      {called && <View style={[styles.badge, { backgroundColor: colors.accent }]}><Txt size={12} lineHeight={20} weight={700} color={colors.onAccent}>{called}</Txt></View>}
    </View>
  );
}

function SideSeat({ layout, side, who, name, state: s, turn, passed, called }: {
  layout: Layout; side: 'left' | 'right'; who: LookKey; name: string; state: GameState; turn?: boolean; passed?: boolean; called?: string;
}) {
  const isPlay = s.screen !== 'bid';
  const onTurn = turn ?? (isPlay && s.turn === side);
  return (
    <View style={{ position: 'absolute', top: 0, bottom: 0, [side]: layout.side + 12, justifyContent: 'center' }}>
      <View style={[styles.row, { gap: 8, flexDirection: side === 'right' && isPlay ? 'row-reverse' : 'row' }]}>
        <View style={[styles.col, { gap: 2 }]}>
          <SeatAvatar who={who} ring={colors.teamB} turn={onTurn} />
          <Labels name={name} align="center" passed={passed} called={called} />
        </View>
        {isPlay && <BackWithCount count={s.hands[side].length} />}
      </View>
    </View>
  );
}

function MyTimerAvatar({ state: s }: { state: GameState }) {
  const mine = s.screen === 'play' && s.turn === 'me';
  const left = useCountdown(s.t0, PLAY_MS, mine);
  return <SeatAvatar who="me" ring={colors.teamA} turn={mine} timerLeft={mine ? left : undefined} timerColor={timerColor(left)} />;
}

function TrickSlot({ state: s, seat, x, y }: { state: GameState; seat: Seat; x: number; y: number }) {
  const id = s.trick[seat];
  const win = s.winSeat === seat;
  const just = !s.winSeat && s.lastSeat === seat;
  const lift = useTween(just ? -4 : 0, 200);
  return (
    <View style={{ position: 'absolute', left: x, top: y }}>
      {id ? (
        <FadeIn key={id} scale duration={200}>
          <Animated.View style={{ transform: [{ translateY: lift }] }}>
            <TableCard id={id} shadow={win ? shadows.cardWinner : just ? shadows.cardJustPlayed : shadows.cardTable} />
          </Animated.View>
        </FadeIn>
      ) : (
        <View style={styles.emptySlot} />
      )}
    </View>
  );
}

function Hand({ state: s, bottom, onCard }: { state: GameState; bottom: number; onCard: (id: CardId) => void }) {
  const hand = s.hands.me;
  const myTurn = s.screen === 'play' && s.turn === 'me';
  const playable = myTurn ? playableCards(s) : [];
  const mid = (hand.length - 1) / 2;
  const width = Math.max(0, hand.length - 1) * HAND_STEP + 60;
  return (
    <View style={{ position: 'absolute', left: '50%', bottom: bottom + CARD_H, width: 0, height: 0 }}>
      {hand.map((id, i) => {
        const ok = playable.includes(id);
        return (
          <HandCard key={id} id={id} x={i * HAND_STEP - width / 2} rot={(i - mid) * 2}
            arc={Math.round((i - mid) ** 2 * 0.55)} selected={s.selected === id} dim={myTurn && !ok} playable={ok} onPress={onCard} />
        );
      })}
    </View>
  );
}

function HandCard({ id, x, rot, arc, selected, dim, playable, onPress }: {
  id: CardId; x: number; rot: number; arc: number; selected: boolean; dim: boolean; playable: boolean; onPress: (id: CardId) => void;
}) {
  const tx = useTween(x, 250);
  const r = useTween(rot, 250);
  const ty = useTween(arc + (selected ? -16 : 0), 180);
  return (
    <Animated.View style={{
      position: 'absolute', top: 0, left: 0, transformOrigin: 'bottom',
      transform: [{ translateX: tx }, { translateY: ty }, { rotate: r.interpolate({ inputRange: [-90, 90], outputRange: ['-90deg', '90deg'] }) }],
    }}>
      <Pressable onPress={() => onPress(id)} disabled={!playable} accessibilityRole="button">
        <PlayingCard id={id} dim={dim} selected={selected} shadow={selected ? shadows.cardHandSelected : shadows.cardHand} />
      </Pressable>
    </Animated.View>
  );
}

function BidPanel({ t0, onCall, onPass }: { t0: number; onCall: () => void; onPass: () => void }) {
  const left = useCountdown(t0, BID_MS, true);
  const c = timerColor(left);
  return (
    <FadeIn duration={250}>
      <GlassPanel tint="rgba(14,21,20,.72)" blur={16} style={{ padding: 12, gap: 8 }}>
        <View style={[styles.row, { justifyContent: 'space-between', alignItems: 'baseline' }]}>
          <Txt size={15} lineHeight={20} weight={700}>Tvoj red</Txt>
          <Txt size={12} weight={700} color={c} tabular>{Math.ceil(left * BID_MS / 1000)} s</Txt>
        </View>
        <View style={[styles.row, { gap: 8 }]}>
          <PrimaryButton label="Zovi adut" onPress={onCall} style={{ flexGrow: 1, flexShrink: 1 }} />
          <SecondaryButton label="Dalje" onPress={onPass} style={{ paddingHorizontal: 16 }} />
        </View>
        <View style={styles.track}><View style={[styles.fill, { width: `${left * 100}%`, backgroundColor: c }]} /></View>
      </GlassPanel>
    </FadeIn>
  );
}

function EndOverlay({ state: s, onHome, onNext }: { state: GameState; onHome: () => void; onNext: () => void }) {
  const title = s.scoreA === s.scoreB ? 'Neriješeno' : s.scoreA > s.scoreB ? 'Mi smo pobijedili' : 'Vi ste pobijedili';
  return (
    <FadeIn style={{ ...StyleSheet.absoluteFill, ...styles.endBackdrop }}>
      <View style={styles.endCard}>
        <View style={[styles.col, { gap: 4 }]}>
          <Txt size={12} weight={700} em={0.06} color={colors.textMuted}>{`KRAJ RUNDE ${s.round}`}</Txt>
          <Txt size={24} lineHeight={28} weight={700}>{title}</Txt>
        </View>
        <View style={[styles.row, { justifyContent: 'center', gap: 16 }]}>
          <EndScore dot={colors.teamA} label="Mi" value={s.scoreA} />
          <Txt color={colors.textMuted}>:</Txt>
          <EndScore dot={colors.teamB} label="Vi" value={s.scoreB} reverse />
        </View>
        <View style={[styles.row, { gap: 8 }]}>
          <SecondaryButton label="Početna" onPress={onHome} style={{ paddingHorizontal: 20 }} />
          <PrimaryButton label="Nova runda" onPress={onNext} style={{ flexGrow: 1, paddingHorizontal: 20 }} />
        </View>
      </View>
    </FadeIn>
  );
}

function EndScore({ dot, label, value, reverse }: { dot: string; label: string; value: number; reverse?: boolean }) {
  const parts: ReactNode[] = [
    <View key="d" style={[styles.dot, { backgroundColor: dot }]} />,
    <Txt key="l" size={15} weight={600}>{label}</Txt>,
    <Txt key="v" size={24} weight={800} tabular>{value}</Txt>,
  ];
  return <View style={[styles.row, { gap: 8 }]}>{reverse ? parts.reverse() : parts}</View>;
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center' },
  col: { alignItems: 'center' },
  pill: { flexDirection: 'row', alignItems: 'center', height: 40, borderRadius: 999, backgroundColor: colors.chip },
  dot: { width: 8, height: 8, borderRadius: 4 },
  trumpChip: { width: 24, height: 24, borderRadius: 12, backgroundColor: colors.cardFace, alignItems: 'center', justifyContent: 'center' },
  trumpUnknown: { backgroundColor: 'transparent', borderWidth: 1.5, borderStyle: 'dashed', borderColor: 'rgba(244,241,234,.4)' },
  badge: { height: 20, paddingHorizontal: 8, borderRadius: 999, justifyContent: 'center' },
  emptySlot: { width: 52, height: 72, borderRadius: 8, borderWidth: 1.5, borderStyle: 'dashed', borderColor: 'rgba(244,241,234,.22)' },
  track: { height: 4, borderRadius: 999, backgroundColor: 'rgba(244,241,234,.14)', overflow: 'hidden' },
  fill: { height: '100%', borderRadius: 999 },
  endBackdrop: { backgroundColor: 'rgba(14,21,20,.6)', alignItems: 'center', justifyContent: 'center' },
  endCard: { width: 300, padding: 24, borderRadius: 16, backgroundColor: colors.surface, gap: 16, boxShadow: shadows.panel },
});
