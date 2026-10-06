import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';

/// Tracks hover/pressed for custom buttons (no Material ripple: the game UI is custom on both platforms).
class _Press extends StatefulWidget {
  const _Press({required this.onTap, required this.builder, this.label});
  final VoidCallback? onTap;
  final String? label;
  final Widget Function(bool pressed, bool hovered) builder;

  @override
  State<_Press> createState() => _PressState();
}

class _PressState extends State<_Press> {
  bool _pressed = false, _hovered = false;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        button: true,
        label: widget.label,
        excludeSemantics: widget.label != null,
        child: MouseRegion(
          cursor: widget.onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _pressed ? .98 : 1,
              duration: const Duration(milliseconds: 100),
              child: widget.builder(_pressed, _hovered),
            ),
          ),
        ),
      );
}

/// Filled accent pill. Pressed: darker accent, no shadow.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onTap, this.height = 48, this.fontSize = 15, this.icon, this.padding = 12});
  final String label;
  final VoidCallback? onTap;
  final double height, fontSize, padding;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => _Press(
        onTap: onTap,
        builder: (pressed, hovered) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            color: pressed ? BelotColors.accentPressed : (hovered ? BelotColors.accentHover : BelotColors.accent),
            borderRadius: BorderRadius.circular(999),
            boxShadow: pressed ? null : (height == 56 ? BelotShadows.buttonLarge : BelotShadows.button),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(label, maxLines: 1, style: jakarta(fontSize, 700, color: BelotColors.onAccent)),
          ]),
        ),
      );
}

/// Outlined pill. Pressed: faint fill.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, this.onTap, this.height = 48, this.padding = 12});
  final String label;
  final VoidCallback? onTap;
  final double height, padding;

  @override
  Widget build(BuildContext context) => _Press(
        onTap: onTap,
        builder: (pressed, hovered) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: height,
          padding: EdgeInsets.symmetric(horizontal: padding),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pressed ? BelotColors.ghostPressed : const Color(0x00000000),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: hovered ? BelotColors.outlineHover : BelotColors.outline, width: 1.5),
          ),
          child: Text(label, maxLines: 1, style: jakarta(15, 600)),
        ),
      );
}

/// 48×48 round icon button on a translucent dark chip.
class IconChipButton extends StatelessWidget {
  const IconChipButton({super.key, required this.label, required this.icon, this.onTap});
  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => _Press(
        onTap: onTap ?? () {},
        label: label,
        builder: (pressed, _) => AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: pressed ? BelotColors.chipPressed : BelotColors.chip, shape: BoxShape.circle),
          child: icon,
        ),
      );
}

/// Translucent blurred panel with a hairline border and soft shadow.
class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.tint, required this.blur, required this.child, this.padding = const EdgeInsets.all(12)});
  final Color tint;
  final double blur;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: BelotShadows.panel),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur / 2, sigmaY: blur / 2),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BelotColors.hairline),
              ),
              child: child,
            ),
          ),
        ),
      );
}

/// Stroke icons from the design (24×24, 2 px, round caps).
abstract final class BelotIcons {
  static Widget _stroke(String body) => SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#F4F1EA" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">$body</svg>',
        width: 22,
        height: 22,
      );

  static Widget play() => SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M7 4.5v15a1 1 0 0 0 1.5.86l12.5-7.5a1 1 0 0 0 0-1.72L8.5 3.64A1 1 0 0 0 7 4.5z" fill="#1F1606"/></svg>',
        width: 18,
        height: 18,
      );
  static Widget leaderboard() => _stroke('<path d="M3 20h18M5 20v-7h4v7M10 20V5h4v15M15 20v-10h4v10"/>');
  static Widget rules() => _stroke('<path d="M4 19V5a2 2 0 0 1 2-2h14v14H6a2 2 0 0 0-2 2 2 2 0 0 0 2 2h14M8 7h8M8 11h5"/>');
  static Widget settings() => _stroke(
      '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>');
  static Widget chat() => _stroke('<path d="M4 5h16v11H10l-5 4V5z"/><path d="M9 10h.01M15 10h.01M9.5 12.5q2.5 1.8 5 0"/>');
  static Widget menu() => _stroke('<path d="M4 7h16M4 12h16M4 17h16"/>');
  static Widget close() => _stroke('<path d="M6 6l12 12M18 6L6 18"/>');
}
