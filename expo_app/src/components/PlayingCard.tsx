import { StyleSheet, View, ViewStyle } from 'react-native';
import Svg, { G, Path } from 'react-native-svg';
import { CardId, FACE, SUIT_COLOR, SUIT_PATHS, rankOf, suitOf } from '../game/cards';
import { colors, radius, shadows } from '../theme';
import { SuitIcon } from './SuitIcon';
import { Txt } from './Txt';

/** Hand card 60×84. Table cards (52×72) render this scaled, see TableCard. */
export const CARD_W = 60;
export const CARD_H = 84;

type Props = {
  id: CardId;
  shadow?: string;
  dim?: boolean;
  selected?: boolean;
  style?: ViewStyle;
};

/**
 * White card: large index (rank + suit) top-left so it stays readable when fanned,
 * a single big suit in the middle, geometric J/Q/K glyph for face cards.
 */
export function PlayingCard({ id, shadow = shadows.cardHand, dim, selected, style }: Props) {
  const suit = suitOf(id), rank = rankOf(id), color = SUIT_COLOR[suit], face = FACE[rank];
  return (
    <View style={[styles.card, { boxShadow: shadow }, style]}>
      <View style={styles.clip}>
        <View style={styles.index}>
          <Txt size={19} weight={800} lineHeight={19} em={-0.06} color={color} style={styles.rank}>{rank}</Txt>
          <SuitIcon suit={suit} size={14} color={color} />
        </View>
        {face ? (
          <Svg style={styles.face} width={34} height={44} viewBox="0 0 34 44">
            <Path d={face.d} fill={color} fillOpacity={0.12} stroke={color} strokeWidth={2} strokeLinejoin="round" />
            <G transform={`translate(${face.tx} ${face.ty}) scale(.5)`}>
              <Path d={SUIT_PATHS[suit]} fill={color} />
            </G>
          </Svg>
        ) : (
          <View style={styles.pip}><SuitIcon suit={suit} size={30} color={color} /></View>
        )}
        {dim && <View style={styles.dim} />}
        {selected && <View style={styles.selected} />}
      </View>
    </View>
  );
}

/** 52×72 card on the table: the hand card scaled by 52/60 × 72/84 from the top-left corner. */
export const TABLE_W = 52;
export const TABLE_H = 72;
export function TableCard(props: Props) {
  return (
    <View style={{ width: TABLE_W, height: TABLE_H }}>
      <PlayingCard {...props} style={{ transformOrigin: 'left top', transform: [{ scaleX: TABLE_W / CARD_W }, { scaleY: TABLE_H / CARD_H }] }} />
    </View>
  );
}

const styles = StyleSheet.create({
  card: { width: CARD_W, height: CARD_H, borderRadius: radius.card, backgroundColor: colors.cardFace },
  clip: { flex: 1, borderRadius: radius.card, overflow: 'hidden' },
  index: { position: 'absolute', left: 3, top: 5, width: 22, alignItems: 'center', gap: 2 },
  rank: { textAlign: 'center' },
  pip: { position: 'absolute', left: 20, top: 34 },
  face: { position: 'absolute', left: 20, top: 30 },
  dim: { ...StyleSheet.absoluteFill, backgroundColor: 'rgba(14,21,20,.55)' },
  selected: { ...StyleSheet.absoluteFill, borderRadius: radius.card, borderWidth: 2, borderColor: colors.accent },
});
