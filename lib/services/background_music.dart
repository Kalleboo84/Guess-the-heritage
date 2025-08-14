import 'dart:math';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Enkel bakgrundsmusik-tjänst.
/// Spelar ett slumpat spår till slut, väljer sedan ett nytt (ej samma som nyss).
class BackgroundMusic {
  BackgroundMusic._internal();
  static final BackgroundMusic instance = BackgroundMusic._internal();

  final AudioPlayer _player = AudioPlayer();
  final Random _rng = Random();

  final List<String> _tracks = const [
    'assets/audio/forest.wav',
    'assets/audio/rain.wav',
    'assets/audio/wind.wav',
  ];

  String? _current;
  bool _started = false;
  bool _muted = false;

  bool get isStarted => _started;
  bool get isMuted => _muted;

  Future<void> ensureStarted() async {
    if (!_started) {
      await start();
    }
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _player.setLoopMode(LoopMode.off);

    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed && !_muted) {
        await _playRandom(exclude: _current);
      }
    });

    if (!_muted) {
      await _playRandom();
    }
  }

  Future<void> _playRandom({String? exclude}) async {
    final candidates = _tracks.where((t) => t != exclude).toList();
    final next = candidates[_rng.nextInt(candidates.length)];
    _current = next;
    await _player.setAsset(next);
    try {
      await _player.setVolume(0.0);
      await _player.play();
      for (var v = 0; v <= 10; v++) {
        await Future.delayed(const Duration(milliseconds: 60));
        await _player.setVolume(v / 10.0);
      }
    } catch (_) {
      await _player.play();
    }
  }

  /// Slå av/på musik. Startar musiken om den var av och ska sättas på.
  Future<void> setMuted(bool mute) async {
    _muted = mute;
    if (mute) {
      await _player.stop();
    } else {
      await ensureStarted();
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
