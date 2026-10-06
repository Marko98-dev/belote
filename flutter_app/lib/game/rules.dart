import 'dart:math';

import 'cards.dart';

enum Seat { me, top, left, right }

/// Prototype play order: every trick is led by Ivke (left), so "me" always plays last.
const leader = Seat.left;
const Map<Seat, Seat?> nextSeat = {Seat.left: Seat.top, Seat.top: Seat.right, Seat.right: Seat.me, Seat.me: null};
bool isTeamA(Seat s) => s == Seat.me || s == Seat.top;
const lastTrickBonus = 10;

final _rng = Random();
T pick<T>(List<T> list) => list[_rng.nextInt(list.length)];

List<PlayingCardId> sortHand(List<PlayingCardId> hand) => [...hand]
  ..sort((a, b) {
    final bySuit = handSuitOrder.indexOf(a.suit) - handSuitOrder.indexOf(b.suit);
    return bySuit != 0 ? bySuit : b.rank.plainStrength - a.rank.plainStrength;
  });

Map<Seat, List<PlayingCardId>> deal() {
  final d = fullDeck()..shuffle(_rng);
  return {
    Seat.me: sortHand(d.sublist(0, 8)),
    Seat.top: d.sublist(8, 16),
    Seat.left: d.sublist(16, 24),
    Seat.right: d.sublist(24, 32),
  };
}

/// Must follow the led suit; otherwise must trump; otherwise anything.
List<PlayingCardId> legalCards(List<PlayingCardId> hand, Suit? led, Suit? trump) {
  if (led == null) return hand;
  final follow = hand.where((c) => c.suit == led).toList();
  if (follow.isNotEmpty) return follow;
  final trumps = hand.where((c) => c.suit == trump).toList();
  return trumps.isNotEmpty ? trumps : hand;
}

Seat trickWinner(Map<Seat, PlayingCardId> trick, Suit? trump) {
  var best = leader;
  for (final seat in const [Seat.top, Seat.right, Seat.me]) {
    final c = trick[seat], b = trick[best];
    if (c == null || b == null) continue;
    if (c.suit == trump && b.suit != trump) {
      best = seat;
    } else if (c.suit == b.suit) {
      final stronger = c.suit == trump ? c.rank.trumpStrength > b.rank.trumpStrength : c.rank.plainStrength > b.rank.plainStrength;
      if (stronger) best = seat;
    }
  }
  return best;
}

int trickPoints(Map<Seat, PlayingCardId> trick, Suit? trump) => trick.values.fold(0, (n, c) => n + c.points(trump));
