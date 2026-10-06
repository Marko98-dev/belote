import { ReactNode } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import Svg, { Defs, Ellipse, FeGaussianBlur, Filter, RadialGradient, Stop } from 'react-native-svg';
import { Avatar } from '../components/Avatar';
import { BackStack } from '../components/CardBack';
import { PrimaryButton, SecondaryButton } from '../components/Buttons';
import { LeaderboardIcon, PlayIcon, RulesIcon, SettingsIcon } from '../components/Icons';
import { PlayingCard, TableCard } from '../components/PlayingCard';
import { GlassPanel, HorizontalFill, RadialFill } from '../components/Surfaces';
import { Txt } from '../components/Txt';
import { FadeIn, PulseRing } from '../components/anim';
import { CardId } from '../game/cards';
import { Layout } from '../layout';
import { colors } from '../theme';

const HOME_HAND: CardId[] = ['H-A', 'H-10', 'H-K', 'S-J', 'S-9', 'D-Q', 'D-8', 'C-A'];
const HOME_TRICK: { id: CardId; x: number; y: number; rot: number }[] = [
  { id: 'H-Q', x: -50, y: -40, rot: -9 },
  { id: 'H-7', x: -2, y: -34, rot: 7 },
];

/**
 * Home: a dimmed "live table" scene on the left 60 % and the menu column on the right 40 %.
 */
export function HomeScreen({ layout, onPlay }: { layout: Layout; onPlay: () => void }) {
  const { W, H, side, bottom } = layout;
  const sceneW = W * 0.6;
  const menuW = Math.round(W * 0.4 - 76);
  const midY = H * 0.47;

  return (
    <FadeIn style={StyleSheet.absoluteFill}>
      <RadialFill cx={0.3} cy={0.5} rx={0.8} ry={1.2} colors={[[0, '#152321'], [0.7, colors.bg], [1, colors.bg]]} />

      {/* Scene */}
      <View style={[styles.scene, { width: sceneW }]} pointerEvents="none">
        <TableEllipse x={sceneW * 0.04} y={H * 0.09} w={sceneW * 0.94} h={H * 0.79} />

        {/* Partner (top): 56 avatar + 12 gap + 78 card stack = 146 wide, centred */}
        <View style={[styles.row, { position: 'absolute', top: 12, left: sceneW / 2 - 73, gap: 12 }]}>
          <Avatar who="top" size={56} ring={colors.teamA} />
          <View style={{ gap: 4 }}>
            <Txt size={12} weight={700}>AnaB</Txt>
            <BackStack count={7} step={7} />
          </View>
        </View>

        {/* Left opponent */}
        <VCenter top={midY} left={side + 12}>
          <View style={[styles.row, { gap: 12 }]}>
            <View style={styles.col}>
              <Avatar who="left" size={56} ring={colors.teamB} />
              <Txt size={12} weight={700}>Ivke</Txt>
            </View>
            <BackStack count={8} step={6} />
          </View>
        </VCenter>

        {/* Right opponent — on turn */}
        <VCenter top={midY} right={12}>
          <View style={[styles.row, { flexDirection: 'row-reverse', gap: 12 }]}>
            <View style={styles.col}>
              <View style={styles.center56}>
                <PulseRing size={56} color={colors.teamB} duration={1600} />
                <Avatar who="right" size={56} ring={colors.teamB} />
              </View>
              <Txt size={12} weight={700}>Luka7</Txt>
            </View>
            <BackStack count={7} step={7} />
          </View>
        </VCenter>

        {/* Two played cards */}
        <View style={{ position: 'absolute', left: sceneW / 2, top: midY }}>
          {HOME_TRICK.map(c => (
            <View key={c.id} style={{ position: 'absolute', left: c.x, top: c.y, transform: [{ rotate: `${c.rot}deg` }] }}>
              <TableCard id={c.id} shadow="0 1px 2px rgba(0,0,0,.25), 0 6px 16px rgba(0,0,0,.22)" />
            </View>
          ))}
        </View>

        {/* Me */}
        <View style={[styles.col, { position: 'absolute', left: side + 12, bottom: bottom + 4 }]}>
          <Txt size={12} weight={700}>Marko</Txt>
          <Avatar who="me" size={56} ring={colors.teamA} />
        </View>

        {/* My fan of 8 */}
        <View style={{ position: 'absolute', left: sceneW / 2 + 24 - 128, bottom: bottom + 16, width: 256, height: 84 }}>
          {HOME_HAND.map((id, i) => (
            <View key={id} style={{
              position: 'absolute', top: 0, left: i * 28, transformOrigin: 'bottom',
              transform: [{ translateY: Math.round((i - 3.5) ** 2 * 0.8) }, { rotate: `${(i - 3.5) * 3}deg` }],
            }}>
              <PlayingCard id={id} />
            </View>
          ))}
        </View>
      </View>

      {/* Dim the scene ~35 %, darkening to 90 % under the menu */}
      <HorizontalFill colors={[[0, colors.bg, 0.35], [0.52, colors.bg, 0.35], [0.66, colors.bg, 0.82], [1, colors.bg, 0.9]]} />

      {/* Wordmark */}
      <View style={[styles.row, { position: 'absolute', left: side + 12, top: 16, alignItems: 'flex-end', gap: 2 }]}>
        <Txt size={24} lineHeight={28} weight={800} em={-0.04}>Bellote</Txt>
        <View style={{ width: 6, height: 6, borderRadius: 3, backgroundColor: colors.accent, marginBottom: 7 }} />
      </View>

      {/* Menu column */}
      <View style={{ position: 'absolute', right: side, top: 12, bottom, width: menuW, justifyContent: 'space-between' }}>
        <View style={styles.row}>
          <TopAction label="Profil">
            <View style={styles.center48}><Avatar who="me" size={40} ring={colors.teamA} ringWidth={2} /></View>
          </TopAction>
          <TopAction label="Rang lista"><LeaderboardIcon /></TopAction>
          <TopAction label="Pravila"><RulesIcon /></TopAction>
          <TopAction label="Postavke"><SettingsIcon /></TopAction>
        </View>
        <GlassPanel tint="rgba(27,39,38,.55)" blur={20} style={{ padding: 12, gap: 8 }}>
          <PrimaryButton label="Igraj online" height={56} fontSize={18} icon={<PlayIcon />} onPress={onPlay} />
          <SecondaryButton label="Igra protiv botova" onPress={onPlay} />
          <SecondaryButton label="Igraj s prijateljima" onPress={onPlay} />
          <SecondaryButton label="Turniri" onPress={onPlay} />
        </GlassPanel>
      </View>
    </FadeIn>
  );
}

/** Icon button (48×48 chip) with a small label underneath. */
function TopAction({ label, children }: { label: string; children: ReactNode }) {
  return (
    <Pressable accessibilityRole="button" accessibilityLabel={label} style={({ pressed }) => [styles.topAction, pressed && { transform: [{ scale: 0.96 }] }]}>
      <View style={styles.chip48}>{children}</View>
      <Txt size={12} lineHeight={14} weight={600} numberOfLines={1}>{label}</Txt>
    </Pressable>
  );
}

/** Absolutely positioned wrapper whose child is vertically centred on `top`. */
function VCenter({ top, left, right, children }: { top: number; left?: number; right?: number; children: ReactNode }) {
  return (
    <View style={{ position: 'absolute', top: top - 100, height: 200, left, right, justifyContent: 'center' }}>{children}</View>
  );
}

/** Oval table: soft drop shadow, teal radial gradient, inner vignette, faint hairline. */
function TableEllipse({ x, y, w, h }: { x: number; y: number; w: number; h: number }) {
  const pad = 70;
  const cx = w / 2 + pad, cy = h / 2 + pad;
  return (
    <Svg style={{ position: 'absolute', left: x - pad, top: y - pad }} width={w + 2 * pad} height={h + 2 * pad}>
      <Defs>
        <Filter id="tableShadow" x="-50%" y="-50%" width="200%" height="200%"><FeGaussianBlur stdDeviation={30} /></Filter>
        <RadialGradient id="tableFill" cx="50%" cy="45%" rx="71%" ry="78%" fx="50%" fy="45%">
          <Stop offset={0} stopColor="#175A55" />
          <Stop offset={0.55} stopColor="#134E4A" />
          <Stop offset={1} stopColor="#10433F" />
        </RadialGradient>
        <RadialGradient id="tableVignette" cx="50%" cy="50%" r="50%">
          <Stop offset={0.72} stopColor="#000" stopOpacity={0} />
          <Stop offset={1} stopColor="#000" stopOpacity={0.28} />
        </RadialGradient>
      </Defs>
      <Ellipse cx={cx} cy={cy + 24} rx={w / 2} ry={h / 2} fill="#000" fillOpacity={0.55} filter="url(#tableShadow)" />
      <Ellipse cx={cx} cy={cy} rx={w / 2} ry={h / 2} fill="url(#tableFill)" />
      <Ellipse cx={cx} cy={cy} rx={w / 2} ry={h / 2} fill="url(#tableVignette)" stroke="rgba(244,241,234,.04)" strokeWidth={1} />
    </Svg>
  );
}

const styles = StyleSheet.create({
  scene: { position: 'absolute', left: 0, top: 0, bottom: 0 },
  row: { flexDirection: 'row', alignItems: 'center' },
  col: { alignItems: 'center', gap: 4 },
  center56: { width: 56, height: 56, alignItems: 'center', justifyContent: 'center' },
  center48: { width: 48, height: 48, alignItems: 'center', justifyContent: 'center' },
  topAction: { flex: 1, alignItems: 'center', gap: 4 },
  chip48: { width: 48, height: 48, borderRadius: 999, backgroundColor: 'rgba(244,241,234,.08)', alignItems: 'center', justifyContent: 'center' },
});
