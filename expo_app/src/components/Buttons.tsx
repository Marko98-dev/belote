import { ReactNode } from 'react';
import { Pressable, StyleProp, StyleSheet, ViewStyle } from 'react-native';
import { colors, shadows } from '../theme';
import { Txt } from './Txt';

type BtnProps = {
  label: string;
  onPress?: () => void;
  height?: 48 | 56;
  fontSize?: number;
  icon?: ReactNode;
  disabled?: boolean;
  style?: StyleProp<ViewStyle>;
};

/** Filled accent pill. Pressed: darker accent, scale .98, no shadow. */
export function PrimaryButton({ label, onPress, height = 48, fontSize = 15, icon, disabled, style }: BtnProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      style={({ pressed, hovered }: { pressed: boolean; hovered?: boolean }) => [
        styles.base,
        { height, backgroundColor: pressed ? colors.accentPressed : hovered ? colors.accentHover : colors.accent },
        pressed ? styles.pressed : { boxShadow: height === 56 ? shadows.soft : '0 2px 8px rgba(0,0,0,.16)' },
        disabled && styles.disabled,
        style,
      ]}
    >
      {icon}
      <Txt size={fontSize} weight={700} color={colors.onAccent} numberOfLines={1}>{label}</Txt>
    </Pressable>
  );
}

/** Outlined pill. Pressed: faint fill, scale .98. */
export function SecondaryButton({ label, onPress, height = 48, fontSize = 15, disabled, style }: BtnProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      style={({ pressed, hovered }: { pressed: boolean; hovered?: boolean }) => [
        styles.base,
        styles.outline,
        { height, borderColor: hovered ? colors.outlineHover : colors.outline },
        pressed && [styles.pressed, { backgroundColor: colors.ghostPressed }],
        disabled && styles.disabled,
        style,
      ]}
    >
      <Txt size={fontSize} weight={600} numberOfLines={1}>{label}</Txt>
    </Pressable>
  );
}

/** 48×48 round icon button on a translucent dark chip. */
export function IconButton({ label, onPress, children }: { label: string; onPress?: () => void; children: ReactNode }) {
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={label}
      style={({ pressed }) => [styles.icon, pressed && { backgroundColor: colors.chipPressed, transform: [{ scale: 0.96 }] }]}
    >
      {children}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: { borderRadius: 999, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 8, paddingHorizontal: 12 },
  outline: { borderWidth: 1.5, backgroundColor: 'transparent' },
  pressed: { transform: [{ scale: 0.98 }] },
  disabled: { opacity: 0.4 },
  icon: { width: 48, height: 48, borderRadius: 999, backgroundColor: colors.chip, alignItems: 'center', justifyContent: 'center' },
});
