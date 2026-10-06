import { Text, TextProps, TextStyle } from 'react-native';
import { Weight, colors, font } from '../theme';

type Props = TextProps & {
  size?: number;
  weight?: Weight;
  lineHeight?: number;
  color?: string;
  /** Letter spacing in em, like the CSS source. */
  em?: number;
  tabular?: boolean;
};

/** Plus Jakarta Sans text. Maps a numeric weight to the matching font family. */
export function Txt({ size = 15, weight = 400, lineHeight, color = colors.text, em, tabular, style, ...rest }: Props) {
  const s: TextStyle = {
    fontFamily: font[weight],
    fontSize: size,
    color,
    ...(lineHeight != null && { lineHeight }),
    ...(em != null && { letterSpacing: em * size }),
    ...(tabular && { fontVariant: ['tabular-nums'] }),
  };
  return <Text allowFontScaling={false} {...rest} style={[s, style]} />;
}
