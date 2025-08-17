import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bakgrundsmusik med på/av + loop. Är en ChangeNotifier (har addListener/removeListener).
class BackgroundMusic extends ChangeNotifier {
  static final BackgroundMusic instance = BackgroundMusic._();
  BackgroundMusic._();

  static const _kMusicEnabled = 'music_enabled';

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get enabled => _enabled;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    _enabled = sp.getBool(_kMusicEnabled) ?? true;

    try {
      await _player.setAudioSource(
        AudioSource.asset('assets/audio/FloridaBirds.mp3'),
      );
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0.6);
      if (_enabled) {
        await _player.play();
      }
    } catch (_) {
      // Ignorera init-fel (t.ex. saknad fil) så appen startar ändå
    }
    notifyListeners();
  }

  Future<void> setEnabled(bool on) async {
    _enabled = on;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kMusicEnabled, on);
    if (on) {
      await _player.play();
    } else {
      await _player.pause();
    }
    notifyListeners();
  }

  Future<void> toggle() => setEnabled(!_enabled);
}
