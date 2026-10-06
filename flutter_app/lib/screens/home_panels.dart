import 'package:flutter/widgets.dart';

import '../game/belot_controller.dart';
import '../theme.dart';
import '../widgets/sheet.dart';

const _rules = [
  ('Cilj', 'Igraju dva tima po dva igrača; partneri sjede nasuprot. Pobjeđuje tim koji prvi skupi 1001 bod (cilj možeš promijeniti u postavkama).'),
  ('Dijeljenje i adut', 'Svaki igrač dobije 8 karata. Djeliteljeva zadnja karta je otkrivena i nudi se kao adut. U prvom krugu svako redom može zvati tu boju ili reći „Dalje“. Ako svi kažu „Dalje“, u drugom krugu se može zvati bilo koja druga boja, a djelitelj mora zvati.'),
  ('Igra', 'Prvi igra igrač nakon djelitelja, a svaki sljedeći štih otvara onaj ko je nosio prethodni. Moraš pratiti boju i, ako možeš, igrati jaču kartu. Ako nemaš boju, moraš sjeći adutom i prebiti jači adut ako možeš. Ako nemaš ni adut, igraš bilo koju kartu.'),
  ('Jačina karata', 'Adut: J, 9, A, 10, K, Q, 8, 7.\nOstale boje: A, 10, K, Q, J, 9, 8, 7.'),
  ('Bodovi', 'Adut: J 20, 9 14, A 11, 10 10, K 4, Q 3.\nOstale boje: A 11, 10 10, K 4, Q 3, J 2.\nZadnji štih +10. Ukupno u kartama 162.'),
  ('Zvanja', 'Tri karte u nizu 20, četiri 50, pet ili više 100. Četiri dečka 200, četiri devetke 150, četiri asa, kralja, dame ili desetke 100. Boduje samo tim s najjačim zvanjem. Bela (kralj i dama aduta kod istog igrača) 20. Štiglja (svi štihovi) +90.'),
  ('Prolaz i pad', 'Tim koji je zvao adut mora imati više bodova od protivnika. Ako nema, pada i svi bodovi te runde idu protivnicima.'),
];

/// Scrollable Bela rules for the home screen.
class RulesText extends StatelessWidget {
  const RulesText({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final (title, body) in _rules) ...[
            const SizedBox(height: 12),
            Text(title.toUpperCase(), style: jakarta(12, 700, em: .06, color: BelotColors.accent)),
            const SizedBox(height: 4),
            Text(body, style: jakarta(14, 400, lineHeight: 21, color: BelotColors.textSoft)),
          ],
        ]),
      );
}

/// Game settings: target score and bot speed.
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key, required this.game});
  final BelotController game;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: game,
        builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          _row('Igra se do', Segmented<int>(options: const [501, 701, 1001], value: game.target, label: (v) => '$v', onChanged: game.setTarget)),
          const SizedBox(height: 16),
          _row('Brzina botova', Segmented<BotSpeed>(options: BotSpeed.values, value: game.botSpeed, label: (v) => v.label, onChanged: game.setBotSpeed)),
        ]),
      );

  static Widget _row(String label, Widget control) => Row(children: [
        Expanded(child: Text(label, style: jakarta(15, 600))),
        control,
      ]);
}
