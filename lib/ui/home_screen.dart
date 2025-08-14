import 'package:flutter/material.dart';
import '../services/background_music.dart';
import 'game_screen.dart';

enum AppLocale { sv, en }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppLocale _locale = AppLocale.sv;
  bool _musicOn = true;

  String t(String sv, String en) => _locale == AppLocale.sv ? sv : en;

  @override
  void initState() {
    super.initState();
    // Starta musiken på startsidan
    BackgroundMusic.instance.ensureStarted();
  }

  @override
  Widget build(BuildContext context) {
    final title = t('Guess the Heritage', 'Guess the Heritage');
    final subtitle = t('Kulturarvsquiz med bilder & ljud',
                       'Cultural Heritage Quiz with images & music');

    return Scaffold(
      body: Stack(
        children: [
          const _LeafBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Översta raden: språk + musik
                  Row(
                    children: [
                      // Språkval
                      DropdownButton<AppLocale>(
                        value: _locale,
                        onChanged: (v) => setState(() => _locale = v ?? AppLocale.sv),
                        items: const [
                          DropdownMenuItem(value: AppLocale.sv, child: Text('SV')),
                          DropdownMenuItem(value: AppLocale.en, child: Text('EN')),
                        ],
                      ),
                      const Spacer(),
                      // Musik av/på
                      Row(
                        children: [
                          Icon(_musicOn ? Icons.music_note : Icons.music_off),
                          Switch(
                            value: _musicOn,
                            onChanged: (v) async {
                              setState(() => _musicOn = v);
                              await BackgroundMusic.instance.setMuted(!v);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Titel och underrad
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  // Startknapp
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text(t('Starta spel', 'Start Game')),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameScreen(locale: _locale),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Sekundära knappar (kan kopplas senare)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: Text(t('Inställningar', 'Settings')),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.info_outline),
                        label: Text(t('Om', 'About')),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafBackground extends StatelessWidget {
  const _LeafBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE6F4EA), Color(0xFFCDEFD8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: List.generate(14, (i) {
          final double top = (i * 70) % (MediaQuery.of(context).size.height);
          final double left = (i * 40) % (MediaQuery.of(context).size.width);
          final double size = 40 + (i % 5) * 12;
          return Positioned(
            top: top,
            left: left,
            child: Icon(
              Icons.eco,
              size: size,
              color: Colors.green.withOpacity(0.08 + (i % 4) * 0.03),
            ),
          );
        }),
      ),
    );
  }
}
