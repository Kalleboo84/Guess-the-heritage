import 'package:flutter/material.dart';
import '../services/lang.dart';
import '../services/background_music.dart';
import 'widgets/language_menu.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    BackgroundMusic.instance.ensureStarted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('Världsarvs-quiz', 'Heritage Quiz')),
        actions: const [
          LanguageMenu(), // 🌍 språkval
          SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6FFF6), Color(0xFFC8F3E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.terrain, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    lang.t('Gissa kulturarvet!', 'Guess the Heritage!'),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.t(
                      'Starta spelet och se hur många platser du känner igen.',
                      'Start the game and see how many places you recognize.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      );
                    },
                    label: Text(lang.t('Starta spel', 'Start game')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
