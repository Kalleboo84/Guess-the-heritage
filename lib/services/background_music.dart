import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Spelar en enda ambience-fil i loop (tystas med setMuted).
class BackgroundMusic {
  BackgroundMusic._internal();
  static final BackgroundMusic instance = BackgroundMusic._internal();

  final AudioPlayer _player = AudioPlayer();

  bool _started = false;
  bool _muted = false;

  Future<void> ensureStarted() async {
    if (!_started) await start();
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // ✅ Spela din uppladdade fil och loopa den
    await _player.setAsset('assets/audio/FloridaBirds.mp3');
    await _player.setLoopMode(LoopMode.one); // loopa just detta spår
    await _player.setVolume(_muted ? 0.0 : 0.8);
    await _player.play();
  }

  /// Slå av/på musik mjukt utan att stoppa (undviker hack)
  Future<void> setMuted(bool mute) async {
    _muted = mute;
    if (mute) {
      await _player.setVolume(0.0);
    } else {
      await ensureStarted();
      await _player.setVolume(0.8);
    }
  }

  Future<void> stop() async {
    _started = false;
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
