import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../game/rules.dart';
import '../theme.dart';
import 'anim.dart';

enum _Hair { short, long, cap, afro }

class _Look {
  const _Look(this.bg, this.skin, this.hair, this.shirt, this.type, [this.cap]);
  final String bg, skin, hair, shirt;
  final _Hair type;
  final String? cap;
}

/// Flat vector faces for the four seats.
const _looks = {
  Seat.me: _Look('#2C4A47', '#F0CDA9', '#2B1E16', '#E9E4D8', _Hair.short),
  Seat.top: _Look('#3B3550', '#E3B088', '#7A3E22', '#F5B544', _Hair.long),
  Seat.left: _Look('#4A3F33', '#C68A5E', '#231A14', '#4DA3FF', _Hair.cap, '#2F8F83'),
  Seat.right: _Look('#2E3E52', '#8D5A3B', '#17110D', '#E9E4D8', _Hair.afro),
};

String _faceSvg(_Look a) {
  String p(String d, String c) => '<path d="$d" fill="$c"/>';
  var back = '', front = '', extra = '';
  switch (a.type) {
    case _Hair.short:
      front = p('M20 27c-1-10 5-16 12-16s13 6 12 16c-2-5-6-8-12-8s-10 3-12 8z', a.hair);
    case _Hair.long:
      back = p('M17 48c-2-7-2-13-2-20 0-10 7-17 17-17s17 7 17 17c0 7 0 13-2 20z', a.hair);
      front = p('M20 27c0-9 5-14 12-14s12 5 12 14c-5-2-9-6-11-9-2 4-7 8-13 9z', a.hair);
    case _Hair.cap:
      front = '${p('M19 25c0-8 6-14 13-14s13 6 13 14z', a.cap!)}<rect x="30" y="22" width="21" height="4" rx="2" fill="${a.cap}"/>';
    case _Hair.afro:
      back = '<circle cx="32" cy="23" r="17" fill="${a.hair}"/>';
      extra = '<g fill="none" stroke="#0E1514" stroke-width="1.8"><circle cx="27" cy="29" r="4.4"/><circle cx="37" cy="29" r="4.4"/><path d="M31.4 29h1.2"/></g>';
  }
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" fill="${a.bg}"/>$back'
      '<path d="M8 66c2-13 12-19 24-19s22 6 24 19z" fill="${a.shirt}"/><rect x="28" y="38" width="8" height="10" rx="3" fill="${a.skin}"/>'
      '<circle cx="20" cy="29" r="2.6" fill="${a.skin}"/><circle cx="44" cy="29" r="2.6" fill="${a.skin}"/>'
      '<ellipse cx="32" cy="28" rx="12" ry="14" fill="${a.skin}"/>$front'
      '<circle cx="27" cy="29" r="1.7" fill="#0E1514"/><circle cx="37" cy="29" r="1.7" fill="#0E1514"/>'
      '<path d="M28.5 35.5q3.5 2.6 7 0" stroke="#0E1514" stroke-width="1.6" fill="none" stroke-linecap="round"/>$extra</svg>';
}

final _svgs = {for (final e in _looks.entries) e.key: _faceSvg(e.value)};

/// Round avatar with a team-coloured ring (3 px) and a 2 px dark gap.
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.who, required this.size, required this.ring, this.ringWidth = 3});
  final Seat who;
  final double size;
  final Color ring;
  final double ringWidth;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(ringWidth + 2),
        decoration: BoxDecoration(shape: BoxShape.circle, color: BelotColors.bg, border: Border.all(color: ring, width: ringWidth)),
        child: ClipOval(child: SvgPicture.string(_svgs[who]!, fit: BoxFit.cover)),
      );
}

/// In-game 40 px avatar inside a 52 px box: optional pulsing ring (on turn)
/// and a thin circular countdown ([timerLeft] 1 → 0).
class SeatAvatar extends StatelessWidget {
  const SeatAvatar({super.key, required this.who, required this.ring, this.turn = false, this.timerLeft, this.timerColor});
  final Seat who;
  final Color ring;
  final bool turn;
  final double? timerLeft;
  final Color? timerColor;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 52,
        height: 52,
        child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
          if (turn) PulseRing(size: 40, color: ring, period: const Duration(milliseconds: 1400)),
          if (timerLeft != null) CustomPaint(size: const Size.square(52), painter: _TimerPainter(timerLeft!, timerColor!)),
          Avatar(who: who, size: 40, ring: ring),
        ]),
      );
}

class _TimerPainter extends CustomPainter {
  _TimerPainter(this.left, this.color);
  final double left;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 24.5);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawArc(rect, 0, 2 * math.pi, false, stroke..color = const Color(0x24F4F1EA));
    if (left > 0) {
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * left, false, stroke
        ..color = color
        ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_TimerPainter old) => old.left != left || old.color != color;
}
