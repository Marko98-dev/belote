import 'dart:math';

import 'cards.dart';
import 'rules.dart';

/// Simple hand evaluation for calling [suit] as trump: strong trumps, trump length and side aces.
double trumpValue(List<PlayingCardId> hand, Suit suit) {
  var v = 0.0;
  final trumps = hand.where((c) => c.suit == suit).toList();
  for (final c in trumps) {
    v += switch (c.rank) { Rank.jack => 3, Rank.nine => 2.2, Rank.ace => 1.4, Rank.ten => 1, _ => .5 };
  }
  v += max(0, trumps.length - 2) * .6;
  for (final c in hand.where((c) => c.suit != suit)) {
    if (c.rank == Rank.ace) v += 1;
    if (c.rank == Rank.ten && hand.contains(PlayingCardId(c.suit, Rank.ace))) v += .5;
  }
  return v;
}

Suit bestSuit(List<PlayingCardId> hand, {Suit? except}) {
  final options = Suit.values.where((s) => s != except).toList();
  options.sort((a, b) => trumpValue(hand, b).compareTo(trumpValue(hand, a)));
  return options.first;
}

/// Bot bidding: in round 1 only the offered suit can be called, in round 2 any other suit.
/// [mustCall] = dealer in round 2 ("mora").
Suit? botBid(List<PlayingCardId> hand, {required int round, required Suit offered, required bool mustCall}) {
  if (round == 1) return trumpValue(hand, offered) >= 5.5 ? offered : null;
  final s = bestSuit(hand, except: offered);
  return mustCall || trumpValue(hand, s) >= 6 ? s : null;
}

/// Bot card play: win cheaply when possible, feed points to a winning partner, otherwise throw the cheapest card.
PlayingCardId botPlay({
  required Seat seat,
  required List<PlayingCardId> hand,
  required Map<Seat, PlayingCardId> trick,
  required Seat leader,
  required Suit trump,
  required Team caller,
}) {
  final legal = legalCards(hand, trick, leader, trump);
  int pts(PlayingCardId c) => c.points(trump);
  int str(PlayingCardId c) => strength(c, trump);
  PlayingCardId minBy(List<PlayingCardId> l, int Function(PlayingCardId) f) => l.reduce((a, b) => f(b) < f(a) ? b : a);
  PlayingCardId maxBy(List<PlayingCardId> l, int Function(PlayingCardId) f) => l.reduce((a, b) => f(b) > f(a) ? b : a);

  if (trick.isEmpty) {
    final sideAces = legal.where((c) => c.suit != trump && c.rank == Rank.ace).toList();
    if (sideAces.isNotEmpty) return sideAces.first;
    final jack = PlayingCardId(trump, Rank.jack);
    if (seat.team == caller && legal.contains(jack)) return jack;
    final side = legal.where((c) => c.suit != trump).toList();
    return minBy(side.isNotEmpty ? side : legal, (c) => pts(c) * 100 + str(c));
  }

  final winner = trickWinner(trick, leader, trump);
  final lastToPlay = trick.length == 3;
  final winning = [
    for (final c in legal)
      if (trickWinner({...trick, seat: c}, leader, trump) == seat) c,
  ];

  if (winner.team == seat.team) {
    // Partner is winning: add points if nothing can overtake us any more, or if the partner's card is very strong.
    final partnerCard = trick[winner]!;
    final safe = lastToPlay || (partnerCard.suit == trump ? partnerCard.rank.trumpStrength >= 6 : partnerCard.rank == Rank.ace);
    final notOvertaking = legal.where((c) => !winning.contains(c) || c.suit != trump).toList();
    final pool = notOvertaking.isNotEmpty ? notOvertaking : legal;
    return safe ? maxBy(pool, (c) => pts(c) * 100 - str(c)) : minBy(pool, (c) => pts(c) * 100 + str(c));
  }
  if (winning.isNotEmpty) {
    // Last to play: win with the highest-point winner; otherwise win as cheaply as possible.
    return lastToPlay ? maxBy(winning, (c) => pts(c) * 100 - str(c)) : minBy(winning, (c) => str(c));
  }
  return minBy(legal, (c) => pts(c) * 100 + str(c));
}
