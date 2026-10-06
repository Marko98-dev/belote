import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../game/belot_controller.dart';
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
import '../widgets/sheet.dart';

/// Hand: 36 px of each card visible, gentle arc, selected card lifted 16 px.
const _handStep = 36.0;
const _emojis = ['👍', '😂', '😮', '😎', '🙏', '🔥'];
Color _timerColor(double left) => left < .3 ? BelotColors.warning : BelotColors.accent;

/// Bidding, play and the end of a hand share the table layout.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.layout, required this.game});
  final BelotLayout layout;
  final BelotController game;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _emojiOpen = false, _leaveOpen = false;

  BelotController get g => widget.game;

  @override
  Widget build(BuildContext context) {
    final BelotLayout(:w, :h, :side, :bottom) = widget.layout;
    final isBid = g.screen == Screen.bid;
    final isPlay = g.screen == Screen.play || g.screen == Screen.end;
    final handBottom = bottom + 12;
    final cyPlay = ((68 + (h - handBottom - cardH - 16)) / 2).roundToDouble();
    final cyBid = ((68 + (h - handBottom - cardH)) / 2).roundToDouble();

    return FadeIn(
      child: Stack(clipBehavior: Clip.none, children: [
        // ── Top bar ──
        Positioned(left: side + 12, top: 12, child: _ScoreBar(game: g)),
        Positioned(
          right: side, top: 8,
          child: Row(children: [
            IconChipButton(label: 'Emoji i chat', icon: BelotIcons.chat(), onTap: () => setState(() => _emojiOpen = !_emojiOpen)),
            const SizedBox(width: 8),
            IconChipButton(label: 'Meni', icon: BelotIcons.menu(), onTap: () => setState(() => _leaveOpen = true)),
          ]),
        ),

        // ── Players ──
        Positioned(
          left: w / 2 - 26, top: 12,
          child: Row(children: [
            _avatar(Seat.top),
            SizedBox(width: isBid ? 8 : 6),
            _Labels(name: Seat.top.nickname, start: true, badge: _badge(Seat.top)),
            if (isPlay) ...[const SizedBox(width: 8), BackWithCount(count: g.hands[Seat.top]!.length)],
          ]),
        ),
        _sideSeat(Seat.left, isPlay: isPlay),
        _sideSeat(Seat.right, isPlay: isPlay),
        Positioned(
          left: side + 12, top: h - handBottom - (isBid ? 72 : 68),
          child: isBid
              ? Row(children: [
                  _avatar(Seat.me),
                  const SizedBox(width: 8),
                  _Labels(name: Seat.me.nickname, start: true, badge: _badge(Seat.me)),
                ])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(children: [
                    Countdown(
                      start: g.turnStart, total: playDuration, active: g.myTurn,
                      builder: (_, left) => _avatar(Seat.me, timerLeft: g.myTurn ? left : null, timerColor: _timerColor(left)),
                    ),
                    const SizedBox(height: 2),
                    Text(Seat.me.nickname, style: jakarta(12, 700, lineHeight: 14)),
                  ]),
                  if (_badge(Seat.me) case final b?) ...[const SizedBox(width: 8), Padding(padding: const EdgeInsets.only(top: 16), child: b)],
                ]),
        ),

        // ── Offered trump card (dimmed in round 2, when it can no longer be called; hidden behind my suit panel) ──
        if (isBid && !(g.myBid && g.bidRound == 2))
          Positioned(
            left: w / 2 - 30, top: cyBid - 42,
            child: FadeIn(
              scale: true,
              child: AnimatedOpacity(
                opacity: g.bidRound == 2 && g.caller == null ? .35 : 1,
                duration: const Duration(milliseconds: 250),
                child: PlayingCard(
                  g.offer,
                  shadow: g.caller != null && g.trump == g.offer.suit ? BelotShadows.offerCalled : BelotShadows.offer,
                ),
              ),
            ),
          ),

        // ── Trick: four slots in a cross, each next to its player ──
        if (isPlay)
          for (final (seat, x, y) in const [(Seat.top, -26.0, -74.0), (Seat.left, -88.0, -36.0), (Seat.right, 36.0, -36.0), (Seat.me, -26.0, 2.0)])
            Positioned(left: w / 2 + x, top: cyPlay + y, child: _TrickSlot(game: g, seat: seat)),

        // ── My hand ──
        Positioned(left: 0, right: 0, bottom: handBottom, height: cardH + 40, child: _Hand(game: g, centerX: w / 2)),

        if (g.myBid && g.bidRound == 1)
          Positioned(left: w / 2 + 48, bottom: handBottom + 96, width: 212, child: _OfferPanel(game: g)),
        if (g.myBid && g.bidRound == 2)
          Positioned(left: w / 2 - 134, bottom: handBottom + 96, width: 268, child: _SuitPanel(game: g)),

        if (_emojiOpen)
          Positioned(
            right: side, top: 64,
            child: FadeIn(
              duration: const Duration(milliseconds: 150),
              child: GlassPanel(
                tint: const Color(0xB80E1514),
                blur: 16,
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  for (final e in _emojis)
                    GestureDetector(
                      onTap: () {
                        g.react(Seat.me, e);
                        setState(() => _emojiOpen = false);
                      },
                      child: SizedBox.square(dimension: 48, child: Center(child: Text(e, style: const TextStyle(fontSize: 26)))),
                    ),
                ]),
              ),
            ),
          ),

        if (g.screen == Screen.end) Positioned.fill(child: _EndOverlay(game: g)),

        if (_leaveOpen)
          Positioned.fill(
            child: BelotSheet(
              title: 'Napusti igru?',
              width: 320,
              onClose: () => setState(() => _leaveOpen = false),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
                Text('Rezultat ove igre se neće sačuvati.', style: jakarta(15, 400, lineHeight: 22, color: BelotColors.textSoft)),
                const SizedBox(height: 16),
                Row(children: [
                  SecondaryButton('Ostani', padding: 20, onTap: () => setState(() => _leaveOpen = false)),
                  const SizedBox(width: 8),
                  Expanded(child: PrimaryButton('Napusti', onTap: g.goHome)),
                ]),
              ]),
            ),
          ),
      ]),
    );
  }

  Widget _avatar(Seat seat, {double? timerLeft, Color? timerColor}) {
    final onTurn = switch (g.screen) {
      Screen.bid => g.caller == null && g.bidTurn == seat,
      Screen.play => g.turn == seat,
      _ => false,
    };
    return SeatAvatar(
      who: seat,
      ring: seat.team == Team.a ? BelotColors.teamA : BelotColors.teamB,
      turn: onTurn,
      timerLeft: timerLeft,
      timerColor: timerColor,
      reaction: g.reactions[seat],
    );
  }

  /// One status badge per seat: bidding (called / passed / dealer), then bela, declarations and the caller.
  Widget? _badge(Seat seat) {
    final trumpName = g.trump?.bosnianName ?? '';
    if (g.screen == Screen.bid) {
      if (g.caller == seat) return _Badge.accent('Zvao $trumpName');
      if (g.passed.contains(seat)) return const _Badge.dark('Dalje');
      if (g.dealer == seat) return const _Badge.dark('Dijeli');
      return null;
    }
    if (g.screen != Screen.play) return null;
    // "Bela" shows while the holder's trump king or queen is on the table.
    final onTable = g.trick[seat];
    if (g.belaSeat == seat && onTable != null && onTable.suit == g.trump && (onTable.rank == Rank.king || onTable.rank == Rank.queen)) {
      return const _Badge.accent('Bela');
    }
    if (g.tricksPlayed == 0 && g.declaredBy(seat) > 0) return _Badge.accent('Zvanje ${g.declaredBy(seat)}');
    if (g.caller == seat) return _Badge.dark('Zvao $trumpName');
    return null;
  }

  Widget _sideSeat(Seat seat, {required bool isPlay}) {
    final isLeft = seat == Seat.left;
    final side = widget.layout.side + 12;
    return Positioned(
      top: 0, bottom: 0,
      left: isLeft ? side : null,
      right: isLeft ? null : side,
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        widthFactor: 1,
        child: Row(
          textDirection: !isLeft && isPlay ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              _avatar(seat),
              const SizedBox(height: 2),
              _Labels(name: seat.nickname, badge: _badge(seat)),
            ]),
            if (isPlay) ...[const SizedBox(width: 8), BackWithCount(count: g.hands[seat]!.length)],
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
  /// A 4-digit score only appears when the match ends, under the summary overlay.
  static Widget _score(Color dot, String label, int value) => Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: jakarta(15, 600)),
        const SizedBox(width: 6),
        SizedBox(width: value >= 1000 ? 38 : 28, child: Text('$value', style: jakarta(15, 800, tabular: true))),
      ]);
}

class _Badge extends StatelessWidget {
  const _Badge.dark(this.text) : accent = false;
  const _Badge.accent(this.text) : accent = true;
  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) => Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: accent ? BelotColors.accent : const Color(0x990E1514), borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: jakarta(12, accent ? 700 : 600, lineHeight: 20, color: accent ? BelotColors.onAccent : BelotColors.textSoft)),
      );
}

class _Labels extends StatelessWidget {
  const _Labels({required this.name, this.start = false, this.badge});
  final String name;
  final bool start;
  final Widget? badge;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: start ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(name, maxLines: 1, style: jakarta(12, 700, lineHeight: 14)),
          if (badge != null) ...[const SizedBox(height: 4), badge!],
        ],
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

/// Header + countdown bar shared by both bidding panels.
class _BidPanelFrame extends StatelessWidget {
  const _BidPanelFrame({required this.game, required this.title, required this.actions, this.titleSuffix});
  final BelotController game;
  final String title;
  final Widget actions;
  final Widget? titleSuffix;

  @override
  Widget build(BuildContext context) => FadeIn(
        key: ValueKey(game.bidRound),
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
                Row(children: [
                  Text(title, style: jakarta(15, 700, lineHeight: 20)),
                  if (titleSuffix != null) ...[const SizedBox(width: 8), titleSuffix!],
                  const Spacer(),
                  Text('${(left * bidDuration.inSeconds).ceil()} s', style: jakarta(12, 700, color: c, tabular: true)),
                ]),
                const SizedBox(height: 8),
                actions,
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

/// Round 1: call the offered suit or pass.
class _OfferPanel extends StatelessWidget {
  const _OfferPanel({required this.game});
  final BelotController game;

  @override
  Widget build(BuildContext context) {
    final suit = game.offer.suit;
    return _BidPanelFrame(
      game: game,
      title: 'Tvoj red',
      titleSuffix: Container(
        height: 20,
        padding: const EdgeInsets.only(left: 3, right: 8),
        decoration: BoxDecoration(color: BelotColors.cardFace, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          SvgPathIcon(suit.path, size: 14, color: suit.color),
          const SizedBox(width: 3),
          Text(suit.bosnianName, style: jakarta(12, 700, lineHeight: 20, color: BelotColors.suitBlack)),
        ]),
      ),
      actions: Row(children: [
        Expanded(child: PrimaryButton('Zovi adut', onTap: () => game.callTrump(suit))),
        const SizedBox(width: 8),
        SecondaryButton('Dalje', padding: 16, onTap: game.pass),
      ]),
    );
  }
}

/// Round 2: call any other suit; the dealer must call ("mora").
class _SuitPanel extends StatelessWidget {
  const _SuitPanel({required this.game});
  final BelotController game;

  @override
  Widget build(BuildContext context) => _BidPanelFrame(
        game: game,
        title: game.mustCall ? 'Moraš zvati adut' : 'Biraj adut',
        actions: Row(children: [
          for (final s in Suit.values.where((s) => s != game.offer.suit)) ...[
            _SuitButton(suit: s, onTap: () => game.callTrump(s)),
            const SizedBox(width: 8),
          ],
          const Spacer(),
          if (!game.mustCall) SecondaryButton('Dalje', padding: 16, onTap: game.pass),
        ]),
      );
}

class _SuitButton extends StatefulWidget {
  const _SuitButton({required this.suit, required this.onTap});
  final Suit suit;
  final VoidCallback onTap;

  @override
  State<_SuitButton> createState() => _SuitButtonState();
}

class _SuitButtonState extends State<_SuitButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => Semantics(
        container: true,
        button: true,
        label: 'Zovi ${widget.suit.bosnianName}',
        excludeSemantics: true,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapUp: (_) => setState(() => _down = false),
          onTapCancel: () => setState(() => _down = false),
          onTap: widget.onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedScale(
              scale: _down ? .96 : 1,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: 48, height: 48, alignment: Alignment.center,
                decoration: BoxDecoration(color: _down ? const Color(0xFFE9E4D8) : BelotColors.cardFace, shape: BoxShape.circle, boxShadow: BelotShadows.button),
                child: SvgPathIcon(widget.suit.path, size: 24, color: widget.suit.color),
              ),
            ),
          ),
        ),
      );
}

/// End of a hand: points breakdown, pass/fall, match totals; at the end of the match the winner.
class _EndOverlay extends StatelessWidget {
  const _EndOverlay({required this.game});
  final BelotController game;

  @override
  Widget build(BuildContext context) {
    final g = game;
    final r = g.lastResult!;
    final weCalled = r.caller == Team.a;
    final title = g.matchOver
        ? (g.matchWinner == Team.a ? 'Pobijedili smo!' : 'Izgubili smo')
        : switch ((weCalled, r.fell)) {
            (true, false) => 'Prošli smo',
            (true, true) => 'Pali smo',
            (false, false) => 'Prošli su',
            (false, true) => 'Pali su',
          };
    final eyebrow = g.matchOver ? 'Kraj igre · do ${g.target}' : 'Kraj runde ${g.round}';
    TextStyle cell([int w = 600, Color c = BelotColors.text]) => jakarta(13, w, lineHeight: 20, color: c, tabular: true);
    TableRow row(String label, int a, int b, {bool strong = false}) => TableRow(children: [
          Text(label, style: cell(strong ? 700 : 500, strong ? BelotColors.text : BelotColors.textSoft)),
          Text('$a', textAlign: TextAlign.right, style: cell(strong ? 800 : 600)),
          Text('$b', textAlign: TextAlign.right, style: cell(strong ? 800 : 600)),
        ]);
    Widget dot(Color c) => Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

    return FadeIn(
      child: Container(
        color: const Color(0x990E1514),
        alignment: Alignment.center,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BelotColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BelotColors.hairline),
            boxShadow: BelotShadows.panel,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(eyebrow.toUpperCase(), textAlign: TextAlign.center, style: jakarta(12, 700, em: .06, color: BelotColors.textMuted)),
            const SizedBox(height: 2),
            Text(title, textAlign: TextAlign.center, style: jakarta(24, 700, lineHeight: 28)),
            const SizedBox(height: 10),
            Table(
              columnWidths: const {0: FlexColumnWidth(), 1: FixedColumnWidth(56), 2: FixedColumnWidth(56)},
              children: [
                TableRow(children: [
                  const SizedBox(),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [dot(BelotColors.teamA), const SizedBox(width: 6), Text('Mi', style: cell(700))]),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [dot(BelotColors.teamB), const SizedBox(width: 6), Text('Vi', style: cell(700))]),
                ]),
                row('Karte', r.cards[Team.a]!, r.cards[Team.b]!),
                row('Zvanja', r.declarations[Team.a]!, r.declarations[Team.b]!),
                row('Bela i štiglja', r.bela[Team.a]! + r.stiglja[Team.a]!, r.bela[Team.b]! + r.stiglja[Team.b]!),
                row(r.fell ? 'Runda (pad)' : 'Runda', r.total[Team.a]!, r.total[Team.b]!, strong: true),
              ],
            ),
            Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 8), color: BelotColors.hairline),
            Row(children: [
              Expanded(child: Text('Ukupno', style: jakarta(15, 700))),
              SizedBox(width: 56, child: Text('${g.scoreA}', textAlign: TextAlign.right, style: jakarta(18, 800, tabular: true))),
              SizedBox(width: 56, child: Text('${g.scoreB}', textAlign: TextAlign.right, style: jakarta(18, 800, tabular: true))),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              SecondaryButton('Početna', padding: 20, onTap: g.goHome),
              const SizedBox(width: 8),
              Expanded(child: PrimaryButton(g.matchOver ? 'Nova igra' : 'Sljedeća runda', padding: 16, onTap: g.nextHand)),
            ]),
          ]),
        ),
      ),
    );
  }
}
