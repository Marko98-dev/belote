import 'dart:io';

import 'package:belote/game/belot_controller.dart';
import 'package:belote/game/rules.dart';
import 'package:belote/main.dart';
import 'package:flutter/services.dart';
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

void main() {
  setUpAll(_loadFonts);

  for (final (name, size) in const [('iPhone', Size(852, 393)), ('Android', Size(800, 360))]) {
    testWidgets('$name: home → bid → play a full round without layout overflow', (tester) async {
      await _phone(tester, size);
      await tester.pumpWidget(const BelotApp());
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Igraj online'), findsOneWidget);

      await tester.tap(find.text('Igraj online'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Tvoj red'), findsOneWidget);

      await tester.tap(find.text('Zovi adut'));
      await tester.pump(const Duration(milliseconds: 1400));

      // Let the bots and my turn timer (auto-play) finish all 8 tricks.
      final game = (tester.state(find.byType(BelotApp)) as dynamic).game as BelotController;
      for (var i = 0; i < 400 && game.screen != Screen.end; i++) {
        if (game.myTurn) {
          final card = game.playable.first;
          game.tapCard(card);
          game.tapCard(card);
        }
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(game.screen, Screen.end);
      expect(game.hands[Seat.me], isEmpty);
      expect(game.scoreA + game.scoreB, 162);
      expect(find.text('Nova runda'), findsOneWidget);

      await tester.tap(find.text('Početna'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Igraj online'), findsOneWidget);
    });
  }
}
