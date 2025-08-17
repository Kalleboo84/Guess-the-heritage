import 'package:flutter/material.dart';
import '../../services/lang.dart';

/// Språkval: Svenska / English / Följ system (lagras i SharedPreferences)
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final code = lang.currentCode();
    final isSv = code.startsWith('sv');
    final isEn = code.startsWith('en');
    final following = lang.followingSystem;

    String currentText;
    if (following) {
      currentText = t('Systemspråk', 'System language');
    } else {
      currentText = isSv ? 'Svenska' : 'English';
    }

    return PopupMenuButton<String>(
      tooltip: t('Byt språk', 'Change language'),
      onSelected: (value) async {
        if (value == 'sv') {
          await lang.setLocale(const Locale('sv'));
        } else if (value == 'en') {
          await lang.setLocale(const Locale('en'));
        } else if (value == 'sys') {
          await lang.followSystem();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'sv',
          child: Row(
            children: [
              if (!following && isSv) const Icon(Icons.check, size: 18),
              if (!following && isSv) const SizedBox(width: 8),
              const Text('Svenska'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              if (!following && isEn) const Icon(Icons.check, size: 18),
              if (!following && isEn) const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'sys',
          child: Row(
            children: [
              if (following) const Icon(Icons.check, size: 18),
              if (following) const SizedBox(width: 8),
              Text(t('Följ systemspråk', 'Follow system language')),
            ],
          ),
        ),
      ],
      child: Material(
        elevation: 4,
        color: Colors.white,
        shape: StadiumBorder(side: BorderSide(color: Colors.teal.withOpacity(0.3))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, color: Colors.teal),
              const SizedBox(width: 8),
              Text(currentText, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
