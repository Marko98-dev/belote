import 'dart:math';

import 'cards.dart';

/// Seats in play order (clockwise from the bottom): me → left → top → right → me.
enum Seat {
  me('Marko'),
  left('Ivke'),
  top('AnaB'),
  right('Luka7');

  const Seat(this.nickname);
  final String nickname;

  Seat get next => Seat.values[(index + 1) % 4];
  Team get team => this == me || this == top ? Team.a : Team.b;

  /// All four seats starting with this one.
  List<Seat> get fromHere => [for (var i = 0; i < 4; i++) Seat.values[(index + i) % 4]];
}

/// Team A = me + partner (top) — "Mi". Team B = left + right — "Vi".
enum Team {
  a,
  b;

  Team get other => this == a ? b : a;
}

const lastTrickBonus = 10;
const stigljaBonus = 90;
const belaPoints = 20;

final _rng = Random();
T pick<T>(List<T> list) => list[_rng.nextInt(list.length)];

/// Trick strength of a card given the trump (trumps always beat other suits).
int strength(PlayingCardId c, Suit? trump) => c.suit == trump ? 100 + c.rank.trumpStrength : c.rank.plainStrength;

List<PlayingCardId> sortHand(List<PlayingCardId> hand, [Suit? trump]) => [...hand]
  ..sort((a, b) {
    final bySuit = handSuitOrder.indexOf(a.suit) - handSuitOrder.indexOf(b.suit);
    return bySuit != 0 ? bySuit : strength(b, trump) - strength(a, trump);
  });

/// Deals 8 cards to each seat. Returns the hands in deal order (last card of the dealer is the offered card).
Map<Seat, List<PlayingCardId>> deal() {
  final d = fullDeck()..shuffle(_rng);
  return {for (final s in Seat.values) s: d.sublist(s.index * 8, s.index * 8 + 8)};
}

/// Cards played so far in this trick, in play order.
List<PlayingCardId> playedInOrder(Map<Seat, PlayingCardId> trick, Seat leader) =>
    [for (final s in leader.fromHere) if (trick[s] != null) trick[s]!];

/// Legal cards under Bela rules:
/// follow suit and beat the best card of that suit if you can (unless the trick is already trumped);
/// without the suit you must trump, over-trumping if you can; otherwise play anything.
List<PlayingCardId> legalCards(List<PlayingCardId> hand, Map<Seat, PlayingCardId> trick, Seat leader, Suit? trump) {
  if (trick.isEmpty) return hand;
  final played = playedInOrder(trick, leader);
  final led = played.first.suit;
  final trumped = led != trump && played.any((c) => c.suit == trump);

  final follow = hand.where((c) => c.suit == led).toList();
  if (follow.isNotEmpty) {
    if (trumped) return follow;
    final best = played.where((c) => c.suit == led).map((c) => strength(c, trump)).reduce(max);
    final higher = follow.where((c) => strength(c, trump) > best).toList();
    return higher.isNotEmpty ? higher : follow;
  }
  final trumps = hand.where((c) => c.suit == trump).toList();
  if (trumps.isNotEmpty) {
    if (!trumped) return trumps;
    final best = played.where((c) => c.suit == trump).map((c) => strength(c, trump)).reduce(max);
    final higher = trumps.where((c) => strength(c, trump) > best).toList();
    return higher.isNotEmpty ? higher : trumps;
  }
  return hand;
}

Seat trickWinner(Map<Seat, PlayingCardId> trick, Seat leader, Suit? trump) {
  var best = leader;
  for (final seat in leader.fromHere.skip(1)) {
    final c = trick[seat], b = trick[best]!;
    if (c == null) continue;
    final beats = (c.suit == b.suit && strength(c, trump) > strength(b, trump)) || (c.suit == trump && b.suit != trump);
    if (beats) best = seat;
  }
  return best;
}

int trickPoints(Map<Seat, PlayingCardId> trick, Suit? trump) => trick.values.fold(0, (n, c) => n + c.points(trump));

// ── Declarations (zvanja) ─────────────────────────────────────────────────────

class Declaration {
  const Declaration(this.seat, this.points, this.label, this.topRank);
  final Seat seat;
  final int points;
  final String label;

  /// Highest card in the declaration, for breaking ties between equal declarations.
  final int topRank;
}

/// Sequences of 3+ in one suit (7 8 9 10 J Q K A) and four of a kind (J, 9, A, K, Q, 10).
List<Declaration> declarationsOf(Seat seat, List<PlayingCardId> hand) {
  final out = <Declaration>[];
  for (final suit in Suit.values) {
    final idx = hand.where((c) => c.suit == suit).map((c) => c.rank.index).toList()..sort();
    var start = 0;
    for (var i = 1; i <= idx.length; i++) {
      if (i < idx.length && idx[i] == idx[i - 1] + 1) continue;
      final len = i - start;
      if (len >= 3) {
        final pts = switch (len) { 3 => 20, 4 => 50, 8 => 1000, _ => 100 };
        out.add(Declaration(seat, pts, len == 8 ? 'Belot' : '$len u nizu', idx[i - 1]));
      }
      start = i;
    }
  }
  const quads = {Rank.jack: 200, Rank.nine: 150, Rank.ace: 100, Rank.king: 100, Rank.queen: 100, Rank.ten: 100};
  for (final MapEntry(key: rank, value: pts) in quads.entries) {
    if (hand.where((c) => c.rank == rank).length == 4) out.add(Declaration(seat, pts, '4 × ${rank.label}', rank.index));
  }
  return out;
}

/// The team with the strongest single declaration scores all of its declarations; the other team scores none.
/// Ties go to the player earlier in play order from [firstPlayer].
({Team? team, List<Declaration> winning}) resolveDeclarations(Map<Seat, List<PlayingCardId>> hands, Seat firstPlayer) {
  final all = [for (final s in firstPlayer.fromHere) ...declarationsOf(s, hands[s]!)];
  if (all.isEmpty) return (team: null, winning: const []);
  Declaration best = all.first;
  for (final d in all.skip(1)) {
    if (d.points > best.points || (d.points == best.points && d.topRank > best.topRank)) best = d;
  }
  final team = best.seat.team;
  return (team: team, winning: all.where((d) => d.seat.team == team).toList());
}

/// Seat holding both the king and queen of trump (bela), if any.
Seat? belaHolder(Map<Seat, List<PlayingCardId>> hands, Suit trump) {
  for (final s in Seat.values) {
    final h = hands[s]!;
    if (h.contains(PlayingCardId(trump, Rank.king)) && h.contains(PlayingCardId(trump, Rank.queen))) return s;
  }
  return null;
}

// ── Hand scoring ──────────────────────────────────────────────────────────────

class HandResult {
  HandResult({
    required this.caller,
    required this.cards,
    required this.declarations,
    required this.bela,
    required this.stiglja,
  }) {
    int raw(Team t) => cards[t]! + declarations[t]! + bela[t]! + stiglja[t]!;
    final rc = raw(caller), ro = raw(caller.other);
    // The calling team must score more than the other team, otherwise it falls ("pad")
    // and the other team takes every point of the hand.
    fell = rc <= ro;
    total = fell ? {caller: 0, caller.other: rc + ro} : {caller: rc, caller.other: ro};
  }

  final Team caller;
  final Map<Team, int> cards, declarations, bela, stiglja;
  late final bool fell;
  late final Map<Team, int> total;
}
