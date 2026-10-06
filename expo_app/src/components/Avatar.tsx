import { StyleSheet, View } from 'react-native';
import Svg, { Circle } from 'react-native-svg';
import { SvgXml } from 'react-native-svg';
import { colors } from '../theme';
import { PulseRing } from './anim';

type Look = { bg: string; skin: string; hair: string; shirt: string; type: 'short' | 'long' | 'cap' | 'afro'; cap?: string };

/** Flat vector faces for the four players at the table. */
export const LOOKS = {
  me: { bg: '#2C4A47', skin: '#F0CDA9', hair: '#2B1E16', shirt: '#E9E4D8', type: 'short' },
  top: { bg: '#3B3550', skin: '#E3B088', hair: '#7A3E22', shirt: '#F5B544', type: 'long' },
  left: { bg: '#4A3F33', skin: '#C68A5E', hair: '#231A14', shirt: '#4DA3FF', type: 'cap', cap: '#2F8F83' },
  right: { bg: '#2E3E52', skin: '#8D5A3B', hair: '#17110D', shirt: '#E9E4D8', type: 'afro' },
} satisfies Record<string, Look>;
export type LookKey = keyof typeof LOOKS;

function faceXml(a: Look) {
  const p = (d: string, c: string) => `<path d="${d}" fill="${c}"/>`;
  let back = '', front = '', extra = '';
  if (a.type === 'short') front = p('M20 27c-1-10 5-16 12-16s13 6 12 16c-2-5-6-8-12-8s-10 3-12 8z', a.hair);
  if (a.type === 'long') {
    back = p('M17 48c-2-7-2-13-2-20 0-10 7-17 17-17s17 7 17 17c0 7 0 13-2 20z', a.hair);
    front = p('M20 27c0-9 5-14 12-14s12 5 12 14c-5-2-9-6-11-9-2 4-7 8-13 9z', a.hair);
  }
  if (a.type === 'cap') front = p('M19 25c0-8 6-14 13-14s13 6 13 14z', a.cap!) + `<rect x="30" y="22" width="21" height="4" rx="2" fill="${a.cap}"/>`;
  if (a.type === 'afro') {
    back = `<circle cx="32" cy="23" r="17" fill="${a.hair}"/>`;
    extra = '<g fill="none" stroke="#0E1514" stroke-width="1.8"><circle cx="27" cy="29" r="4.4"/><circle cx="37" cy="29" r="4.4"/><path d="M31.4 29h1.2"/></g>';
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" fill="${a.bg}"/>${back}<path d="M8 66c2-13 12-19 24-19s22 6 24 19z" fill="${a.shirt}"/><rect x="28" y="38" width="8" height="10" rx="3" fill="${a.skin}"/><circle cx="20" cy="29" r="2.6" fill="${a.skin}"/><circle cx="44" cy="29" r="2.6" fill="${a.skin}"/><ellipse cx="32" cy="28" rx="12" ry="14" fill="${a.skin}"/>${front}<circle cx="27" cy="29" r="1.7" fill="#0E1514"/><circle cx="37" cy="29" r="1.7" fill="#0E1514"/><path d="M28.5 35.5q3.5 2.6 7 0" stroke="#0E1514" stroke-width="1.6" fill="none" stroke-linecap="round"/>${extra}</svg>`;
}
const XML = Object.fromEntries(Object.entries(LOOKS).map(([k, v]) => [k, faceXml(v)])) as Record<LookKey, string>;

type AvatarProps = { who: LookKey; size: number; ring: string; ringWidth?: number; padding?: number };

/** Round avatar with a team-coloured ring (3 px) and a 2 px dark gap. */
export function Avatar({ who, size, ring, ringWidth = 3, padding = 2 }: AvatarProps) {
  const inner = size - 2 * (ringWidth + padding);
  return (
    <View style={{ width: size, height: size, borderRadius: size / 2, borderWidth: ringWidth, borderColor: ring, padding, backgroundColor: colors.bg }}>
      <View style={{ width: inner, height: inner, borderRadius: inner / 2, overflow: 'hidden' }}>
        <SvgXml xml={XML[who]} width={inner} height={inner} />
      </View>
    </View>
  );
}

const TIMER_R = 24.5;
export const TIMER_LEN = 2 * Math.PI * TIMER_R;

/**
 * In-game 40 px avatar inside a 52 px box: optional pulsing ring (on turn)
 * and thin circular countdown (`timerLeft` 1 → 0).
 */
export function SeatAvatar({ who, ring, turn, timerLeft, timerColor }: { who: LookKey; ring: string; turn?: boolean; timerLeft?: number; timerColor?: string }) {
  return (
    <View style={styles.box}>
      {turn && <PulseRing size={40} color={ring} duration={1400} />}
      {timerLeft != null && (
        <Svg width={52} height={52} viewBox="0 0 52 52" style={[StyleSheet.absoluteFill, { transform: [{ rotate: '-90deg' }] }]}>
          <Circle cx={26} cy={26} r={TIMER_R} fill="none" stroke="rgba(244,241,234,.14)" strokeWidth={2.5} />
          <Circle cx={26} cy={26} r={TIMER_R} fill="none" stroke={timerColor} strokeWidth={2.5} strokeLinecap="round"
            strokeDasharray={TIMER_LEN} strokeDashoffset={TIMER_LEN * (1 - timerLeft)} />
        </Svg>
      )}
      <Avatar who={who} size={40} ring={ring} />
    </View>
  );
}

const styles = StyleSheet.create({
  box: { width: 52, height: 52, alignItems: 'center', justifyContent: 'center' },
});
