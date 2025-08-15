import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Stabil bakgrundsmusik med gapless + crossfade.
/// Tips: byt testfilerna mot längre, riktiga ambient-loopar.
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

    // Mild crossfade mellan spår
    await _player.setCrossFadeDuration(const Duration(seconds: 2));

    final playlist = ConcatenatingAudioSource(children: [
      AudioSource.asset('assets/audio/forest.wav'),
      AudioSource.asset('assets/audio/rain.wav'),
      AudioSource.asset('assets/audio/wind.wav'),
    ]);

    await _player.setAudioSource(playlist, initialIndex: 0, preload: true);
    await _player.setLoopMode(LoopMode.all);          // loopa hela listan
    await _player.setShuffleModeEnabled(true);        // mixa spårordning

    // Starta med lagom volym; muting sköts med setVolume (inte stop)
    await _player.setVolume(_muted ? 0.0 : 0.8);
    await _player.play();
  }

  Future<void> setMuted(bool mute) async {
    _muted = mute;
    // Sänk/höj volym mjukt istället för att stoppa (undviker hack)
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
