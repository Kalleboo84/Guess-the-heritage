import 'package:flutter/material.dart';
import '../../services/lang.dart';

class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final label = lang.t('Språk', 'Language');
    final following = lang.followingSystem;

    String currentText() {
      if (following) return lang.t('Följer system', 'Follow system');
      return lang.current == AppLocale.sv ? 'Svenska' : 'English';
    }

    return PopupMenuButton<String>(
      tooltip: '$label: ${currentText()}',
      icon: const Icon(Icons.language),
      onSelected: (val) async {
        switch (val) {
          case 'system':
            await lang.setOverride(null);
            break;
          case 'en':
            await lang.setOverride(AppLocale.en);
            break;
          case 'sv':
            await lang.setOverride(AppLocale.sv);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'system',
          child: Row(
            children: [
              if (following) const Icon(Icons.check, size: 18),
              if (!following) const SizedBox(width: 18),
              const SizedBox(width: 6),
              Text(lang.t('Följ systemspråk', 'Follow system language')),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              if (!following && lang.current == AppLocale.en) const Icon(Icons.check, size: 18),
              if (following || lang.current != AppLocale.en) const SizedBox(width: 18),
              const SizedBox(width: 6),
              const Text('English'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'sv',
          child: Row(
            children: [
              if (!following && lang.current == AppLocale.sv) const Icon(Icons.check, size: 18),
              if (following || lang.current != AppLocale.sv) const SizedBox(width: 18),
              const SizedBox(width: 6),
              const Text('Svenska'),
            ],
          ),
        ),
      ],
    );
  }
}
