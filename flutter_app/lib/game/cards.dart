import 'package:flutter/painting.dart';

import '../theme.dart';

enum Suit {
  spades('S', 'pik'),
  hearts('H', 'herc'),
  diamonds('D', 'karo'),
  clubs('C', 'tref');

  const Suit(this.code, this.bosnianName);
  final String code;
  final String bosnianName;

  bool get isRed => this == hearts || this == diamonds;
  Color get color => isRed ? BelotColors.suitRed : BelotColors.suitBlack;

  /// Suit glyph in a 24×24 viewBox.
  String get path => switch (this) {
        spades => 'M12 2C9 6 4 9.5 4 13.6 4 16.3 6 18 8.4 18c1.3 0 2.5-.5 3.1-1.3L10.2 22h3.6l-1.3-5.3c.6.8 1.8 1.3 3.1 1.3 2.4 0 4.4-1.7 4.4-4.4C20 9.5 15 6 12 2z',
        hearts => 'M12 21.5C6.5 17.5 3 14 3 9.6 3 6.5 5.4 4 8.3 4c1.6 0 3 .8 3.7 2.1C12.7 4.8 14.1 4 15.7 4 18.6 4 21 6.5 21 9.6c0 4.4-3.5 7.9-9 11.9z',
        diamonds => 'M12 2l7.5 10L12 22 4.5 12z',
        clubs => 'M12 2.5a4.3 4.3 0 0 1 3.9 6.1A4.3 4.3 0 1 1 13.3 16l1 6h-4.6l1-6a4.3 4.3 0 1 1-2.6-7.4A4.3 4.3 0 0 1 12 2.5z',
      };
}

/// Display order of suits in the hand.
const handSuitOrder = [Suit.spades, Suit.hearts, Suit.clubs, Suit.diamonds];

enum Rank {
  seven('7', 0, 0),
  eight('8', 0, 0),
  nine('9', 0, 14),
  ten('10', 10, 10),
  jack('J', 2, 20),
  queen('Q', 3, 3),
  king('K', 4, 4),
  ace('A', 11, 11);

  const Rank(this.label, this.points, this.trumpPoints);
  final String label;
  final int points;
  final int trumpPoints;

  /// Trick strength, higher wins.
  int get plainStrength => const [Rank.seven, Rank.eight, Rank.nine, Rank.jack, Rank.queen, Rank.king, Rank.ten, Rank.ace].indexOf(this);
  int get trumpStrength => const [Rank.seven, Rank.eight, Rank.queen, Rank.king, Rank.ten, Rank.ace, Rank.nine, Rank.jack].indexOf(this);

  /// Geometric J/Q/K glyph (34×44 viewBox) and where the suit sits inside it.
  ({String path, Offset suitAt})? get face => switch (this) {
        jack => (path: 'M14 2h6a8 8 0 0 1 8 8v24a8 8 0 0 1-8 8h-6a8 8 0 0 1-8-8V10a8 8 0 0 1 8-8z', suitAt: const Offset(11, 16)),
        queen => (path: 'M17 6a15 15 0 1 1 0 30a15 15 0 1 1 0-30z', suitAt: const Offset(11, 15)),
        king => (path: 'M2 40V14l8 8 7-14 7 14 8-8v26z', suitAt: const Offset(11, 24)),
        _ => null,
      };
}

class PlayingCardId {
  const PlayingCardId(this.suit, this.rank);
  final Suit suit;
  final Rank rank;

  int points(Suit? trump) => suit == trump ? rank.trumpPoints : rank.points;

  @override
  bool operator ==(Object other) => other is PlayingCardId && other.suit == suit && other.rank == rank;
  @override
  int get hashCode => Object.hash(suit, rank);
  @override
  String toString() => '${suit.code}-${rank.label}';
}

List<PlayingCardId> fullDeck() => [for (final s in handSuitOrder) for (final r in Rank.values) PlayingCardId(s, r)];
