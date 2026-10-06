import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../game/belot_controller.dart';
import '../game/rules.dart';
import '../layout.dart';
import '../theme.dart';
import '../widgets/anim.dart';
import '../widgets/avatar.dart';
import '../widgets/buttons.dart';
import '../widgets/card_back.dart';
import '../widgets/paint.dart';
import '../widgets/playing_card.dart';

/// Hand: 36 px of each card visible, gentle arc, selected card lifted 16 px.
const _handStep = 36.0;
Color _timerColor(double left) => left < .3 ? BelotColors.warning : BelotColors.accent;

/// Bidding, play and round end share the table layout.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.layout, required this.game});
  final BelotLayout layout;
  final BelotController game;

  @override
  Widget build(BuildContext context) {
    final g = game;
    final BelotLayout(:w, :h, :side, :bottom) = layout;
    final isBid = g.screen == Screen.bid;
    final isPlay = g.screen == Screen.play || g.screen == Screen.end;
    final handBottom = bottom + 12;
    final cyPlay = ((68 + (h - handBottom - cardH - 16)) / 2).roundToDouble();
    final cyBid = ((68 + (h - handBottom - cardH)) / 2).roundToDouble();
    final bp = g.bidPhase;
    final calledLabel = 'Zvao ${g.offer.suit.bosnianName}';

    return FadeIn(
      child: Stack(clipBehavior: Clip.none, children: [
        // ── Top bar ──
        Positioned(left: side + 12, top: 12, child: _ScoreBar(game: g)),
        Positioned(
          right: side, top: 8,
          child: Row(children: [
            IconChipButton(label: 'Emoji i chat', icon: BelotIcons.chat()),
            const SizedBox(width: 8),
            IconChipButton(label: 'Meni', icon: BelotIcons.menu(), onTap: g.goHome),
          ]),
        ),

        // ── Players ──
        Positioned(
          left: w / 2 - 26, top: 12,
          child: Row(children: [
            SeatAvatar(who: Seat.top, ring: BelotColors.teamA, turn: isPlay && g.turn == Seat.top),
            SizedBox(width: isBid ? 8 : 6),
            _Labels(name: 'AnaB', start: true, passed: isBid),
            if (isPlay) ...[const SizedBox(width: 8), BackWithCount(count: g.hands[Seat.top]!.length)],
          ]),
        ),
        _sideSeat(Seat.left, 'Ivke', isPlay: isPlay, turn: isPlay && g.turn == Seat.left, passed: isBid),
        _sideSeat(Seat.right, 'Luka7', isPlay: isPlay,
            turn: isBid ? bp == BidPhase.passed : g.turn == Seat.right,
            called: isBid && bp == BidPhase.luka ? calledLabel : null),
        if (isBid)
          Positioned(
            left: side + 12, top: h - handBottom - 72,
            child: Row(children: [
              SeatAvatar(who: Seat.me, ring: BelotColors.teamA, turn: bp == BidPhase.mine),
              const SizedBox(width: 8),
              _Labels(
                name: 'Marko', start: true,
                passed: bp == BidPhase.passed || bp == BidPhase.luka,
                called: bp == BidPhase.called ? calledLabel : null,
              ),
            ]),
          )
        else
          Positioned(
            left: side + 12, top: h - handBottom - 68,
            child: Column(children: [
              Countdown(
                start: g.turnStart, total: playDuration, active: g.myTurn,
                builder: (_, left) => SeatAvatar(
                  who: Seat.me, ring: BelotColors.teamA, turn: g.myTurn,
                  timerLeft: g.myTurn ? left : null, timerColor: _timerColor(left),
                ),
              ),
              const SizedBox(height: 2),
              Text('Marko', style: jakarta(12, 700, lineHeight: 14)),
            ]),
          ),

        // ── Offered trump card ──
        if (isBid)
          Positioned(
            left: w / 2 - 30, top: cyBid - 42,
            child: FadeIn(
              scale: true,
              child: PlayingCard(g.offer,
                  shadow: bp == BidPhase.called || bp == BidPhase.luka ? BelotShadows.offerCalled : BelotShadows.offer),
            ),
          ),

        // ── Trick: four slots in a cross, each next to its player ──
        if (isPlay)
          for (final (seat, x, y) in const [(Seat.top, -26.0, -74.0), (Seat.left, -88.0, -36.0), (Seat.right, 36.0, -36.0), (Seat.me, -26.0, 2.0)])
            Positioned(left: w / 2 + x, top: cyPlay + y, child: _TrickSlot(game: g, seat: seat)),

        // ── My hand ──
        Positioned(left: 0, right: 0, bottom: handBottom, height: cardH + 40, child: _Hand(game: g, centerX: w / 2)),

        if (isBid && bp == BidPhase.mine)
          Positioned(left: w / 2 + 48, bottom: handBottom + 96, width: 212, child: _BidPanel(game: g)),

        if (g.screen == Screen.end) Positioned.fill(child: _EndOverlay(game: g)),
      ]),
    );
  }

  Widget _sideSeat(Seat seat, String name, {required bool isPlay, bool turn = false, bool passed = false, String? called}) {
    final isLeft = seat == Seat.left;
    return Positioned(
      top: 0, bottom: 0,
      left: isLeft ? layout.side + 12 : null,
      right: isLeft ? null : layout.side + 12,
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        widthFactor: 1,
        child: Row(
          textDirection: !isLeft && isPlay ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              SeatAvatar(who: seat, ring: BelotColors.teamB, turn: turn),
              const SizedBox(height: 2),
              _Labels(name: name, passed: passed, called: called),
            ]),
            if (isPlay) ...[const SizedBox(width: 8), BackWithCount(count: game.hands[seat]!.length)],
          ],
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.game});
  final BelotController game;

  @override
  Widget build(BuildContext context) {
    final trump = game.trump;
    return Row(children: [
      _pill(const EdgeInsets.symmetric(horizontal: 14), [
        _score(BelotColors.teamA, 'Mi', game.scoreA),
        const SizedBox(width: 10),
        Container(width: 1, height: 16, color: const Color(0x33F4F1EA)),
        const SizedBox(width: 10),
        _score(BelotColors.teamB, 'Vi', game.scoreB),
      ]),
      const SizedBox(width: 8),
      _pill(const EdgeInsets.only(left: 8, right: 12), [
        if (trump != null)
          Container(
            width: 24, height: 24, alignment: Alignment.center,
            decoration: const BoxDecoration(color: BelotColors.cardFace, shape: BoxShape.circle),
            child: SvgPathIcon(trump.path, size: 14, color: trump.color),
          )
        else
          Stack(alignment: Alignment.center, children: [
            const DashedRRect(size: Size.square(24), radius: 12, color: Color(0x66F4F1EA)),
            Text('?', style: jakarta(12, 800, color: BelotColors.textMuted)),
          ]),
        const SizedBox(width: 8),
        Text('Runda ${game.round}', style: jakarta(12, 700, em: .04, tabular: true)),
      ]),
    ]);
  }

  static Widget _pill(EdgeInsets padding, List<Widget> children) => Container(
        height: 40,
        padding: padding,
        decoration: BoxDecoration(color: BelotColors.chip, borderRadius: BorderRadius.circular(999)),
        child: Row(children: children),
      );

  /// Each score has a fixed 3-digit width so the pill never grows into the partner's seat.
  static Widget _score(Color dot, String label, int value) => Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: jakarta(15, 600)),
        const SizedBox(width: 6),
        SizedBox(width: 28, child: Text('$value', style: jakarta(15, 800, tabular: true))),
      ]);
}

class _Labels extends StatelessWidget {
  const _Labels({required this.name, this.start = false, this.passed = false, this.called});
  final String name;
  final bool start, passed;
  final String? called;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: start ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(name, maxLines: 1, style: jakarta(12, 700, lineHeight: 14)),
          if (passed) ...[const SizedBox(height: 4), _badge('Dalje', const Color(0x990E1514), jakarta(12, 600, lineHeight: 20, color: BelotColors.textSoft))],
          if (called != null) ...[const SizedBox(height: 4), _badge(called!, BelotColors.accent, jakarta(12, 700, lineHeight: 20, color: BelotColors.onAccent))],
        ],
      );

  static Widget _badge(String text, Color bg, TextStyle style) => Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: style),
      );
}

class _TrickSlot extends StatelessWidget {
  const _TrickSlot({required this.game, required this.seat});
  final BelotController game;
  final Seat seat;

  @override
  Widget build(BuildContext context) {
    final card = game.trick[seat];
    if (card == null) return const DashedRRect(size: Size(tableW, tableH), radius: 8, color: Color(0x38F4F1EA));
    final win = game.winSeat == seat;
    final just = game.winSeat == null && game.lastSeat == seat;
    return FadeIn(
      key: ValueKey(card),
      scale: true,
      duration: const Duration(milliseconds: 200),
      child: AnimatedSlide(
        offset: Offset(0, just ? -4 / tableH : 0),
        duration: const Duration(milliseconds: 200),
        child: TableCard(card, shadow: win ? BelotShadows.cardWinner : just ? BelotShadows.cardJustPlayed : BelotShadows.cardTable),
      ),
    );
  }
}

class _Hand extends StatelessWidget {
  const _Hand({required this.game, required this.centerX});
  final BelotController game;
  final double centerX;

  @override
  Widget build(BuildContext context) {
    final hand = game.hands[Seat.me]!;
    final playable = game.playable;
    final mid = (hand.length - 1) / 2;
    final width = math.max(0, hand.length - 1) * _handStep + cardW;
    return Stack(clipBehavior: Clip.none, children: [
      for (final (i, card) in hand.indexed)
        Positioned(
          key: ValueKey(card),
          left: centerX - width / 2,
          top: 40,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            transformAlignment: Alignment.bottomCenter,
            transform: Matrix4.translationValues(i * _handStep, ((i - mid) * (i - mid) * .55).roundToDouble() + (game.selected == card ? -16 : 0), 0)
              ..rotateZ((i - mid) * 2 * math.pi / 180),
            child: GestureDetector(
              onTap: playable.contains(card) ? () => game.tapCard(card) : null,
              child: MouseRegion(
                cursor: playable.contains(card) ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: PlayingCard(
                  card,
                  dim: game.myTurn && !playable.contains(card),
                  selected: game.selected == card,
                  shadow: game.selected == card ? BelotShadows.cardHandSelected : BelotShadows.cardHand,
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

class _BidPanel extends StatelessWidget {
  const _BidPanel({required this.game});
  final BelotController game;

  @override
  Widget build(BuildContext context) => FadeIn(
        duration: const Duration(milliseconds: 250),
        child: GlassPanel(
          tint: const Color(0xB80E1514),
          blur: 16,
          child: Countdown(
            start: game.turnStart,
            total: bidDuration,
            builder: (_, left) {
              final c = _timerColor(left);
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Tvoj red', style: jakarta(15, 700, lineHeight: 20)),
                    Text('${(left * bidDuration.inSeconds).ceil()} s', style: jakarta(12, 700, color: c, tabular: true)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: PrimaryButton('Zovi adut', onTap: game.call)),
                  const SizedBox(width: 8),
                  SecondaryButton('Dalje', padding: 16, onTap: game.pass),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 4,
                    color: const Color(0x24F4F1EA),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: left,
                      child: Container(decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(999))),
                    ),
                  ),
                ),
              ]);
            },
          ),
        ),
      );
}

class _EndOverlay extends StatelessWidget {
  const _EndOverlay({required this.game});
  final BelotController game;

  @override
  Widget build(BuildContext context) {
    final g = game;
    final title = g.scoreA == g.scoreB ? 'Neriješeno' : (g.scoreA > g.scoreB ? 'Mi smo pobijedili' : 'Vi ste pobijedili');
    Widget dot(Color c) => Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
    return FadeIn(
      child: Container(
        color: const Color(0x990E1514),
        alignment: Alignment.center,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: BelotColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BelotColors.hairline),
            boxShadow: BelotShadows.panel,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('KRAJ RUNDE ${g.round}', textAlign: TextAlign.center, style: jakarta(12, 700, em: .06, color: BelotColors.textMuted)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: jakarta(24, 700, lineHeight: 28)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              dot(BelotColors.teamA), const SizedBox(width: 8),
              Text('Mi', style: jakarta(15, 600)), const SizedBox(width: 8),
              Text('${g.scoreA}', style: jakarta(24, 800, tabular: true)),
              const SizedBox(width: 16),
              Text(':', style: jakarta(15, 400, color: BelotColors.textMuted)),
              const SizedBox(width: 16),
              Text('${g.scoreB}', style: jakarta(24, 800, tabular: true)), const SizedBox(width: 8),
              Text('Vi', style: jakarta(15, 600)), const SizedBox(width: 8),
              dot(BelotColors.teamB),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              SecondaryButton('Početna', padding: 20, onTap: g.goHome),
              const SizedBox(width: 8),
              Expanded(child: PrimaryButton('Nova runda', padding: 20, onTap: () => g.startRound(g.round + 1))),
            ]),
          ]),
        ),
      ),
    );
  }
}
