import 'dart:async';

import 'package:flutter/foundation.dart';

import 'cards.dart';
import 'rules.dart';

const bidDuration = Duration(seconds: 10);
const playDuration = Duration(seconds: 15);

enum Screen { home, bid, play, end }

/// mine: my turn to bid · called: I called · passed: I passed, Luka is deciding · luka: Luka called.
enum BidPhase { mine, called, passed, luka }

/// Prototype game flow: home → trump bidding → 8 tricks → round end.
///
/// Bots (partner + opponents) play random legal cards. After every state change exactly one
/// pending step is scheduled from the current state, so leaving to home cancels everything.
class BelotController extends ChangeNotifier {
  Screen screen = Screen.home;
  Map<Seat, List<PlayingCardId>> hands = {for (final s in Seat.values) s: const []};
  PlayingCardId offer = const PlayingCardId(Suit.hearts, Rank.king);
  Suit? trump;
  BidPhase bidPhase = BidPhase.mine;
  Map<Seat, PlayingCardId> trick = {};
  Seat? turn;
  PlayingCardId? selected;
  Seat? lastSeat;
  Seat? winSeat;
  int scoreA = 0, scoreB = 0, round = 1;

  /// Start of the current timed turn.
  DateTime turnStart = DateTime.now();

  Timer? _pending;

  Suit? get ledSuit => trick[leader]?.suit;
  bool get myTurn => screen == Screen.play && turn == Seat.me;
  List<PlayingCardId> get playable => myTurn ? legalCards(hands[Seat.me]!, ledSuit, trump) : const [];

  // ── user actions ────────────────────────────────────────────────────────────

  void startRound(int round) {
    final dealt = deal();
    hands = dealt;
    // Prototype simplification: the offered trump card comes from Luka's hand.
    offer = pick(dealt[Seat.right]!);
    trump = null;
    bidPhase = BidPhase.mine;
    trick = {};
    turn = null;
    selected = null;
    lastSeat = null;
    winSeat = null;
    scoreA = 0;
    scoreB = 0;
    this.round = round;
    screen = Screen.bid;
    turnStart = DateTime.now();
    _changed();
  }

  void call() {
    if (screen != Screen.bid || bidPhase != BidPhase.mine) return;
    bidPhase = BidPhase.called;
    trump = offer.suit;
    _changed();
  }

  void pass() {
    if (screen != Screen.bid || bidPhase != BidPhase.mine) return;
    bidPhase = BidPhase.passed;
    _changed();
  }

  /// First tap selects (lifts) a playable card, second tap plays it.
  void tapCard(PlayingCardId card) {
    if (!playable.contains(card)) return;
    if (selected == card) {
      _play(Seat.me, card);
    } else {
      selected = card;
      _changed();
    }
  }

  void goHome() {
    screen = Screen.home;
    turn = null;
    _changed();
  }

  // ── flow ────────────────────────────────────────────────────────────────────

  void _play(Seat seat, PlayingCardId card) {
    if (turn != seat) return;
    hands = {...hands, seat: hands[seat]!.where((c) => c != card).toList()};
    trick = {...trick, seat: card};
    lastSeat = seat;
    turn = nextSeat[seat];
    selected = null;
    turnStart = DateTime.now();
    _changed();
  }

  void _startTrick() {
    screen = Screen.play;
    trick = {};
    turn = leader;
    selected = null;
    lastSeat = null;
    winSeat = null;
    _changed();
  }

  void _resolve() {
    final win = trickWinner(trick, trump);
    final pts = trickPoints(trick, trump) + (hands[Seat.me]!.isEmpty ? lastTrickBonus : 0);
    winSeat = win;
    if (isTeamA(win)) {
      scoreA += pts;
    } else {
      scoreB += pts;
    }
    _changed();
  }

  void _changed() {
    notifyListeners();
    _schedule();
  }

  void _schedule() {
    _pending?.cancel();
    _pending = null;
    void after(Duration d, VoidCallback fn) => _pending = Timer(d.isNegative ? Duration.zero : d, fn);
    Duration untilTimeout(Duration limit) => turnStart.add(limit).difference(DateTime.now());

    switch (screen) {
      case Screen.home || Screen.end:
        return;
      case Screen.bid:
        switch (bidPhase) {
          case BidPhase.mine:
            after(untilTimeout(bidDuration), pass);
          case BidPhase.called:
            after(const Duration(milliseconds: 1300), _startTrick);
          case BidPhase.passed:
            after(const Duration(milliseconds: 1400), () {
              bidPhase = BidPhase.luka;
              trump = offer.suit;
              _changed();
            });
          case BidPhase.luka:
            after(const Duration(milliseconds: 1300), _startTrick);
        }
      case Screen.play:
        if (winSeat != null) {
          after(const Duration(milliseconds: 1100), () {
            if (hands[Seat.me]!.isEmpty) {
              screen = Screen.end;
              trick = {};
              winSeat = null;
              _changed();
            } else {
              _startTrick();
            }
          });
        } else if (trick.length == 4) {
          after(const Duration(milliseconds: 800), _resolve);
        } else if (turn == Seat.me) {
          after(untilTimeout(playDuration), () => _play(Seat.me, pick(playable)));
        } else if (turn != null) {
          final seat = turn!;
          after(Duration(milliseconds: seat == leader ? 800 : 650), () {
            _play(seat, pick(legalCards(hands[seat]!, ledSuit, trump)));
          });
        }
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }
}
