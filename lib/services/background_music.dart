import 'dart:async';
import 'package:flutter/foundation.dart'; // ChangeNotifier, ValueListenable, ValueNotifier, debugPrint
import 'package:just_audio/just_audio.dart';

/// Bakgrundsmusik (singleton) med mjuk fade och preloading.
/// - Åtkomst: BackgroundMusic.instance
/// - ensureStarted(): säkerställer att musik startar om den ska vara på
/// - enabledNotifier: ValueListenable<bool> för UI (Sound On/Off-knapp)
class BackgroundMusic extends ChangeNotifier {
  // ---- Singleton ----
  BackgroundMusic._internal() {
    _init();
  }
  static final BackgroundMusic _instance = BackgroundMusic._internal();
  factory BackgroundMusic() => _instance;
  static BackgroundMusic get instance => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _inited = false;
  bool _busy = false; // skydd mot snabba upprepade klick
  bool _enabled = true; // starta med ljud PÅ

  // UI-lyssnare (för t.ex. ValueListenableBuilder)
  final ValueNotifier<bool> _enabledVN = ValueNotifier<bool>(true);
  ValueListenable<bool> get enabledNotifier => _enabledVN;

  bool get enabled => _enabled;

  static const double _targetVolume = 0.6;
  static const Duration _fadeDur = Duration(milliseconds: 500);

  Future<void> _init() async {
    if (_inited) return;
    try {
      await _player.setAsset('assets/audio/FloridaBirds.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0.0);
      _inited = true;

      // Starta direkt om ljud ska vara på
      if (_enabled) {
        await _player.play();
        await _fadeTo(_targetVolume, _fadeDur);
      }
    } catch (e) {
      debugPrint('BackgroundMusic init error: $e');
    }
  }

  /// Säkerställ att musiken spelar om ljud är påslaget.
  Future<void> ensureStarted() async {
    if (_busy) return;
    await _init();
    if (!_enabled) return;
    if (!_player.playing) {
      await _player.play();
    }
    if (_player.volume < _targetVolume - 0.01) {
      await _fadeTo(_targetVolume, _fadeDur);
    }
  }

  /// Växla på/av med mjuk fade.
  Future<void> toggle() async {
    await setEnabled(!_enabled);
  }

  /// Slå på/av explicit (används av toggle & UI).
  Future<void> setEnabled(bool value) async {
    if (_busy || value == _enabled) return;
    _busy = true;
    try {
      if (value) {
        await _init();
        if (!_player.playing) {
          await _player.play();
        }
        await _fadeTo(_targetVolume, _fadeDur);
        _enabled = true;
      } else {
        await _fadeTo(0.0, _fadeDur);
        await _player.pause(); // pausa (behåll buffert) för mindre knaster
        _enabled = false;
      }
      _enabledVN.value = _enabled;
      notifyListeners();
    } catch (e) {
      debugPrint('BackgroundMusic setEnabled error: $e');
    } finally {
      _busy = false;
    }
  }

  /// Mjuk volymramp utan externa paket.
  Future<void> _fadeTo(double target, Duration dur) async {
    try {
      final current = _player.volume;
      const int steps = 15;
      final stepDur = dur.inMilliseconds ~/ steps;
      final delta = (target - current) / steps;

      for (int i = 1; i <= steps; i++) {
        final v = (current + delta * i).clamp(0.0, 1.0);
        await _player.setVolume(v);
        await Future.delayed(Duration(milliseconds: stepDur));
      }
    } catch (_) {
      await _player.setVolume(target);
    }
  }

  @override
  void dispose() {
    _enabledVN.dispose();
    _player.dispose();
    super.dispose();
  }
}

/// Legacy/global – pekar på samma singleton om något gammalt anropar den.
final backgroundMusic = BackgroundMusic.instance;
