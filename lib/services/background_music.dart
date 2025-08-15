import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Stabil bakgrundsmusik med gapless + crossfade.
/// Tips: använd längre ambient-loopar (30–120 s) för bäst känsla.
class BackgroundMusic {
  BackgroundMusic._internal();
  static final BackgroundMusic instance = BackgroundMusic._internal();

  // ✅ Sätt crossfade i konstruktorn (stöds av just_audio)
  final AudioPlayer _player = AudioPlayer(
    crossFadeDuration: const Duration(seconds: 2),
  );

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

    final playlist = ConcatenatingAudioSource(children: const [
      AudioSource.asset('assets/audio/forest.wav'),
      AudioSource.asset('assets/audio/rain.wav'),
      AudioSource.asset('assets/audio/wind.wav'),
    ]);

    await _player.setAudioSource(playlist, initialIndex: 0, preload: true);
    await _player.setLoopMode(LoopMode.all);
    await _player.setShuffleModeEnabled(true);

    await _player.setVolume(_muted ? 0.0 : 0.8);
    await _player.play();
  }

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
