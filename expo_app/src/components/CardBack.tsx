import { useId } from 'react';
import { StyleSheet, View } from 'react-native';
import Svg, { Circle, Defs, Pattern, Rect } from 'react-native-svg';
import { colors, shadows } from '../theme';
import { Txt } from './Txt';

export const BACK_W = 36;
export const BACK_H = 50;

/** Closed card (36×50): dark frame, accent outline and a dot pattern in the accent colour. */
export function CardBack() {
  const pid = 'dots' + useId().replace(/:/g, '');
  const iw = BACK_W - 6, ih = BACK_H - 6;
  return (
    <View style={styles.back}>
      <Svg width={iw} height={ih}>
        <Defs>
          <Pattern id={pid} x={2} y={2} width={6} height={6} patternUnits="userSpaceOnUse">
            <Circle cx={3} cy={3} r={1.1} fill={colors.accent} />
          </Pattern>
        </Defs>
        <Rect x={0.5} y={0.5} width={iw - 1} height={ih - 1} rx={4} fill={colors.cardBackFill} />
        <Rect x={0.5} y={0.5} width={iw - 1} height={ih - 1} rx={4} fill={`url(#${pid})`} stroke="rgba(245,181,68,.55)" strokeWidth={1} />
      </Svg>
    </View>
  );
}

/** Fanned stack of closed cards (used on the home scene). */
export function BackStack({ count, step }: { count: number; step: number }) {
  return (
    <View style={{ width: 78, height: BACK_H }}>
      {Array.from({ length: count }, (_, i) => (
        <View key={i} style={{ position: 'absolute', top: 0, left: i * step }}><CardBack /></View>
      ))}
    </View>
  );
}

/** Closed card with the number of cards left in hand. */
export function BackWithCount({ count }: { count: number }) {
  return (
    <View style={{ width: BACK_W, height: BACK_H }}>
      <CardBack />
      <View style={styles.badge}>
        <Txt size={12} weight={800} lineHeight={14} color={colors.bg} tabular>{count}</Txt>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  back: { width: BACK_W, height: BACK_H, borderRadius: 6, backgroundColor: colors.bg, padding: 3, boxShadow: shadows.cardBack },
  badge: {
    position: 'absolute', right: -8, bottom: -6, minWidth: 22, height: 22, paddingHorizontal: 6, borderRadius: 999,
    backgroundColor: colors.text, alignItems: 'center', justifyContent: 'center', boxShadow: shadows.cardBack,
  },
});
