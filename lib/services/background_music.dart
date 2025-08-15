import 'package:just_audio/just_audio.dart';

/// Enkel bakgrundsmusik som loopar FloridaBirds.mp3
class BackgroundMusic {
  BackgroundMusic._();
  static final BackgroundMusic instance = BackgroundMusic._();

  final AudioPlayer _player = AudioPlayer();
  bool _started = false;

  Future<void> ensureStarted() async {
    if (_started) return;
    _started = true;
    try {
      await _player.setAudioSource(
        AudioSource.asset('assets/audio/FloridaBirds.mp3'),
      );
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (_) {
      // Ignorera ljudfel i produktion
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _started = false;
  }

  void dispose() {
    _player.dispose();
  }
}
