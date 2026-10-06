import 'package:belote/game/bots.dart';
import 'package:belote/game/cards.dart';
import 'package:belote/game/rules.dart';
import 'package:flutter_test/flutter_test.dart';

PlayingCardId c(Suit s, Rank r) => PlayingCardId(s, r);
const S = Suit.spades, H = Suit.hearts, D = Suit.diamonds, C = Suit.clubs;

void main() {
  test('card points: 120 without trump, 152 with trump (+10 last trick = 162)', () {
    final deck = fullDeck();
    expect(deck.toSet().length, 32);
    expect(deck.fold<int>(0, (n, x) => n + x.points(null)), 120);
    expect(deck.fold<int>(0, (n, x) => n + x.points(H)), 152);
  });

  group('legal cards', () {
    test('must follow suit and beat the best card of that suit if possible', () {
      final hand = [c(S, Rank.seven), c(S, Rank.ace), c(H, Rank.jack)];
      final trick = {Seat.left: c(S, Rank.king)};
      expect(legalCards(hand, trick, Seat.left, H), [c(S, Rank.ace)]);
    });

    test('follow with any card of the suit when you cannot beat it', () {
      final hand = [c(S, Rank.seven), c(S, Rank.eight), c(H, Rank.jack)];
      expect(legalCards(hand, {Seat.left: c(S, Rank.ace)}, Seat.left, H), [c(S, Rank.seven), c(S, Rank.eight)]);
    });

    test('no need to beat in the led suit once the trick is trumped', () {
      final hand = [c(S, Rank.seven), c(S, Rank.ace)];
      final trick = {Seat.left: c(S, Rank.king), Seat.top: c(H, Rank.seven)};
      expect(legalCards(hand, trick, Seat.left, H), hand);
    });

    test('without the suit you must trump and over-trump if you can', () {
      final hand = [c(H, Rank.eight), c(H, Rank.nine), c(D, Rank.ace)];
      final trick = {Seat.left: c(S, Rank.king), Seat.top: c(H, Rank.ace)};
      expect(legalCards(hand, trick, Seat.left, H), [c(H, Rank.nine)]);
    });

    test('must under-trump when you cannot over-trump', () {
      final hand = [c(H, Rank.eight), c(D, Rank.ace)];
      final trick = {Seat.left: c(S, Rank.king), Seat.top: c(H, Rank.jack)};
      expect(legalCards(hand, trick, Seat.left, H), [c(H, Rank.eight)]);
    });

    test('without suit and trump anything goes', () {
      final hand = [c(D, Rank.ace), c(C, Rank.seven)];
      expect(legalCards(hand, {Seat.left: c(S, Rank.king)}, Seat.left, H), hand);
    });
  });

  test('trick winner respects the leader and trump order', () {
    final trick = {
      Seat.top: c(S, Rank.ace),
      Seat.right: c(S, Rank.ten),
      Seat.me: c(H, Rank.seven),
      Seat.left: c(C, Rank.ace),
    };
    expect(trickWinner(trick, Seat.top, H), Seat.me);
    expect(trickWinner(trick, Seat.top, D), Seat.top);
    final trumps = {Seat.me: c(H, Rank.ace), Seat.left: c(H, Rank.nine), Seat.top: c(H, Rank.jack), Seat.right: c(H, Rank.ten)};
    expect(trickWinner(trumps, Seat.me, H), Seat.top);
    expect(trickPoints(trumps, H), 11 + 14 + 20 + 10);
  });

  group('declarations', () {
    test('sequences and four of a kind', () {
      final hand = [c(S, Rank.seven), c(S, Rank.eight), c(S, Rank.nine), c(S, Rank.ten), c(D, Rank.jack), c(H, Rank.jack), c(C, Rank.jack), c(S, Rank.jack)];
      final d = declarationsOf(Seat.me, hand).map((d) => d.points).toList()..sort();
      expect(d, [100, 200]); // 7-8-9-10-J of spades (5 in a row) and four jacks
    });

    test('only the team with the best declaration scores', () {
      final hands = {
        Seat.me: [c(S, Rank.seven), c(S, Rank.eight), c(S, Rank.nine)], // 20
        Seat.left: [c(D, Rank.ten), c(D, Rank.jack), c(D, Rank.queen), c(D, Rank.king)], // 50
        Seat.top: [c(C, Rank.queen), c(C, Rank.king), c(C, Rank.ace)], // 20
        Seat.right: <PlayingCardId>[],
      };
      final r = resolveDeclarations(hands, Seat.me);
      expect(r.team, Team.b);
      expect(r.winning.map((d) => d.points), [50]);
    });

    test('bela holder', () {
      final hands = {for (final s in Seat.values) s: <PlayingCardId>[]};
      hands[Seat.top] = [c(H, Rank.king), c(H, Rank.queen)];
      expect(belaHolder(hands, H), Seat.top);
      expect(belaHolder(hands, S), isNull);
    });
  });

  test('calling team falls when it does not score more than the other team', () {
    Map<Team, int> m(int a, int b) => {Team.a: a, Team.b: b};
    final pass = HandResult(caller: Team.a, cards: m(90, 72), declarations: m(20, 0), bela: m(0, 0), stiglja: m(0, 0));
    expect(pass.fell, isFalse);
    expect(pass.total, m(110, 72));
    final fall = HandResult(caller: Team.a, cards: m(70, 92), declarations: m(20, 0), bela: m(0, 0), stiglja: m(0, 0));
    expect(fall.fell, isTrue);
    expect(fall.total, m(0, 182));
  });

  test('bots always play legal cards and every hand totals 162 card points', () {
    for (var game = 0; game < 300; game++) {
      final hands = deal();
      final trump = pick(Suit.values);
      var leader = pick(Seat.values);
      final points = {Team.a: 0, Team.b: 0};
      for (var t = 0; t < 8; t++) {
        final trick = <Seat, PlayingCardId>{};
        for (final seat in leader.fromHere) {
          final card = botPlay(seat: seat, hand: hands[seat]!, trick: trick, leader: leader, trump: trump, caller: Team.a);
          expect(legalCards(hands[seat]!, trick, leader, trump), contains(card));
          hands[seat] = hands[seat]!.where((x) => x != card).toList();
          trick[seat] = card;
        }
        final win = trickWinner(trick, leader, trump);
        points[win.team] = points[win.team]! + trickPoints(trick, trump) + (t == 7 ? lastTrickBonus : 0);
        leader = win;
      }
      expect(points[Team.a]! + points[Team.b]!, 162);
    }
  });
}
