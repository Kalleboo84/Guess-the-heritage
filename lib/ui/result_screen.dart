import 'package:flutter/material.dart';
import '../services/lang.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  const ResultScreen({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final acc = total == 0 ? 0 : ((score / total) * 100).round();
    return Scaffold(
      appBar: AppBar(title: Text(t('Resultat', 'Results'))),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${t('Poäng', 'Score')}: $score / $total',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${t('Träffsäkerhet', 'Accuracy')}: $acc%',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t('Till startsidan', 'Back to home')),
            ),
          ],
        ),
      ),
    );
  }
}
