import 'dart:math';
import 'package:flutter/material.dart';
import '../data/question.dart';
import '../data/question_repository.dart';
import '../services/background_music.dart';
import 'home_screen.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final AppLocale locale;
  const GameScreen({super.key, required this.locale});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _rng = Random();
  List<Question> _questions = [];
  int _index = 0;

  int _score = 0;      // rätt
  int _wrong = 0;      // fel
  int _lifelines = 3;  // 50/50 kvar totalt
  int _answered = 0;   // besvarade (för accuracy)

  String? _selected;
  bool _showResult = false;
  bool _loading = true;

  // 50/50: vilka val som är eliminerade på aktuell fråga
  final Set<String> _eliminated = {};

  String t(String sv, String en) => widget.locale == AppLocale.sv ? sv : en;

  @override
  void initState() {
    super.initState();
    _load();
    BackgroundMusic.instance.ensureStarted();
  }

  Future<void> _load() async {
    final all = await QuestionRepository.loadFromAssets();
    all.shuffle(_rng);
    _questions = all.take(30).toList();
    setState(() => _loading = false);
  }

  void _useFiftyFifty() {
    if (_lifelines <= 0 || _showResult) return;

    final q = _questions[_index];
    final wrongs = q.choices
        .where((c) => c != q.answer && !_eliminated.contains(c))
        .toList();

    wrongs.shuffle(_rng);
    final toRemove = wrongs.take(2).toList();
    if (toRemove.isEmpty) return;

    setState(() {
      _eliminated.addAll(toRemove);
      _lifelines -= 1;
      if (_selected != null && _eliminated.contains(_selected!)) {
        _selected = null;
      }
    });
  }

  void _lockAnswer() {
    if (_selected == null) return;
    final q = _questions[_index];
    final correct = _selected == q.answer;
    setState(() {
      _showResult = true;
      _answered += 1;
      if (correct) {
        _score += 1;
      } else {
        _wrong += 1;
      }
    });

    // Avsluta efter tre fel → Resultatsidan
    if (!correct && _wrong >= 3) {
      Future.delayed(const Duration(milliseconds: 350), _goToResult);
    }
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _showResult = false;
        _eliminated.clear(); // ny fråga
      });
    } else {
      _goToResult();
    }
  }

  void _goToResult() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          correct: _score,
          wrong: _wrong,
          total: _answered,
          locale: widget.locale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(t('Spel', 'Game'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final q = _questions[_index];
    final total = _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('Fråga ${_index + 1} av $total', 'Question ${_index + 1} of $total')),
        actions: [
          // 🔶 Tydlig, beskrivande 50/50-knapp med tooltip
          Tooltip(
            message: t('Livlina 50/50: döljer två felaktiga svar.',
                       'Lifeline 50/50: hides two wrong choices.'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: FilledButton.tonalIcon(
                onPressed: (_lifelines > 0 && !_showResult) ? _useFiftyFifty : null,
                icon: const Icon(Icons.percent, size: 18),
                label: Text(t('Livlina 50/50', 'Lifeline 50/50') + ' ($_lifelines)'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _QuestionImageBlock(question: q, locale: widget.locale),
          const SizedBox(height: 12),

          // Scoreboard
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(blurRadius: 6, color: Color(0x14000000))],
            ),
            child: Row(
              children: [
                const Icon(Icons.stars),
                const SizedBox(width: 6),
                Text(t('Poäng: $_score', 'Score: $_score')),
                const SizedBox(width: 16),
                const Icon(Icons.close),
                const SizedBox(width: 6),
                Text(t('Fel: $_wrong/3', 'Wrong: $_wrong/3')),
                const Spacer(),
                const Icon(Icons.percent, size: 18),
                const SizedBox(width: 6),
                Text('$_lifelines'),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text(q.question, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          ...q.choices.map((choice) {
            final selected = _selected == choice;
            final isCorrect = choice == q.answer;
            final isEliminated = _eliminated.contains(choice);

            Color? bg;
            if (_showResult && selected) {
              bg = isCorrect ? Colors.green.shade200 : Colors.red.shade200;
            }

            final textStyle = isEliminated
                ? const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.black54,
                  )
                : null;

            return Opacity(
              opacity: isEliminated ? 0.5 : 1.0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14
