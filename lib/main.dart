import 'package:flutter/material.dart';
import 'services/background_music.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Starta bakgrundsmusiken en gång
  BackgroundMusic.instance.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess the Heritage',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6DC17E), // mjuk grön ton
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Musik igång 🎵'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                // TODO: navigera till din riktiga startsida/spelvy
              },
              child: const Text('Starta spel'),
            ),
          ],
        ),
      ),
    );
  }
}
