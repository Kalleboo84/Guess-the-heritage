import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bakgrundsmusik med på/av + loop. Är en ChangeNotifier (har addListener/removeListener).
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
      await _prepareIfNeeded();
      if (_enabled) {
        await _player.play();
      }
    } catch (_) {
      // Ignorera init-fel (t.ex. saknad fil) så appen startar ändå.
    }
    notifyListeners();
  }

  /// Säkerställ att spelaren har källa, loop och volym.
  Future<void> _prepareIfNeeded() async {
    if (_player.audioSource == null) {
      await _player.setAudioSource(AudioSource.asset(_assetPath));
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0.6);
    }
  }

  Future<void> setEnabled(bool on) async {
    _enabled = on;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kMusicEnabled, on);

    try {
      if (on) {
        // 🔧 Viktigt: se till att källa finns och hoppa till början innan play()
        await _prepareIfNeeded();
        try {
          await _player.seek(Duration.zero);
        } catch (_) {
          // Om seek misslyckas, fortsätt ändå med play.
        }
        await _player.play();
      } else {
        await _player.pause();
      }
    } catch (_) {
      // Tysta eventuella play/pause-fel
    }

    notifyListeners();
  }

  Future<void> toggle() => setEnabled(!_enabled);
}
