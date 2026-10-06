import { ReactNode, useEffect, useRef } from 'react';
import { Animated, Easing, ViewStyle } from 'react-native';

/** Fades (and optionally scales .9 → 1) in on mount — screenIn / cardIn from the prototype. */
export function FadeIn({ children, duration = 300, scale, style }: { children: ReactNode; duration?: number; scale?: boolean; style?: ViewStyle }) {
  const v = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    Animated.timing(v, { toValue: 1, duration, easing: Easing.out(Easing.quad), useNativeDriver: true }).start();
  }, [v, duration]);
  const transform = scale ? [{ scale: v.interpolate({ inputRange: [0, 1], outputRange: [0.9, 1] }) }] : [];
  return <Animated.View style={[style, { opacity: v, transform }]}>{children}</Animated.View>;
}

/** Animated value that eases toward `target` whenever it changes. */
export function useTween(target: number, duration: number, native = true) {
  const v = useRef(new Animated.Value(target)).current;
  useEffect(() => {
    Animated.timing(v, { toValue: target, duration, easing: Easing.inOut(Easing.ease), useNativeDriver: native }).start();
  }, [v, target, duration, native]);
  return v;
}

/** Ring that grows to 1.5× and fades out, looping — "on turn" indicator. */
export function PulseRing({ size, color, duration, style }: { size: number; color: string; duration: number; style?: ViewStyle }) {
  const v = useRef(new Animated.Value(0)).current;
  useEffect(() => {
    const loop = Animated.loop(Animated.timing(v, { toValue: 1, duration, easing: Easing.out(Easing.ease), useNativeDriver: true }));
    loop.start();
    return () => loop.stop();
  }, [v, duration]);
  return (
    <Animated.View
      pointerEvents="none"
      style={[{
        position: 'absolute', width: size, height: size, borderRadius: size / 2, borderWidth: 3, borderColor: color,
        opacity: v.interpolate({ inputRange: [0, 1], outputRange: [0.95, 0] }),
        transform: [{ scale: v.interpolate({ inputRange: [0, 1], outputRange: [1, 1.5] }) }],
      }, style]}
    />
  );
}
