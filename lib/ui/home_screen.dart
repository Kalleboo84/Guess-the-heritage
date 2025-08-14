import 'package:flutter/material.dart';
import '../services/background_music.dart';
import 'game_screen.dart';

/// Enkel språkväxel
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
    final subtitle = t('Kulturarvsquiz med bilder & musik',
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
                  // Topp: språk + musik
                  Row(
                    children: [
                      DropdownButton<AppLocale>(
                        value: _locale,
                        onChanged: (v) => setState(() => _locale = v ?? AppLocale.sv),
                        items: const [
                          DropdownMenuItem(value: AppLocale.sv, child: Text('SV')),
                          DropdownMenuItem(value: AppLocale.en, child: Text('EN')),
                        ],
                      ),
                      const Spacer(),
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
                  // 🔹 Pyramid-ikon från assets/icons/
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icons/pyramid.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
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
  Widge
