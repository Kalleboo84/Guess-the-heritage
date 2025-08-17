import 'package:flutter/material.dart';
import '../../services/lang.dart' as i18n;

/// Litet språkval uppe till höger. Ingen visuell omplacering.
/// Visar bock för aktuell källa: Följ system / Svenska / English.
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Bygg om automatiskt när språket ändras
    return AnimatedBuilder(
      animation: i18n.lang,
      builder: (context, _) {
        final current = i18n.lang.current; // förväntas vara AppLocale.system/sv/en

        return PopupMenuButton<int>(
          tooltip: i18n.t('Språk', 'Language'),
          icon: const Icon(Icons.language_rounded),
          onSelected: (value) {
            // 0=system, 1=sv, 2=en
            if (value == 0) {
              i18n.lang.setOverride(AppLocale.system);
            } else if (value == 1) {
              i18n.lang.setOverride(AppLocale.sv);
            } else if (value == 2) {
              i18n.lang.setOverride(AppLocale.en);
            }
          },
          itemBuilder: (context) => [
            _item(
              text: i18n.t('Följ system', 'Follow system'),
              selected: current == AppLocale.system,
              value: 0,
            ),
            _item(
              text: 'Svenska',
              selected: current == AppLocale.sv,
              value: 1,
            ),
            _item(
              text: 'English',
              selected: current == AppLocale.en,
              value: 2,
            ),
          ],
        );
      },
    );
  }

  PopupMenuItem<int> _item({
    required String text,
    required bool selected,
    required int value,
  }) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          if (selected) const Icon(Icons.check, size: 18),
        ],
      ),
    );
  }
}

/// En enkel enum som matchar i18n-tjänsten.
/// Om din `services/lang.dart` redan exporterar AppLocale, ta bort denna och
/// importera den därifrån. Lämnas här för kompatibilitet.
enum AppLocale { system, sv, en }
