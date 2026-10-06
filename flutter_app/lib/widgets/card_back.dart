import 'package:flutter/widgets.dart';

import '../theme.dart';

const backW = 36.0, backH = 50.0;

/// Closed card (36×50): dark frame, accent outline and a dot pattern in the accent colour.
class CardBack extends StatelessWidget {
  const CardBack({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: backW,
        height: backH,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: BelotColors.bg, borderRadius: BorderRadius.circular(6), boxShadow: BelotShadows.cardBack),
        child: const CustomPaint(painter: _BackPainter()),
      );
}

class _BackPainter extends CustomPainter {
  const _BackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius((Offset.zero & size).deflate(.5), const Radius.circular(4));
    canvas.drawRRect(r, Paint()..color = BelotColors.cardBackFill);
    canvas.save();
    canvas.clipRRect(r);
    final dot = Paint()..color = BelotColors.accent;
    for (var y = 6.0; y < size.height; y += 6) {
      for (var x = 6.0; x < size.width; x += 6) {
        canvas.drawCircle(Offset(x, y), 1.1, dot);
      }
    }
    canvas.restore();
    canvas.drawRRect(r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x8CF5B544));
  }

  @override
  bool shouldRepaint(_BackPainter old) => false;
}

/// Overlapping stack of closed cards (home scene).
class BackStack extends StatelessWidget {
  const BackStack({super.key, required this.count, required this.step});
  final int count;
  final double step;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 78,
        height: backH,
        child: Stack(clipBehavior: Clip.none, children: [
          for (var i = 0; i < count; i++) Positioned(left: i * step, top: 0, child: const CardBack()),
        ]),
      );
}

/// Closed card with the number of cards left in hand.
class BackWithCount extends StatelessWidget {
  const BackWithCount({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: backW,
        height: backH,
        child: Stack(clipBehavior: Clip.none, children: [
          const CardBack(),
          Positioned(
            right: -8,
            bottom: -6,
            child: Container(
              constraints: const BoxConstraints(minWidth: 22),
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: BelotColors.text, borderRadius: BorderRadius.circular(999), boxShadow: BelotShadows.cardBack),
              child: Text('$count', style: jakarta(12, 800, lineHeight: 14, color: BelotColors.bg, tabular: true)),
            ),
          ),
        ]),
      );
}
