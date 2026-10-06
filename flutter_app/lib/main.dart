import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'game/belot_controller.dart';
import 'layout.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'theme.dart';
import 'widgets/paint.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Landscape only, fullscreen (status bar hidden).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const BelotApp());
}

class BelotApp extends StatefulWidget {
  const BelotApp({super.key});

  @override
  State<BelotApp> createState() => _BelotAppState();
}

class _BelotAppState extends State<BelotApp> {
  final game = BelotController();

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The game UI is fully custom and identical on iOS and Android, so no Material/Cupertino app shell.
    return WidgetsApp(
      title: 'Belot',
      color: BelotColors.accent,
      debugShowCheckedModeBanner: false,
      builder: (context, _) => MediaQuery.withNoTextScaling(
        child: DefaultTextStyle(
          style: jakarta(15, 400),
          child: ColoredBox(
            color: BelotColors.bg,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final layout = BelotLayout.of(context, constraints);
                return ListenableBuilder(
                  listenable: game,
                  builder: (context, _) => Stack(children: [
                    const Positioned.fill(child: TableBackground()),
                    Positioned.fill(
                      child: game.screen == Screen.home
                          ? HomeScreen(layout: layout, game: game)
                          : GameScreen(layout: layout, game: game),
                    ),
                  ]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
