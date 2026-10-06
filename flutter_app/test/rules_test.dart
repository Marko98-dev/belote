import 'package:belote/game/cards.dart';
import 'package:belote/game/rules.dart';
import 'package:flutter_test/flutter_test.dart';

PlayingCardId c(Suit s, Rank r) => PlayingCardId(s, r);

void main() {
  test('deck has 32 cards with 152 points without trump and 162 with trump', () {
    final deck = fullDeck();
    expect(deck.toSet().length, 32);
    expect(deck.fold<int>(0, (n, x) => n + x.points(null)), 120);
    expect(deck.fold<int>(0, (n, x) => n + x.points(Suit.hearts)), 152);
  });

  test('must follow suit, otherwise trump, otherwise anything', () {
    final hand = [c(Suit.spades, Rank.ace), c(Suit.hearts, Rank.seven), c(Suit.clubs, Rank.nine)];
    expect(legalCards(hand, Suit.spades, Suit.hearts), [c(Suit.spades, Rank.ace)]);
    expect(legalCards(hand, Suit.diamonds, Suit.hearts), [c(Suit.hearts, Rank.seven)]);
    expect(legalCards(hand, Suit.diamonds, Suit.diamonds), hand);
    expect(legalCards(hand, null, Suit.hearts), hand);
  });

  test('trump beats led suit; trump jack and nine are highest', () {
    final trick = {
      Seat.left: c(Suit.spades, Rank.ace),
      Seat.top: c(Suit.spades, Rank.ten),
      Seat.right: c(Suit.hearts, Rank.seven),
      Seat.me: c(Suit.clubs, Rank.ace),
    };
    expect(trickWinner(trick, Suit.hearts), Seat.right);
    expect(trickWinner(trick, Suit.diamonds), Seat.left);

    final trumps = {
      Seat.left: c(Suit.hearts, Rank.ace),
      Seat.top: c(Suit.hearts, Rank.nine),
      Seat.right: c(Suit.hearts, Rank.jack),
      Seat.me: c(Suit.hearts, Rank.ten),
    };
    expect(trickWinner(trumps, Suit.hearts), Seat.right);
    expect(trickPoints(trumps, Suit.hearts), 11 + 14 + 20 + 10);
  });

  test('dealt hand is sorted by suit then strength', () {
    final hands = deal();
    expect(hands.values.expand((h) => h).toSet().length, 32);
    final me = hands[Seat.me]!;
    expect(sortHand(me), me);
  });
}
