import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../services/lang.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Future<List<Question>> _future;
  int _index = 0;
  int _score = 0;
  int _mistakes = 0;          // Spelet avslutas vid 3 fel
  int _lifelines = 3;         // 50/50 livlinor kvar
  Set<int> _hiddenChoices = {}; // vilka val som döljs av 50/50 för aktuell fråga
  bool _locked = false;       // lås knappar under feedback

  @override
  void initState() {
    super.initState();
    _future = _loadQuestions();
  }

  Future<List<Question>> _loadQuestions() async {
    final s = await rootBundle.loadString('assets/data/questions.json');
    final data = json.decode(s) as Map<String, dynamic>;
    final list = (data['questions'] as List)
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  void _use5050(List<Question> qs) {
    if (_lifelines <= 0 || _hiddenChoices.isNotEmpty) return;
    final q = qs[_index];
    final correctIndex = q.choices.indexOf(q.answer);
    final wrongs = <int>[];
    for (var i = 0; i < q.choices.length; i++) {
      if (i != correctIndex) wrongs.add(i);
    }
    wrongs.shuffle(Random());
    setState(() {
      _hiddenChoices = wrongs.take(2).toSet();
      _lifelines -= 1;
    });
  }

  Future<void> _answer(List<Question> qs, int choiceIndex) async {
    if (_locked) return;
    setState(() => _locked = true);

    final q = qs[_index];
    final correct = q.choices[choiceIndex] == q.answer;

    if (correct) {
      setState(() => _score += 1);
    } else {
      setState(() => _mistakes += 1);
    }

    // snabb feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 600),
        content: Text(correct ? t('Rätt!', 'Correct!') : t('Fel!', 'Wrong!')),
        backgroundColor: correct ? Colors.teal : Colors.redAccent,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 650));

    // Slutlogik
    if (_mistakes >= 3) {
      await _showEndDialog(qs.length, isGameOver: true);
      if (!mounted) return;
      Navigator.of(context).pop(); // tillbaka till startsidan
      return;
    }

    if (_index >= qs.length - 1) {
      await _showEndDialog(qs.length, isGameOver: false);
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _index += 1;
      _hiddenChoices.clear();
      _locked = false;
    });
  }

  Future<void> _showEndDialog(int total, {required bool isGameOver}) async {
    final acc = total == 0 ? 0 : ((_score / total) * 100).round();
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isGameOver ? t('Spelet över', 'Game over') : t('Resultat', 'Results')),
        content: Text('${t('Poäng', 'Score')}: $_score / $total\n${t('Träffsäkerhet', 'Accuracy')}: $acc%'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('OK', 'OK')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Question>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(t('Laddar…', 'Loading…'))),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final qs = snap.data!;
        final q = qs[_index];

        // Endast "1/XX" – ingen "Question …"
        final progress = '${_index + 1}/${qs.length}';

        return Scaffold(
          appBar: AppBar(
            title: Text(progress),
            centerTitle: true,
            actions: [
              // 👉 50/50-knappen i övre högra hörnet
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FiftyFiftyButton(
                  remaining: _lifelines,
                  onPressed: _hiddenChoices.isEmpty && _lifelines > 0
                      ? () => _use5050(qs)
                      : null,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Bild
              if (q.imageUrl != null && q.imageUrl!.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    q.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: Center(child: Text(t('Bild kunde inte laddas', 'Image failed to load'))),
                    ),
                  ),
                ),
              if (q.attribution != null && q.attribution!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      q.attribution!,
                      style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.6)),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),

              // Frågetext
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  q.question,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),

              // Svarsalternativ
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: q.choices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final hidden = _hiddenChoices.contains(i);
                    return Opacity(
                      opacity: hidden ? 0.25 : 1,
                      child: IgnorePointer(
                        ignoring: hidden || _locked,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _answer(qs, i),
                          child: Text(q.choices[i]),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Statusrad: Poäng + Fel kvar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatPill(
                      label: t('Poäng', 'Score'),
                      value: '$_score',
                      color: Colors.teal,
                    ),
                    _StatPill(
                      label: t('Fel kvar', 'Mistakes left'),
                      value: '${3 - _mistakes}',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Question {
  final String question;
  final List<String> choices;
  final String answer;
  final String? imageUrl;
  final String? attribution;
  final String? century;

  Question({
    required this.question,
    required this.choices,
    required this.answer,
    this.imageUrl,
    this.attribution,
    this.century,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        question: j['question'] as String,
        choices: (j['choices'] as List).cast<String>(),
        answer: j['answer'] as String,
        imageUrl: (j['imageUrl'] as String?) ?? '',
        attribution: (j['attribution'] as String?) ?? '',
        century: (j['century'] as String?) ?? '',
      );
}

/// Liten “pill” för statistik
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.10),
      elevation: 0,
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.45))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
            const SizedBox(width: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}

/// 50/50-knappen med badge (antal kvar)
class _FiftyFiftyButton extends StatelessWidget {
  final int remaining;
  final VoidCallback? onPressed;
  const _FiftyFiftyButton({required this.remaining, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          elevation: 3,
          color: Colors.white,
          shape: const CircleBorder(),
          child: IconButton(
            tooltip: '${t('Livlina 50/50', 'Lifeline 50/50')} ($remaining)',
            onPressed: onPressed,
            icon: const Text('50/50', style: TextStyle(fontWeight: FontWeight.w700)),
            color: disabled ? Colors.grey : Colors.teal,
          ),
        ),
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: disabled ? Colors.grey : Colors.teal,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$remaining',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
