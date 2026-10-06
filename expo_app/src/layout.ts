import { useWindowDimensions } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { SAFE } from './theme';

export type Layout = {
  W: number;
  H: number;
  /** Left/right inset kept free on both sides (notch/Dynamic Island can be on either side). */
  side: number;
  /** Bottom inset for the home indicator / gesture bar. */
  bottom: number;
};

/** Screen size plus the design's safe area (60 px sides, 20 px bottom), widened if the device needs more. */
export function useLayout(): Layout {
  const { width, height } = useWindowDimensions();
  const insets = useSafeAreaInsets();
  return {
    W: width,
    H: height,
    side: Math.max(SAFE.side, insets.left, insets.right),
    bottom: Math.max(SAFE.bottom, insets.bottom),
  };
}
