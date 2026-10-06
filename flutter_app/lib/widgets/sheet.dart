import 'package:flutter/widgets.dart';

import '../theme.dart';
import 'anim.dart';
import 'buttons.dart';

/// Centred modal panel over a dimmed screen. Tapping outside closes it.
class BelotSheet extends StatelessWidget {
  const BelotSheet({super.key, required this.title, required this.child, required this.onClose, this.width = 420, this.maxHeight});
  final String title;
  final Widget child;
  final VoidCallback onClose;
  final double width;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) => FadeIn(
        duration: const Duration(milliseconds: 200),
        child: Stack(children: [
          Positioned.fill(
            child: GestureDetector(onTap: onClose, child: const ColoredBox(color: Color(0xA60E1514))),
          ),
          Center(
            child: Container(
              width: width,
              constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 20),
              decoration: BoxDecoration(
                color: BelotColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BelotColors.hairline),
                boxShadow: BelotShadows.panel,
              ),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Expanded(child: Text(title, style: jakarta(18, 700, lineHeight: 24))),
                  IconChipButton(label: 'Zatvori', icon: BelotIcons.close(), onTap: onClose),
                ]),
                const SizedBox(height: 4),
                Flexible(child: Padding(padding: const EdgeInsets.only(right: 8), child: child)),
              ]),
            ),
          ),
        ]),
      );
}

/// Pill-shaped segmented choice (settings).
class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.options, required this.value, required this.label, required this.onChanged});
  final List<T> options;
  final T value;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: BelotColors.hairline, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final o in options)
            Semantics(
              button: true,
              selected: o == value,
              child: GestureDetector(
                onTap: () => onChanged(o),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: o == value ? BelotColors.accent : const Color(0x00000000), borderRadius: BorderRadius.circular(999)),
                    child: Text(label(o), style: jakarta(13, 700, color: o == value ? BelotColors.onAccent : BelotColors.text, tabular: true)),
                  ),
                ),
              ),
            ),
        ]),
      );
}
