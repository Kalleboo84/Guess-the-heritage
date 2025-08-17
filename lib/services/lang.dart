import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Språkläge som kan väljas i appen.
enum AppLocale {
  system, // Följ enhetens språk
  svSE,   // Svenska (Sverige)
  enUS,   // Engelska (USA)
}

/// Global språk-controller (lyssningsbar i UI via addListener)
class Lang extends ChangeNotifier {
  AppLocale _current = AppLocale.system;

  AppLocale get current => _current;

  /// Sätt manuellt språköverstyrning (uppdaterar lyssnare automatiskt).
  void setOverride(AppLocale locale) {
    if (_current == locale) return;
    _current = locale;
    notifyListeners();
  }

  /// Översättnings-hjälpare:
  /// Används i UI som: i18n.t('Svenska texten', 'English text')
  String t(String sv, String en) {
    final code = _effectiveLocaleCode();
    // Alla 'sv*' → svenska, annars engelska
    if (code.startsWith('sv')) return sv;
    return en;
  }

  /// Tar fram effektiv språkkod enligt valt läge
  String _effectiveLocaleCode() {
    switch (_current) {
      case AppLocale.svSE:
        return 'sv_SE';
      case AppLocale.enUS:
        return 'en_US';
      case AppLocale.system:
        final locales = WidgetsBinding.instance.platformDispatcher.locales;
        if (locales.isNotEmpty) {
          final l = locales.first;
          final lang = l.languageCode; // t.ex. "sv" / "en"
          final country = l.countryCode ?? ''; // t.ex. "SE" / "US"
          return country.isNotEmpty ? '${lang}_$country' : lang;
        }
        // Fallback om inga locales rapporteras
        return 'en_US';
    }
  }
}

/// Global instans som resten av appen använder
final Lang lang = Lang();

/// Top-level hjälpfunktion så du kan skriva i18n.t('sv', 'en') var som helst.
String t(String sv, String en) => lang.t(sv, en);
