import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Lang extends ChangeNotifier {
  static const _kLangCode = 'app_lang_code';
  static const _kFollowSystem = 'follow_system';

  bool followingSystem = true;
  Locale? _locale; // null = följ systemet

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    followingSystem = sp.getBool(_kFollowSystem) ?? true;
    final savedCode = sp.getString(_kLangCode);
    if (!followingSystem && savedCode != null) {
      _locale = Locale(savedCode);
    }
  }

  /// Null => följ systemet
  Locale? materialLocale() => followingSystem ? null : (_locale ?? const Locale('en'));

  Future<void> setLocale(Locale locale) async {
    followingSystem = false;
    _locale = locale;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLangCode, locale.languageCode);
    await sp.setBool(_kFollowSystem, false);
    notifyListeners();
  }

  Future<void> followSystem() async {
    followingSystem = true;
    _locale = null;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kFollowSystem, true);
    await sp.remove(_kLangCode);
    notifyListeners();
  }

  /// Språkkod som används för t()
  String currentCode() {
    if (!followingSystem && _locale != null) {
      return _locale!.languageCode.toLowerCase();
    }
    final system = WidgetsBinding.instance.platformDispatcher.locale;
    return (system.languageCode.toLowerCase());
  }

  /// Enkel översättning: svenska / engelska
  String tr(String sv, String en) => currentCode().startsWith('sv') ? sv : en;
}

final lang = Lang();
String t(String sv, String en) => lang.tr(sv, en);
