import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

/// Enkel bakgrundsmusik med mjuk fade-in/fade-out och preloading.
/// - Startar automatiskt om [enabled] är true.
/// - Pausar (stoppar inte) vid avstängning för att undvika knaster.
/// - Inga UI-beroenden; endast ChangeNotifier för att knappen kan lyssna på state.
class BackgroundMusic extends ChangeNotifier {
  BackgroundMusic() {
    _init(); // laddar och startar (om enabled=true)
  }

  final AudioPlayer _player = AudioPlayer();
  bool _inited = false;
  bool _busy = false; // skyddar mot dubbelklick/glitch
  bool _enabled = true; // starta musik ON som default

  bool get enabled => _enabled;

  /// Justera om du vill annan grundvolym.
  static const double _targetVolume = 0.6;
  static const Duration _fadeDur = Duration(milliseconds: 500);

  Future<void> _init() async {
    if (_inited) return;
    try {
      // Ladda källan i förväg (minskar start-hack/knaster)
      await _player.setAsset('assets/audio/FloridaBirds.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0.0);

      _inited = true;

      if (_enabled) {
        // Vänta en tick så decodern är redo, sen mjuk fade-in
        await _player.play();
        await _fadeTo(_targetVolume, _fadeDur);
      }
    } catch (e) {
      // Tyst fel – vi vill inte krascha spelet om ljudet saknas.
      debugPrint('BackgroundMusic init error: $e');
    }
  }

  /// Växla på/av. Mjuk fade vid båda lägena.
  Future<void> toggle() async {
    if (_busy) return;
    _busy = true;
    try {
      if (_enabled) {
        await _fadeTo(0.0, _fadeDur);
        await _player.pause(); // behåll buffern -> mindre knaster vid nästa start
        _enabled = false;
        notifyListeners();
      } else {
        await _init();
        // säkerställ att vi är laddade och i startläge
        if (_player.playing == false) {
          await _player.play();
        }
        await _fadeTo(_targetVolume, _fadeDur);
        _enabled = true;
        notifyListeners();
      }
    } finally {
      _busy = false;
    }
  }

  /// För säkerhets skull om du vill explicit slå på/av utan att veta läget.
  Future<void> setEnabled(bool value) async {
    if (value == _enabled) return;
    await toggle();
  }

  /// Mjuk volymramp utan externa paket.
  Future<void> _fadeTo(double target, Duration dur) async {
    try {
      final current = _player.volume;
      final steps = 15;
      final stepDur = dur.inMilliseconds ~/ steps;
      final delta = (target - current) / steps;

      for (int i = 1; i <= steps; i++) {
        await _player.setVolume((current + delta * i).clamp(0.0, 1.0));
        await Future.delayed(Duration(milliseconds: stepDur));
      }
    } catch (e) {
      // Om något går fel, försök bara sätta slutvolymen direkt.
      await _player.setVolume(target);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Valfritt: en global instans om din UI använder en singleton.
final backgroundMusic = BackgroundMusic();
