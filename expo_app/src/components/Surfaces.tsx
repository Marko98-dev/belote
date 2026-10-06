import { BlurView } from 'expo-blur';
import { ReactNode, useId } from 'react';
import { StyleSheet, View, ViewStyle } from 'react-native';
import Svg, { Defs, LinearGradient, RadialGradient, Rect, Stop } from 'react-native-svg';
import { radius, shadows } from '../theme';

type Stops = [offset: number, color: string, opacity?: number][];

const stops = (s: Stops) => s.map(([o, c, op = 1], i) => <Stop key={i} offset={o} stopColor={c} stopOpacity={op} />);

/** Full-size radial gradient (ellipse radii in fractions of width/height, like CSS `ellipse rx% ry% at cx% cy%`). */
export function RadialFill({ cx, cy, rx, ry, colors: s }: { cx: number; cy: number; rx: number; ry: number; colors: Stops }) {
  const id = 'rg' + useId().replace(/:/g, '');
  return (
    <Svg style={StyleSheet.absoluteFill} width="100%" height="100%" preserveAspectRatio="none">
      <Defs><RadialGradient id={id} cx={cx} cy={cy} rx={rx} ry={ry} fx={cx} fy={cy} gradientUnits="objectBoundingBox">{stops(s)}</RadialGradient></Defs>
      <Rect width="100%" height="100%" fill={`url(#${id})`} />
    </Svg>
  );
}

/** Full-size horizontal linear gradient. */
export function HorizontalFill({ colors: s }: { colors: Stops }) {
  const id = 'lg' + useId().replace(/:/g, '');
  return (
    <Svg style={StyleSheet.absoluteFill} width="100%" height="100%" pointerEvents="none">
      <Defs><LinearGradient id={id} x1={0} y1={0} x2={1} y2={0}>{stops(s)}</LinearGradient></Defs>
      <Rect width="100%" height="100%" fill={`url(#${id})`} />
    </Svg>
  );
}

/** The game table surface: matte teal with a barely visible radial gradient. */
export const TableFill = () => (
  <RadialFill cx={0.5} cy={0.42} rx={0.75} ry={0.85} colors={[[0, '#175A55'], [0.55, '#134E4A'], [1, '#0F3E3A']]} />
);

/** Translucent blurred panel with a hairline inner border and soft shadow. */
export function GlassPanel({ tint, blur, style, children }: { tint: string; blur: number; style?: ViewStyle; children: ReactNode }) {
  return (
    <View style={[{ borderRadius: radius.panel, boxShadow: shadows.panelDrop }, style]}>
      <View style={[StyleSheet.absoluteFill, { borderRadius: radius.panel, overflow: 'hidden' }]} pointerEvents="none">
        <BlurView intensity={blur * 3} tint="dark" style={StyleSheet.absoluteFill} />
        <View style={[StyleSheet.absoluteFill, { backgroundColor: tint }]} />
      </View>
      {children}
      {/* inset 0 0 0 1px hairline, drawn above the blur layer */}
      <View pointerEvents="none" style={[StyleSheet.absoluteFill, { borderRadius: radius.panel, borderWidth: 1, borderColor: 'rgba(244,241,234,.08)' }]} />
    </View>
  );
}
