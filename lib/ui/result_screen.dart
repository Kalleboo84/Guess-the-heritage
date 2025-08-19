import 'package:flutter/material.dart';
import '../services/lang.dart' as i18n;
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int correct;
  final int wrong;
  final int total;

  const ResultScreen({
    super.key,
    required this.correct,
    required this.wrong,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final acc = total == 0 ? 0 : ((correct / total) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.t('Resultat', 'Results')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                i18n.t('Bra kämpat!', 'Well played!'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _StatRow(
                label: i18n.t('Rätt', 'Correct'),
                value: '$correct / $total',
              ),
              const SizedBox(height: 8),
              _StatRow(
                label: i18n.t('Fel', 'Wrong'),
                value: '$wrong',
              ),
              const SizedBox(height: 8),
              _StatRow(
                label: i18n.t('Träffsäkerhet', 'Accuracy'),
                value: '$acc%',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Till startsidan
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    i18n.t('Till start', 'Back to start'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
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
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
