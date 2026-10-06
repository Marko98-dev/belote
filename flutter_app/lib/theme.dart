// Design tokens from the Belot style guide (design/project/Belot Style Guide.dc.html).

import 'package:flutter/widgets.dart';

abstract final class BelotColors {
  static const appBg = Color(0xFF0A100F);
  static const bg = Color(0xFF0E1514);
  static const surface = Color(0xFF131D1C);
  static const tableLight = Color(0xFF175A55);
  static const table = Color(0xFF134E4A);
  static const tableDark = Color(0xFF0F3E3A);
  static const accent = Color(0xFFF5B544);
  static const accentHover = Color(0xFFF8C062);
  static const accentPressed = Color(0xFFD99A2B);
  static const onAccent = Color(0xFF1F1606);
  static const text = Color(0xFFF4F1EA);
  static const textMuted = Color(0xFF9AA6A2);
  static const textSoft = Color(0xFFC9D1CE);
  static const teamA = Color(0xFFFF6B5B);
  static const teamB = Color(0xFF4DA3FF);
  static const warning = Color(0xFFFF8A3D);
  static const cardFace = Color(0xFFFFFFFF);
  static const cardBackFill = Color(0xFF18221F);
  static const suitBlack = Color(0xFF1C2422);
  static const suitRed = Color(0xFFD33A3A);

  /// Translucent dark chip behind top-bar pills and icon buttons (rgba(14,21,20,.55)).
  static const chip = Color(0x8C0E1514);
  static const chipPressed = Color(0xD90E1514);
  static const outline = Color(0x5CF4F1EA); // .36
  static const outlineHover = Color(0x85F4F1EA); // .52
  static const ghostPressed = Color(0x1AF4F1EA); // .10
  static const hairline = Color(0x14F4F1EA); // .08
}

/// Box shadows. CSS blur values are used as Flutter blur radii.
abstract final class BelotShadows {
  static const _k25 = Color(0x40000000), _k20 = Color(0x33000000), _k18 = Color(0x2E000000);
  static const cardHand = [
    BoxShadow(color: _k25, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: _k20, offset: Offset(-2, 2), blurRadius: 10),
  ];
  static const cardHandSelected = [BoxShadow(color: Color(0x5C000000), offset: Offset(0, 16), blurRadius: 32)];
  static const cardTable = [
    BoxShadow(color: _k25, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: _k18, offset: Offset(0, 4), blurRadius: 10),
  ];
  static const cardHome = [
    BoxShadow(color: _k25, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x38000000), offset: Offset(0, 6), blurRadius: 16),
  ];
  static const cardJustPlayed = [
    BoxShadow(color: _k20, offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(color: Color(0x57000000), offset: Offset(0, 14), blurRadius: 28),
  ];
  static const cardWinner = [
    BoxShadow(color: BelotColors.accent, spreadRadius: 3),
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 10), blurRadius: 24),
  ];
  static const cardBack = [BoxShadow(color: Color(0x4D000000), offset: Offset(0, 2), blurRadius: 6)];
  static const offer = [
    BoxShadow(color: Color(0xBFF5B544), spreadRadius: 2),
    BoxShadow(color: Color(0x40F5B544), blurRadius: 24),
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 10), blurRadius: 24),
  ];
  static const offerCalled = [
    BoxShadow(color: BelotColors.accent, spreadRadius: 3),
    BoxShadow(color: Color(0x73F5B544), blurRadius: 32),
    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 10), blurRadius: 24),
  ];
  static const panel = [BoxShadow(color: Color(0x5C000000), offset: Offset(0, 16), blurRadius: 40)];
  static const button = [BoxShadow(color: Color(0x29000000), offset: Offset(0, 2), blurRadius: 8)];
  static const buttonLarge = [
    BoxShadow(color: Color(0x29000000), offset: Offset(0, 2), blurRadius: 8),
    BoxShadow(color: Color(0x2E000000), offset: Offset(0, 8), blurRadius: 24),
  ];
}

/// Safe area used by the design: 60 px left/right (notch on either side), 20 px bottom.
const kSafeSide = 60.0;
const kSafeBottom = 20.0;

/// Plus Jakarta Sans text style. [em] is letter spacing in em, like the CSS source.
TextStyle jakarta(double size, int weight, {double? lineHeight, Color color = BelotColors.text, double? em, bool tabular = false}) {
  return TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: size,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    height: lineHeight == null ? null : lineHeight / size,
    color: color,
    letterSpacing: em == null ? null : em * size,
    fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    decoration: TextDecoration.none,
  );
}
