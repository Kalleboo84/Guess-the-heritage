import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'game_screen.dart';

class ResultScreen extends StatelessWidget {
  final int correct;
  final int wrong;
  final int total;      // antal besvarade frågor
  final AppLocale locale;

  const ResultScreen({
    super.key,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.locale,
  });

  String t(String sv, String en) => locale == AppLocale.sv ? sv : en;

  @override
  Widget build(BuildContext context) {
    final double acc = total > 0 ? correct / total : 0;
    final percent = (acc * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: Text(t('Resultat', 'Results'))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t('Snyggt!', 'Nice!'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  t('Du svarade på $total frågor.', 'You answered $total questions.'),
                ),
                const SizedBox(height: 24),
                _StatRow(label: t('Rätt', 'Correct'), value: '$correct'),
                _StatRow(label: t('Fel', 'Wrong'), value: '$wrong'),
                _StatRow(label: t('Träffsäkerhet', 'Accuracy'), value: '$percent%'),
                const SizedBox(height: 28),
                FilledButton.icon(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    Navigator.of(context).popUntil((r) => r.isFirst); // till start
                  },
                  label: Text(t('Till start', 'Home')),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    // Spela igen direkt
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(locale: locale),
                      ),
                    );
                  },
                  label: Text(t('Spela igen', 'Play again')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Color(0x14000000))],
      ),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
