import 'package:flutter/widgets.dart';
import 'services/background_music.dart';

/// Exempelprogram som bara startar bakgrundsmusik.
/// Denna fil är bara för demo/analyse och används inte när du bygger appen
/// (standardentry är lib/main.dart).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundMusic.instance.ensureStarted();
}
