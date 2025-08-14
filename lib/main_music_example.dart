import 'package:flutter/material.dart';
import 'services/background_music.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundMusic.instance.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Musik är igång — integrera nu i din egen appstruktur.'),
        ),
      ),
    );
  }
}
