import 'package:flutter/widgets.dart';

import '../game/cards.dart';
import '../theme.dart';
import 'paint.dart';

/// Hand card 60×84; table card 52×72; closed card 36×50.
const cardW = 60.0, cardH = 84.0;
const tableW = 52.0, tableH = 72.0;

/// White card: large index (rank + suit) top-left so it stays readable when fanned,
/// one big suit in the middle, geometric J/Q/K glyph for face cards.
class PlayingCard extends StatelessWidget {
  const PlayingCard(this.card, {super.key, this.shadow = BelotShadows.cardHand, this.dim = false, this.selected = false});
  final PlayingCardId card;
  final List<BoxShadow> shadow;
  final bool dim;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = card.suit.color;
    final face = card.rank.face;
    return Container(
      width: cardW,
      height: cardH,
      decoration: BoxDecoration(color: BelotColors.cardFace, borderRadius: BorderRadius.circular(8), boxShadow: shadow),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(children: [
          Positioned(
            left: 3,
            top: 5,
            width: 22,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(card.rank.label, maxLines: 1, softWrap: false, overflow: TextOverflow.visible,
                  style: jakarta(19, 800, lineHeight: 19, color: color, em: -0.06)),
              const SizedBox(height: 2),
              SvgPathIcon(card.suit.path, size: 14, color: color),
            ]),
          ),
          if (face == null)
            Positioned(left: 20, top: 34, child: SvgPathIcon(card.suit.path, size: 30, color: color))
          else
            Positioned(left: 20, top: 30, child: CustomPaint(size: const Size(34, 44), painter: _FacePainter(face.path, face.suitAt, card.suit.path, color))),
          if (dim) const Positioned.fill(child: ColoredBox(color: Color(0x8C0E1514))),
          if (selected)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: BelotColors.accent, width: 2)),
              ),
            ),
        ]),
      ),
    );
  }
}

/// 52×72 card on the table: the hand card scaled from its top-left corner.
class TableCard extends StatelessWidget {
  const TableCard(this.card, {super.key, this.shadow = BelotShadows.cardTable});
  final PlayingCardId card;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: tableW,
        height: tableH,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: cardW, maxWidth: cardW, minHeight: cardH, maxHeight: cardH,
          child: Transform.scale(
            scaleX: tableW / cardW,
            scaleY: tableH / cardH,
            alignment: Alignment.topLeft,
            child: PlayingCard(card, shadow: shadow),
          ),
        ),
      );
}

class _FacePainter extends CustomPainter {
  _FacePainter(this.facePath, this.suitAt, this.suitPath, this.color);
  final String facePath;
  final Offset suitAt;
  final String suitPath;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final face = svgPath(facePath);
    canvas.drawPath(face, Paint()..color = color.withValues(alpha: .12));
    canvas.drawPath(face, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..color = color);
    canvas.translate(suitAt.dx, suitAt.dy);
    canvas.scale(.5);
    canvas.drawPath(svgPath(suitPath), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.facePath != facePath || old.suitPath != suitPath;
}
