import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Enkel bakgrundsmusik-kontroller med toggle och loop.
/// Används via: BackgroundMusic.instance
class BackgroundMusic extends ChangeNotifier {
  BackgroundMusic._();
  static final BackgroundMusic instance = BackgroundMusic._();

  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> enabledNotifier = ValueNotifier<bool>(true);

  bool _initialized = false;

  bool get enabled => enabledNotifier.value;

  /// Starta musiken exakt en gång (loopar tills man stänger av).
  Future<void> ensureStarted() async {
    if (_initialized) return;
    _initialized = true;
    try {
      // Din fil: assets/audio/FloridaBirds.mp3 (läggs i pubspec.yaml)
      await _player.setAudioSource(
        AudioSource.asset('assets/audio/FloridaBirds.mp3'),
      );
      await _player.setLoopMode(LoopMode.one);
      if (enabledNotifier.value) {
        await _player.play();
      }
    } catch (e) {
      // Tysta fel i release; ev. logga i debug om du vill.
    }
  }

  /// Slå av/på musiken.
  Future<void> toggle() async {
    final next = !enabledNotifier.value;
    enabledNotifier.value = next;
    notifyListeners(); // om någon lyssnar på instansen

    if (next) {
      try {
        await _player.play();
      } catch (_) {}
    } else {
      await _player.pause();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    enabledNotifier.dispose();
    super.dispose();
  }
}
