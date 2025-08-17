import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bakgrundsmusik: på/av + loop. Ingen UI-förändring.
class BackgroundMusic extends ChangeNotifier {
  static final BackgroundMusic instance = BackgroundMusic._();
  BackgroundMusic._();

  static const _kMusicEnabled = 'music_enabled';
  static const _assetPath = 'assets/audio/FloridaBirds.mp3';

  final AudioPlayer _player = AudioPlayer();

  /// Publikt notifierat tillstånd som UI kan lyssna på.
  /// (Används av ValueListenableBuilder i UI.)
  final ValueNotifier<bool> enabledNotifier = ValueNotifier<bool>(true);

  bool get enabled => enabledNotifier.value;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getBool(_kMusicEnabled);
    enabledNotifier.value = saved ?? true;

    try {
      if (_player.audioSource == null) {
        await _player.setAudioSource(AudioSource.asset(_assetPath));
        await _player.setLoopMode(LoopMode.one);
        await _player.setVolume(0.6);
      }
      if (enabled) {
        await _player.play();
      } else {
        await _player.pause();
      }
    } catch (_) {
      // Tysta init-fel så appen alltid startar.
    }
    notifyListeners();
  }

  Future<void> _startFresh() async {
    await _player.stop();
    await _player.setAudioSource(AudioSource.asset(_assetPath));
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(0.6);
    await _player.seek(Duration.zero);
    await _player.play();
  }

  Future<void> setEnabled(bool on) async {
    enabledNotifier.value = on;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kMusicEnabled, on);

    try {
      if (on) {
        await _startFresh();
      } else {
        await _player.pause();
      }
    } catch (_) {
      // Ignorera enstaka fel.
    }

    // Informera både de som lyssnar på ChangeNotifier och ValueListenable.
    notifyListeners();
  }

  Future<void> toggle() => setEnabled(!enabled);
}
