import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bakgrundsmusik: på/av + loop. Inga UI-ändringar.
class BackgroundMusic extends ChangeNotifier {
  static final BackgroundMusic instance = BackgroundMusic._();
  BackgroundMusic._();

  static const _kMusicEnabled = 'music_enabled';
  static const _assetPath = 'assets/audio/FloridaBirds.mp3';

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get enabled => _enabled;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _enabled = sp.getBool(_kMusicEnabled) ?? true;

    try {
      // Första init – förbered och starta om aktiverad
      await _ensurePrepared();
      if (_enabled) {
        await _player.play();
      }
    } catch (_) {
      // Tysta init-fel så appen alltid startar
    }
    notifyListeners();
  }

  Future<void> _ensurePrepared() async {
    if (_player.audioSource == null) {
      await _player.setAudioSource(AudioSource.asset(_assetPath));
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0.6);
    }
  }

  Future<void> _startFresh() async {
    // Säker nystart: stoppa, sätt källa, loop, volym, seek 0, spela
    await _player.stop();
    await _player.setAudioSource(AudioSource.asset(_assetPath));
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(0.6);
    await _player.seek(Duration.zero);
    await _player.play();
  }

  Future<void> setEnabled(bool on) async {
    _enabled = on;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kMusicEnabled, on);

    try {
      if (on) {
        await _startFresh();        // <— viktig fix
      } else {
        await _player.pause();
      }
    } catch (_) {
      // Ignorera enstaka fel från ljudstacken
    }

    notifyListeners();
  }

  Future<void> toggle() => setEnabled(!_enabled);
}
