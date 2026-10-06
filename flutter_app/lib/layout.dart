import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Screen size plus the design's safe area (60 px sides, 20 px bottom), widened if the device needs more.
class BelotLayout {
  const BelotLayout({required this.w, required this.h, required this.side, required this.bottom});

  factory BelotLayout.of(BuildContext context, BoxConstraints c) {
    final pad = MediaQuery.paddingOf(context);
    return BelotLayout(
      w: c.maxWidth,
      h: c.maxHeight,
      side: math.max(kSafeSide, math.max(pad.left, pad.right)),
      bottom: math.max(kSafeBottom, pad.bottom),
    );
  }

  final double w, h;

  /// Left/right inset kept free on both sides (the notch can be on either side).
  final double side;

  /// Bottom inset for the home indicator / gesture bar.
  final double bottom;
}
