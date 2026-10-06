import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Fades in on first build (screenIn); with [scale] also grows .9 → 1 (cardIn).
class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child, this.duration = const Duration(milliseconds: 300), this.scale = false});
  final Widget child;
  final Duration duration;
  final bool scale;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: duration,
        curve: Curves.easeOut,
        child: child,
        builder: (context, v, child) => Opacity(
          opacity: v,
          child: scale ? Transform.scale(scale: .9 + .1 * v, child: child) : child,
        ),
      );
}

/// Ring that grows to 1.5× and fades out, looping — the "on turn" indicator.
class PulseRing extends StatefulWidget {
  const PulseRing({super.key, required this.size, required this.color, required this.period});
  final double size;
  final Color color;
  final Duration period;

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = Curves.easeOut.transform(_c.value);
            return Opacity(
              opacity: .95 * (1 - t),
              child: Transform.scale(
                scale: 1 + .5 * t,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.color, width: 3)),
                ),
              ),
            );
          },
        ),
      );
}

/// Rebuilds every frame while [active] with the fraction of time left (1 → 0) since [start].
class Countdown extends StatefulWidget {
  const Countdown({super.key, required this.start, required this.total, required this.builder, this.active = true});
  final DateTime start;
  final Duration total;
  final bool active;
  final Widget Function(BuildContext context, double left) builder;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((_) => setState(() {}));

  @override
  void initState() {
    super.initState();
    if (widget.active) _ticker.start();
  }

  @override
  void didUpdateWidget(Countdown old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ticker.isActive) _ticker.start();
    if (!widget.active && _ticker.isActive) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(widget.start).inMilliseconds;
    final left = (1 - elapsed / widget.total.inMilliseconds).clamp(0.0, 1.0);
    return widget.builder(context, left);
  }
}
