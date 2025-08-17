import 'package:flutter/material.dart';
import '../../services/lang.dart' as i18n;

/// Språkval i topphörnet. Ingen visuell ändring.
/// Markerar korrekt bock för System / Svenska / English.
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: i18n.lang,
      builder: (context, _) {
        final current = i18n.lang.current;

        return PopupMenuButton<int>(
          tooltip: i18n.t('Språk', 'Language'),
          icon: const Icon(Icons.language_rounded),
          onSelected: (value) {
            // 0=System, 1=sv, 2=en
            if (value == 0) {
              i18n.lang.setOverride(i18n.AppLocale.system);
            } else if (value == 1) {
              i18n.lang.setOverride(i18n.AppLocale.sv);
            } else if (value == 2) {
              i18n.lang.setOverride(i18n.AppLocale.en);
            }
          },
          itemBuilder: (context) => [
            _item(
              text: i18n.t('Följ system', 'Follow system'),
              selected: current == i18n.AppLocale.system,
              value: 0,
            ),
            _item(
              text: 'Svenska',
              selected: current == i18n.AppLocale.sv,
              value: 1,
            ),
            _item(
              text: 'English',
              selected: current == i18n.AppLocale.en,
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
