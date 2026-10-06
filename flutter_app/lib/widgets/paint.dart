import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:path_drawing/path_drawing.dart';

final _pathCache = <String, Path>{};

/// Parses (and caches) SVG path data.
Path svgPath(String d) => _pathCache.putIfAbsent(d, () => parseSvgPathData(d));

/// Fills an SVG path drawn in a [viewBox]-sized coordinate space, scaled to the widget size.
class SvgPathIcon extends StatelessWidget {
  const SvgPathIcon(this.d, {super.key, required this.size, required this.color, this.viewBox = 24});
  final String d;
  final double size;
  final Color color;
  final double viewBox;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _FillPainter(svgPath(d), color, viewBox));
}

class _FillPainter extends CustomPainter {
  _FillPainter(this.path, this.color, this.viewBox);
  final Path path;
  final Color color;
  final double viewBox;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / viewBox);
    canvas.drawPath(path, Paint()..color = color..isAntiAlias = true);
  }

  @override
  bool shouldRepaint(_FillPainter old) => old.path != path || old.color != color;
}

/// Paints a CSS-style `radial-gradient(ellipse rx ry at cx cy, …)` into [bounds].
/// Centre and radii are fractions of the bounds' width/height.
void paintEllipseGradient(Canvas canvas, Rect bounds,
    {required Offset center, required Size radii, required List<Color> colors, required List<double> stops}) {
  final c = bounds.topLeft + Offset(center.dx * bounds.width, center.dy * bounds.height);
  final rx = radii.width * bounds.width, ry = radii.height * bounds.height;
  canvas.save();
  canvas.clipRect(bounds);
  canvas.translate(c.dx, c.dy);
  canvas.scale(rx, ry);
  final paint = Paint()..shader = ui.Gradient.radial(Offset.zero, 1, colors, stops);
  // Cover the whole clip in the scaled space.
  final cover = Rect.fromLTRB((bounds.left - c.dx) / rx, (bounds.top - c.dy) / ry, (bounds.right - c.dx) / rx, (bounds.bottom - c.dy) / ry);
  canvas.drawRect(cover, paint);
  canvas.restore();
}

/// Full-size elliptical radial gradient background.
class EllipseGradient extends StatelessWidget {
  const EllipseGradient({super.key, required this.center, required this.radii, required this.colors, required this.stops});
  final Offset center;
  final Size radii;
  final List<Color> colors;
  final List<double> stops;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _EllipsePainter(this), size: Size.infinite);
}

class _EllipsePainter extends CustomPainter {
  _EllipsePainter(this.w);
  final EllipseGradient w;

  @override
  void paint(Canvas canvas, Size size) =>
      paintEllipseGradient(canvas, Offset.zero & size, center: w.center, radii: w.radii, colors: w.colors, stops: w.stops);

  @override
  bool shouldRepaint(_EllipsePainter old) => false;
}

/// The game table surface: matte teal with a barely visible radial gradient.
class TableBackground extends StatelessWidget {
  const TableBackground({super.key});

  @override
  Widget build(BuildContext context) => const EllipseGradient(
        center: Offset(.5, .42),
        radii: Size(.75, .85),
        colors: [Color(0xFF175A55), Color(0xFF134E4A), Color(0xFF0F3E3A)],
        stops: [0, .55, 1],
      );
}

/// Dashed rounded rectangle outline (empty trick slot).
class DashedRRect extends StatelessWidget {
  const DashedRRect({super.key, required this.size, required this.radius, required this.color, this.strokeWidth = 1.5});
  final Size size;
  final double radius;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => CustomPaint(size: size, painter: _DashedPainter(radius, color, strokeWidth));
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.radius, this.color, this.strokeWidth);
  final double radius;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius((Offset.zero & size).deflate(strokeWidth / 2), Radius.circular(radius));
    final dashed = dashPath(Path()..addRRect(r), dashArray: CircularIntervalList([4.5, 3]));
    canvas.drawPath(dashed, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color);
  }

  @override
  bool shouldRepaint(_DashedPainter old) => false;
}
