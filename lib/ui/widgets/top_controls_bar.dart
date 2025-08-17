import 'package:flutter/material.dart';
import 'package:guess_the_heritage/services/background_music.dart' as music;
import '../../services/lang.dart' as i18n;
import 'language_menu.dart';

/// Gemensam topprad: [Ljudknapp] .............. [Språk-meny]
/// Används både på HomeScreen och GameScreen.
class TopControlsBar extends StatelessWidget {
  const TopControlsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SoundToggle(),
            LanguageMenu(),
          ],
        ),
      ),
    );
  }
}

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
