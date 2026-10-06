import 'dart:io';

import 'package:belote/game/belot_controller.dart';
import 'package:belote/game/bots.dart';
import 'package:belote/game/rules.dart';
import 'package:belote/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _phone(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Widget tests render with a placeholder font unless real fonts are loaded.
Future<void> _loadFonts() async {
  final loader = FontLoader('PlusJakartaSans');
  for (final f in Directory('assets/fonts').listSync().whereType<File>().where((f) => f.path.endsWith('.ttf'))) {
    loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
  }
  await loader.load();
}

/// Finds a widget by its Semantics label (icon buttons, suit buttons).
Finder _label(Pattern label) => find.byWidgetPredicate((w) {
      final l = w is Semantics ? w.properties.label : null;
      return l != null && (label is RegExp ? label.hasMatch(l) : l == label);
    });

BelotController _game(WidgetTester tester) => (tester.state(find.byType(BelotApp)) as dynamic).game as BelotController;

/// Plays until the hand ends: I pass when I may (or call when I must) and play my first legal card.
Future<void> _playHand(WidgetTester tester, BelotController game) async {
  for (var i = 0; i < 600 && game.screen != Screen.end; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (game.myBid) {
      expect(find.text(game.mustCall ? 'Moraš zvati adut' : (game.bidRound == 1 ? 'Tvoj red' : 'Biraj adut')), findsOneWidget);
      game.mustCall ? game.callTrump(bestSuit(game.hands[Seat.me]!, except: game.offer.suit)) : game.pass();
    } else if (game.myTurn) {
      final card = game.playable.first;
      game.tapCard(card);
      game.tapCard(card);
    }
  }
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUpAll(_loadFonts);

  for (final (name, size) in const [('iPhone', Size(852, 393)), ('Android', Size(800, 360))]) {
    testWidgets('$name: home sheets, a full hand and the summary without layout overflow', (tester) async {
      await _phone(tester, size);
      await tester.pumpWidget(const BelotApp());
      await tester.pump(const Duration(milliseconds: 400));

      // Rules and settings open and close.
      await tester.tap(find.text('Pravila'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('PROLAZ I PAD'), findsOneWidget);
      await tester.tap(_label('Zatvori'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Postavke'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('501'));
      await tester.tap(find.text('Brzo'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_game(tester).target, 501);
      await tester.tap(_label('Zatvori'));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Igra protiv botova'));
      await tester.pump(const Duration(milliseconds: 400));
      final game = _game(tester);
      expect(game.screen, Screen.bid);
      expect(find.text('Tvoj red'), findsOneWidget);

      await _playHand(tester, game);
      expect(game.screen, Screen.end);
      expect(game.hands[Seat.me], isEmpty);
      final r = game.lastResult!;
      expect(r.cards[Team.a]! + r.cards[Team.b]!, 162);
      expect(game.scoreA + game.scoreB, r.total[Team.a]! + r.total[Team.b]!);
      expect(find.text('Ukupno'), findsOneWidget);

      // Next hand: the dealer moves on.
      final dealer = game.dealer;
      await tester.tap(find.text(game.matchOver ? 'Nova igra' : 'Sljedeća runda'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(game.dealer, game.matchOver ? Seat.right : dealer.next);

      // Leaving asks for confirmation.
      await tester.tap(_label('Meni'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Napusti igru?'), findsOneWidget);
      await tester.tap(find.text('Napusti'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(game.screen, Screen.home);
    });
  }

  testWidgets('a whole match to 501 ends with a winner', (tester) async {
    await _phone(tester, const Size(852, 393));
    await tester.pumpWidget(const BelotApp());
    await tester.pump(const Duration(milliseconds: 400));
    final game = _game(tester)
      ..setTarget(501)
      ..setBotSpeed(BotSpeed.fast)
      ..newMatch();
    for (var hand = 0; hand < 30 && !game.matchOver; hand++) {
      await _playHand(tester, game);
      if (!game.matchOver) {
        game.nextHand();
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    expect(game.matchOver, isTrue);
    expect(game.scoreA >= 501 || game.scoreB >= 501, isTrue);
    expect(find.text('Nova igra'), findsOneWidget);
  });
}
