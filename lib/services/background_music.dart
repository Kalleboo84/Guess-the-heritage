import 'dart:math';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Enkel bakgrundsmusik-tjänst för Guess the Heritage.
/// Spelar ett slumpat ambient-spår till slut, väljer sedan ett nytt (ej samma som nyss).
class BackgroundMusic {
  BackgroundMusic._internal();
  static final BackgroundMusic instance = BackgroundMusic._internal();

  final AudioPlayer _player = AudioPlayer();
  final Random _rng = Random();

  /// Byt/utöka listan med dina riktiga spår i assets/audio/
  final List<String> _tracks = const [
    'assets/audio/forest.wav',
    'assets/audio/rain.wav',
    'assets/audio/wind.wav',
  ];

  String? _current;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    // Konfigurera sessionen för musik
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Vi loopar inte ett och samma spår – vi byter när det är slut
    await _player.setLoopMode(LoopMode.off);

    // När spåret är slut, välj nytt
    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await _playRandom(exclude: _current);
      }
    });

    // Starta med ett slumpat spår
    await _playRandom();
  }

  Future<void> _playRandom({String? exclude}) async {
    final candidates = _tracks.where((t) => t != exclude).toList();
    final next = candidates[_rng.nextInt(candidates.length)];
    _current = next;

    await _player.setAsset(next);

    // Mjuk fade-in för att undvika hårda starter
    try {
      await _player.setVolume(0.0);
      await _player.play();
      for (var v = 0; v <= 10; v++) {
        await Future.delayed(const Duration(milliseconds: 60));
        await _player.setVolume(v / 10.0);
      }
    } catch (_) {
      // Om fade misslyckas, spela ändå
      await _player.play();
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
