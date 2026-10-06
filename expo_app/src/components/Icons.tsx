import Svg, { Circle, Path } from 'react-native-svg';
import { colors } from '../theme';

const stroke = { fill: 'none', stroke: colors.text, strokeWidth: 2, strokeLinecap: 'round', strokeLinejoin: 'round' } as const;

export const PlayIcon = () => (
  <Svg width={18} height={18} viewBox="0 0 24 24">
    <Path d="M7 4.5v15a1 1 0 0 0 1.5.86l12.5-7.5a1 1 0 0 0 0-1.72L8.5 3.64A1 1 0 0 0 7 4.5z" fill={colors.onAccent} />
  </Svg>
);

export const LeaderboardIcon = () => (
  <Svg width={22} height={22} viewBox="0 0 24 24"><Path {...stroke} d="M3 20h18M5 20v-7h4v7M10 20V5h4v15M15 20v-10h4v10" /></Svg>
);

export const RulesIcon = () => (
  <Svg width={22} height={22} viewBox="0 0 24 24"><Path {...stroke} d="M4 19V5a2 2 0 0 1 2-2h14v14H6a2 2 0 0 0-2 2 2 2 0 0 0 2 2h14M8 7h8M8 11h5" /></Svg>
);

export const SettingsIcon = () => (
  <Svg width={22} height={22} viewBox="0 0 24 24">
    <Circle {...stroke} cx={12} cy={12} r={3} />
    <Path {...stroke} d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
  </Svg>
);

export const ChatIcon = () => (
  <Svg width={22} height={22} viewBox="0 0 24 24">
    <Path {...stroke} d="M4 5h16v11H10l-5 4V5z" />
    <Path {...stroke} d="M9 10h.01M15 10h.01M9.5 12.5q2.5 1.8 5 0" />
  </Svg>
);

export const MenuIcon = () => (
  <Svg width={22} height={22} viewBox="0 0 24 24"><Path {...stroke} d="M4 7h16M4 12h16M4 17h16" /></Svg>
);
