import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'bots.dart';
import 'cards.dart';
import 'rules.dart';

const bidDuration = Duration(seconds: 10);
const playDuration = Duration(seconds: 15);

enum Screen { home, bid, play, end }

enum BotSpeed {
  slow('Sporo', 1.5),
  normal('Normalno', 1),
  fast('Brzo', .55);

  const BotSpeed(this.label, this.factor);
  final String label;
  final double factor;
}

/// Bela against three bots: dealer rotation, two bidding rounds, zvanja, bela, štiglja and play to [target].
///
/// After every state change exactly one pending step is scheduled from the current state,
/// so leaving to the home screen cancels everything.
class BelotController extends ChangeNotifier {
  // ── settings ──
  int target = 1001;
  BotSpeed botSpeed = BotSpeed.normal;

  // ── match ──
  Screen screen = Screen.home;
  int scoreA = 0, scoreB = 0;
  int round = 1;

  /// Dealer of the current hand. Starts with Luka so that you bid and lead first.
  Seat dealer = Seat.right;
  HandResult? lastResult;
  Team? matchWinner;

  // ── hand ──
  Map<Seat, List<PlayingCardId>> hands = {for (final s in Seat.values) s: const []};

  /// Dealer's last card, turned face up and offered as trump in bidding round 1.
  PlayingCardId offer = const PlayingCardId(Suit.hearts, Rank.king);
  int bidRound = 1;
  Seat bidTurn = Seat.me;
  Set<Seat> passed = {};
  Seat? caller;
  Suit? trump;

  Map<Seat, PlayingCardId> trick = {};
  Seat trickLeader = Seat.me;
  Seat? turn;
  PlayingCardId? selected;
  Seat? lastSeat;
  Seat? winSeat;
  int tricksPlayed = 0;
  Map<Team, int> cardPoints = {Team.a: 0, Team.b: 0};
  Map<Team, int> tricksWon = {Team.a: 0, Team.b: 0};
  ({Team? team, List<Declaration> winning}) declarations = (team: null, winning: const []);
  Seat? belaSeat;
  bool belaAnnounced = false;

  /// Start of the current timed turn (bidding or playing).
  DateTime turnStart = DateTime.now();

  /// Emoji currently shown above a seat.
  final Map<Seat, String> reactions = {};
  final Map<Seat, Timer> _reactionTimers = {};

  Timer? _pending;

  bool get myTurn => screen == Screen.play && turn == Seat.me;
  bool get myBid => screen == Screen.bid && caller == null && bidTurn == Seat.me;

  /// Dealer must call in round 2 ("mora").
  bool get mustCall => bidRound == 2 && bidTurn == dealer;
  List<PlayingCardId> get playable => myTurn ? legalCards(hands[Seat.me]!, trick, trickLeader, trump) : const [];
  bool get matchOver => matchWinner != null;

  /// Points a seat declared that count for its team (only during the first trick are they shown).
  int declaredBy(Seat s) => declarations.winning.where((d) => d.seat == s).fold(0, (n, d) => n + d.points);

  // ── user actions ────────────────────────────────────────────────────────────

  void newMatch() {
    scoreA = scoreB = 0;
    round = 1;
    dealer = Seat.right;
    matchWinner = null;
    lastResult = null;
    _dealHand();
  }

  void nextHand() {
    if (matchOver) return newMatch();
    round++;
    dealer = dealer.next;
    _dealHand();
  }

  /// Round 1: call the offered suit. Round 2: call any other suit.
  void callTrump(Suit suit) {
    if (!myBid) return;
    _bid(Seat.me, suit);
  }

  void pass() {
    if (!myBid || mustCall) return;
    _bid(Seat.me, null);
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

  void react(Seat seat, String emoji) {
    reactions[seat] = emoji;
    _reactionTimers[seat]?.cancel();
    _reactionTimers[seat] = Timer(const Duration(milliseconds: 2500), () {
      reactions.remove(seat);
      notifyListeners();
    });
    notifyListeners();
  }

  void setTarget(int value) {
    target = value;
    notifyListeners();
  }

  void setBotSpeed(BotSpeed value) {
    botSpeed = value;
    notifyListeners();
  }

  // ── flow ────────────────────────────────────────────────────────────────────

  void _dealHand() {
    final dealt = deal();
    offer = dealt[dealer]!.last;
    hands = {for (final e in dealt.entries) e.key: e.key == Seat.me ? sortHand(e.value) : e.value};
    bidRound = 1;
    bidTurn = dealer.next;
    passed = {};
    caller = null;
    trump = null;
    trick = {};
    turn = null;
    selected = null;
    lastSeat = null;
    winSeat = null;
    tricksPlayed = 0;
    cardPoints = {Team.a: 0, Team.b: 0};
    tricksWon = {Team.a: 0, Team.b: 0};
    declarations = (team: null, winning: const []);
    belaSeat = null;
    belaAnnounced = false;
    screen = Screen.bid;
    turnStart = DateTime.now();
    _changed();
  }

  void _bid(Seat seat, Suit? suit) {
    if (suit != null) {
      caller = seat;
      trump = suit;
      hands = {...hands, Seat.me: sortHand(hands[Seat.me]!, suit)};
    } else {
      passed = {...passed, seat};
      if (seat == dealer) {
        // Everybody passed the offered suit: round 2, any other suit, dealer must call.
        bidRound = 2;
        passed = {};
      }
      bidTurn = seat.next;
    }
    turnStart = DateTime.now();
    _changed();
  }

  void _startPlay() {
    screen = Screen.play;
    declarations = resolveDeclarations(hands, dealer.next);
    belaSeat = belaHolder(hands, trump!);
    _startTrick(dealer.next);
  }

  void _startTrick(Seat leader) {
    trick = {};
    trickLeader = leader;
    turn = leader;
    selected = null;
    lastSeat = null;
    winSeat = null;
    turnStart = DateTime.now();
    _changed();
  }

  void _play(Seat seat, PlayingCardId card) {
    if (turn != seat) return;
    hands = {...hands, seat: hands[seat]!.where((c) => c != card).toList()};
    trick = {...trick, seat: card};
    if (seat == belaSeat && card.suit == trump && (card.rank == Rank.king || card.rank == Rank.queen)) belaAnnounced = true;
    lastSeat = seat;
    turn = trick.length == 4 ? null : seat.next;
    selected = null;
    turnStart = DateTime.now();
    _changed();
  }

  void _resolve() {
    final win = trickWinner(trick, trickLeader, trump);
    final pts = trickPoints(trick, trump) + (hands[Seat.me]!.isEmpty ? lastTrickBonus : 0);
    winSeat = win;
    cardPoints = {...cardPoints, win.team: cardPoints[win.team]! + pts};
    tricksWon = {...tricksWon, win.team: tricksWon[win.team]! + 1};
    // Bots sometimes react to a good trick.
    if (win != Seat.me && pts >= 20 && Random().nextDouble() < .3) react(win, pick(const ['😎', '💪', '🔥']));
    _changed();
  }

  void _finishHand() {
    final callerTeam = caller!.team;
    Map<Team, int> zero() => {Team.a: 0, Team.b: 0};
    final decl = zero();
    for (final d in declarations.winning) {
      decl[d.seat.team] = decl[d.seat.team]! + d.points;
    }
    final bela = zero();
    if (belaSeat != null) bela[belaSeat!.team] = belaPoints;
    final stiglja = zero();
    for (final t in Team.values) {
      if (tricksWon[t] == 8) stiglja[t] = stigljaBonus;
    }
    final result = HandResult(caller: callerTeam, cards: cardPoints, declarations: decl, bela: bela, stiglja: stiglja);
    lastResult = result;
    scoreA += result.total[Team.a]!;
    scoreB += result.total[Team.b]!;
    if (scoreA >= target || scoreB >= target) {
      matchWinner = scoreA == scoreB ? callerTeam : (scoreA > scoreB ? Team.a : Team.b);
    }
    screen = Screen.end;
    trick = {};
    winSeat = null;
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
    Duration bot(int ms) => Duration(milliseconds: (ms * botSpeed.factor).round());
    Duration untilTimeout(Duration limit) => turnStart.add(limit).difference(DateTime.now());

    switch (screen) {
      case Screen.home || Screen.end:
        return;
      case Screen.bid:
        if (caller != null) return after(const Duration(milliseconds: 1300), _startPlay);
        final seat = bidTurn;
        final mine = hands[seat]!;
        if (seat == Seat.me) {
          // Time out: pass, or call the best suit when you must.
          return after(untilTimeout(bidDuration), () => _bid(seat, mustCall ? bestSuit(mine, except: offer.suit) : null));
        }
        after(bot(1000), () => _bid(seat, botBid(mine, round: bidRound, offered: offer.suit, mustCall: mustCall)));
      case Screen.play:
        if (winSeat != null) {
          return after(const Duration(milliseconds: 1100), () {
            tricksPlayed++;
            hands[Seat.me]!.isEmpty ? _finishHand() : _startTrick(winSeat!);
          });
        }
        if (trick.length == 4) return after(const Duration(milliseconds: 800), _resolve);
        final seat = turn;
        if (seat == Seat.me) {
          return after(untilTimeout(playDuration), () => _play(Seat.me, botPlay(
              seat: Seat.me, hand: hands[Seat.me]!, trick: trick, leader: trickLeader, trump: trump!, caller: caller!.team)));
        }
        if (seat != null) {
          after(bot(trick.isEmpty ? 900 : 700), () => _play(seat, botPlay(
              seat: seat, hand: hands[seat]!, trick: trick, leader: trickLeader, trump: trump!, caller: caller!.team)));
        }
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    for (final t in _reactionTimers.values) {
      t.cancel();
    }
    super.dispose();
  }
}
