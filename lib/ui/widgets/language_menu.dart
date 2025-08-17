import 'package:flutter/material.dart';
import 'package:guess_the_heritage/services/lang.dart' as i18n;

/// Popup-meny för språk. Visar ✅ på valt språk och uppdateras live.
/// Kräver att `i18n.lang` är en ChangeNotifier med:
/// - getter: current (AppLocale)
/// - method: setOverride(AppLocale)
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: i18n.lang,
      builder: (context, _) {
        final current = i18n.lang.current;

        return PopupMenuButton<i18n.AppLocale>(
          tooltip: i18n.t('Språk', 'Language'),
          icon: const Icon(Icons.language_rounded),
          onSelected: (sel) => i18n.lang.setOverride(sel),
          itemBuilder: (context) => [
            _item(
              value: i18n.AppLocale.system,
              text: i18n.t('Systemspråk', 'System language'),
              selected: current == i18n.AppLocale.system,
            ),
            _item(
              value: i18n.AppLocale.svSE,
              text: 'Svenska',
              selected: current == i18n.AppLocale.svSE,
            ),
            _item(
              value: i18n.AppLocale.enUS,
              text: 'English',
              selected: current == i18n.AppLocale.enUS,
            ),
          ],
        );
      },
    );
  }

  PopupMenuItem<i18n.AppLocale> _item({
    required i18n.AppLocale value,
    required String text,
    required bool selected,
  }) {
    return PopupMenuItem<i18n.AppLocale>(
      value: value,
      child: Row(
        children: [
          Expanded(child: Text(text)),
          if (selected) const Icon(Icons.check, size: 18),
        ],
      ),
    );
  }
}
