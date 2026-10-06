import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../game/cards.dart';
import '../game/rules.dart';
import '../layout.dart';
import '../theme.dart';
import '../widgets/anim.dart';
import '../widgets/avatar.dart';
import '../widgets/buttons.dart';
import '../widgets/card_back.dart';
import '../widgets/paint.dart';
import '../widgets/playing_card.dart';

const _homeHand = [
  PlayingCardId(Suit.hearts, Rank.ace), PlayingCardId(Suit.hearts, Rank.ten), PlayingCardId(Suit.hearts, Rank.king),
  PlayingCardId(Suit.spades, Rank.jack), PlayingCardId(Suit.spades, Rank.nine), PlayingCardId(Suit.diamonds, Rank.queen),
  PlayingCardId(Suit.diamonds, Rank.eight), PlayingCardId(Suit.clubs, Rank.ace),
];

/// Home: a dimmed "live table" scene on the left 60 % and the menu column on the right 40 %.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.layout, required this.onPlay});
  final BelotLayout layout;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final BelotLayout(:w, :h, :side, :bottom) = layout;
    final sceneW = w * .6;
    final menuW = (w * .4 - 76).roundToDouble();
    final midY = h * .47;

    return FadeIn(
      child: Stack(children: [
        const Positioned.fill(
          child: EllipseGradient(center: Offset(.3, .5), radii: Size(.8, 1.2), colors: [Color(0xFF152321), BelotColors.bg, BelotColors.bg], stops: [0, .7, 1]),
        ),

        // ── Scene ──
        Positioned(
          left: 0, top: 0, bottom: 0, width: sceneW,
          child: IgnorePointer(
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: sceneW * .04, top: h * .09, width: sceneW * .94, height: h * .79,
                child: const CustomPaint(painter: _TablePainter()),
              ),
              // Partner (top): 56 avatar + 12 gap + 78 card stack = 146 wide, centred.
              Positioned(
                left: sceneW / 2 - 73, top: 12,
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  const Avatar(who: Seat.top, size: 56, ring: BelotColors.teamA),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('AnaB', style: jakarta(12, 700)),
                    const SizedBox(height: 4),
                    const BackStack(count: 7, step: 7),
                  ]),
                ]),
              ),
              _vCenter(midY, left: side + 12, child: Row(children: [
                _named(const Avatar(who: Seat.left, size: 56, ring: BelotColors.teamB), 'Ivke'),
                const SizedBox(width: 12),
                const BackStack(count: 8, step: 6),
              ])),
              // Right opponent is on turn.
              _vCenter(midY, right: 12, child: Row(textDirection: TextDirection.rtl, children: [
                _named(
                  const SizedBox.square(
                    dimension: 56,
                    child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                      PulseRing(size: 56, color: BelotColors.teamB, period: Duration(milliseconds: 1600)),
                      Avatar(who: Seat.right, size: 56, ring: BelotColors.teamB),
                    ]),
                  ),
                  'Luka7',
                ),
                const SizedBox(width: 12),
                const BackStack(count: 7, step: 7),
              ])),
              // Two played cards.
              for (final (card, x, y, rot) in const [
                (PlayingCardId(Suit.hearts, Rank.queen), -50.0, -40.0, -9.0),
                (PlayingCardId(Suit.hearts, Rank.seven), -2.0, -34.0, 7.0),
              ])
                Positioned(
                  left: sceneW / 2 + x, top: midY + y,
                  child: Transform.rotate(angle: rot * math.pi / 180, child: TableCard(card, shadow: BelotShadows.cardHome)),
                ),
              // Me.
              Positioned(
                left: side + 12, bottom: bottom + 4,
                child: Column(children: [
                  Text('Marko', style: jakarta(12, 700)),
                  const SizedBox(height: 4),
                  const Avatar(who: Seat.me, size: 56, ring: BelotColors.teamA),
                ]),
              ),
              // My fan of 8.
              for (final (i, card) in _homeHand.indexed)
                Positioned(
                  left: sceneW / 2 + 24 - 128 + i * 28, bottom: bottom + 16,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.translationValues(0, ((i - 3.5) * (i - 3.5) * .8).roundToDouble(), 0)
                      ..rotateZ((i - 3.5) * 3 * math.pi / 180),
                    child: PlayingCard(card),
                  ),
                ),
            ]),
          ),
        ),

        // Dim the scene ~35 %, darkening to 90 % under the menu.
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x590E1514), Color(0x590E1514), Color(0xD10E1514), Color(0xE60E1514)],
                  stops: [0, .52, .66, 1],
                ),
              ),
            ),
          ),
        ),

        // Wordmark.
        Positioned(
          left: side + 12, top: 16,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Bellote', style: jakarta(24, 800, lineHeight: 28, em: -0.04)),
            const SizedBox(width: 2),
            Container(
              width: 6, height: 6, margin: const EdgeInsets.only(bottom: 7),
              decoration: const BoxDecoration(color: BelotColors.accent, shape: BoxShape.circle),
            ),
          ]),
        ),

        // Menu column.
        Positioned(
          right: side, top: 12, bottom: bottom, width: menuW,
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              _TopAction('Profil', const Avatar(who: Seat.me, size: 40, ring: BelotColors.teamA, ringWidth: 2)),
              _TopAction('Rang lista', BelotIcons.leaderboard()),
              _TopAction('Pravila', BelotIcons.rules()),
              _TopAction('Postavke', BelotIcons.settings()),
            ]),
            GlassPanel(
              tint: const Color(0x8C1B2726),
              blur: 20,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                PrimaryButton('Igraj online', height: 56, fontSize: 18, icon: BelotIcons.play(), onTap: onPlay),
                const SizedBox(height: 8),
                SecondaryButton('Igra protiv botova', onTap: onPlay),
                const SizedBox(height: 8),
                SecondaryButton('Igraj s prijateljima', onTap: onPlay),
                const SizedBox(height: 8),
                SecondaryButton('Turniri', onTap: onPlay),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  static Widget _named(Widget avatar, String name) => Column(mainAxisSize: MainAxisSize.min, children: [
        avatar,
        const SizedBox(height: 4),
        Text(name, style: jakarta(12, 700)),
      ]);

  /// Child vertically centred on [centerY].
  static Widget _vCenter(double centerY, {double? left, double? right, required Widget child}) => Positioned(
        top: centerY - 100, height: 200, left: left, right: right,
        child: Align(alignment: left != null ? Alignment.centerLeft : Alignment.centerRight, widthFactor: 1, child: child),
      );
}

/// Icon (48×48 chip) with a small label underneath.
class _TopAction extends StatelessWidget {
  const _TopAction(this.label, this.icon);
  final String label;
  final Widget icon;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Semantics(
          button: true,
          label: label,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 48, height: 48, alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0x14F4F1EA), shape: BoxShape.circle),
              child: icon,
            ),
            const SizedBox(height: 4),
            Text(label, maxLines: 1, softWrap: false, overflow: TextOverflow.visible, style: jakarta(12, 600, lineHeight: 14)),
          ]),
        ),
      );
}

/// Oval table: soft drop shadow, teal radial gradient, inner vignette, faint hairline.
class _TablePainter extends CustomPainter {
  const _TablePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final oval = Offset.zero & size;
    canvas.drawOval(oval.shift(const Offset(0, 24)), Paint()
      ..color = const Color(0x8C000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    canvas.save();
    canvas.clipPath(Path()..addOval(oval));
    paintEllipseGradient(canvas, oval,
        center: const Offset(.5, .45), radii: const Size(.71, .78),
        colors: const [Color(0xFF175A55), Color(0xFF134E4A), Color(0xFF10433F)], stops: const [0, .55, 1]);
    paintEllipseGradient(canvas, oval,
        center: const Offset(.5, .5), radii: const Size(.5, .5),
        colors: const [Color(0x00000000), Color(0x00000000), Color(0x47000000)], stops: const [0, .72, 1]);
    canvas.restore();
    canvas.drawOval(oval, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x0AF4F1EA));
  }

  @override
  bool shouldRepaint(_TablePainter old) => false;
}
