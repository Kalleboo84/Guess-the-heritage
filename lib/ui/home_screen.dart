import 'package:flutter/material.dart';

// Viktigt: använd package-import så vi inte får två separata instanser av musiktjänsten.
import 'package:guess_the_heritage/services/background_music.dart' as music;
import '../services/lang.dart' as i18n;

import 'game_screen.dart';
import 'widgets/language_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    i18n.lang.addListener(_onChange);
    music.BackgroundMusic.instance.addListener(_onChange);
  }

  void _onChange() => setState(() {});
  @override
  void dispose() {
    i18n.lang.removeListener(_onChange);
    music.BackgroundMusic.instance.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = i18n.t('Gissa kulturarvet', 'Guess the Heritage');

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _LeafBackground(), // 🌿 blad-bakgrund
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _SoundToggle(),
                      LanguageMenu(),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 260,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GameScreen()),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: Text(
                        i18n.t('Starta spel', 'Start game'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    i18n.t(
                      'Tips: Du kan byta språk och stänga av/på musik uppe i hörnen.',
                      'Tip: You can change language and toggle music in the top corners.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌿 Blad-bakgrund på mjuk gradient
class _LeafBackground extends StatelessWidget {
  const _LeafBackground();

  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFFE8F5E9), const Color(0xFFFFFFFF)];
    const leaves = _leafs;

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            for (final leaf in leaves)
              Positioned(
                top: leaf.top,
                left: leaf.left,
                child: Transform.rotate(
                  angle: leaf.angle,
                  child: Icon(
                    Icons.eco_rounded,
                    size: leaf.size,
                    color: Colors.teal.withOpacity(leaf.opacity),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeafSpec {
  final double top, left, size, angle, opacity;
  const _LeafSpec(this.top, this.left, this.size, this.angle, this.opacity);
}

const _leafs = <_LeafSpec>[
  _LeafSpec(40, 24, 56, 0.5, 0.20),
  _LeafSpec(120, 300, 84, -0.7, 0.15),
  _LeafSpec(220, 40, 42, 0.3, 0.12),
  _LeafSpec(340, 200, 96, 0.9, 0.10),
  _LeafSpec(480, 16, 64, -0.4, 0.14),
  _LeafSpec(520, 280, 52, 0.2, 0.16),
  _LeafSpec(640, 180, 76, -0.9, 0.12),
];

/// 🔊 Ljudknapp (på/av) — etiketten följer alltid live-tillståndet.
class _SoundToggle extends StatelessWidget {
  const _SoundToggle();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: music.BackgroundMusic.instance.enabledNotifier,
      builder: (_, on, __) {
        final label = on ? i18n.t('Ljud på', 'Sound on') : i18n.t('Ljud av', 'Sound off');
        final icon = on ? Icons.volume_up_rounded : Icons.volume_off_rounded;

        return Material(
          elevation: 4,
          shape: const StadiumBorder(),
          color: Colors.white,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => music.BackgroundMusic.instance.toggle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: on ? Colors.teal : Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: on ? Colors.teal : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
