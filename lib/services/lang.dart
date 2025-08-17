import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Vilka lägen appens språk kan vara i.
enum AppLocale { system, sv, en }

/// Enkel språktjänst som notifierar lyssnare vid ändring.
/// Ingen UI-förändring – bara logik.
class Lang extends ChangeNotifier {
  static const _kLang = 'app_locale_override';

  AppLocale _override = AppLocale.system;

  /// Returnerar valt läge (system/sv/en).
  AppLocale get current => _override;

  /// (Valfritt) Ladda sparat val från disk.
  Future<void> init() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final saved = sp.getString(_kLang);
      if (saved != null) {
        _override = AppLocale.values.firstWhere(
          (e) => e.name == saved,
          orElse: () => AppLocale.system,
        );
      }
    } catch (_) {
      // Ignorera fel – standard blir system.
    }
  }

  /// Sätt nytt språkläge och spara.
  Future<void> setOverride(AppLocale locale) async {
    if (_override == locale) return;
    _override = locale;
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kLang, _override.name);
    } catch (_) {
      // Ignorera sparfel – påverkar ej körning.
    }
    notifyListeners();
  }

  bool get _systemIsSwedish {
    final code =
        ui.PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    return code.startsWith('sv');
  }

  /// True om svenska ska väljas utifrån nuvarande läge.
  bool get isSwedish {
    switch (_override) {
      case AppLocale.sv:
        return true;
      case AppLocale.en:
        return false;
      case AppLocale.system:
        return _systemIsSwedish;
    }
  }

  /// Tvåsträngs-översättning: först SV, sen EN.
  String t(String sv, String en) => isSwedish ? sv : en;
}

/// Global instans + hjälpfunktioner (som din kod redan använder).
final Lang lang = Lang();

String t(String sv, String en) => lang.t(sv, en);
