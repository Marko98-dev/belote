import Svg, { Path } from 'react-native-svg';
import { SUIT_PATHS, Suit } from '../game/cards';

export function SuitIcon({ suit, size, color }: { suit: Suit; size: number; color: string }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24">
      <Path d={SUIT_PATHS[suit]} fill={color} />
    </Svg>
  );
}
