import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocale { en, sv }

/// Global språktjänst
class Lang extends ChangeNotifier {
  static const _prefsKey = 'app_locale_override';
  AppLocale? _override; // null = följ systemet

  /// Ladda tidigare valt språk (om något) från SharedPreferences
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == null) return;
    _override = AppLocale.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppLocale.en,
    );
    notifyListeners();
  }

  /// Sätt ett specifikt språk, eller null för att följa systemet
  Future<void> setOverride(AppLocale? loc) async {
    _override = loc;
    final prefs = await SharedPreferences.getInstance();
    if (loc == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, loc.name);
    }
    notifyListeners();
  }

  /// Aktuellt språk (override om satt, annars systemets)
  AppLocale get current => _override ?? _systemDefault();

  bool get followingSystem => _override == null;

  /// Översättning ”på två rader”
  String t(String sv, String en) => current == AppLocale.sv ? sv : en;

  /// Flutter Locale för MaterialApp
  Locale materialLocale() {
    switch (current) {
      case AppLocale.sv:
        return const Locale('sv');
      case AppLocale.en:
      default:
        return const Locale('en');
    }
  }

  /// Läs av systemets språklista: om sv finns → sv, annars en
  AppLocale _systemDefault() {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;
    for (final l in locales) {
      if (l.languageCode.toLowerCase() == 'sv') return AppLocale.sv;
    }
    return AppLocale.en; // fallback = engelska
  }
}

final lang = Lang();
