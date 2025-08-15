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

  int _score = 0;    // rätt
  int _wrong = 0;    // fel
  int _lifelines = 3;
  int _answered = 0; // besvarade frågor (för accuracy)

  String? _selected;
  bool _showResult = false;
  bool _loading = true;

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

  void _useLifeline() {
    if (_lifelines <= 0) return;
    setState(() => _lifelines--); // enkel räknare
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

    // Avsluta direkt efter tre fel → till ResultScreen
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
      });
    } else {
      // slut på omgången
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
          TextButton.icon(
            onPressed: _lifelines > 0 ? _useLifeline : null,
            icon: const Icon(Icons.favorite, size: 18),
            label: Text(t('Livlinor: $_lifelines', 'Lifelines: $_lifelines')),
          ),
          const SizedBox(width: 8),
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
                const Icon(Icons.favorite, size: 18),
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
            Color? bg;
            if (_showResult && selected) {
              bg = isCorrect ? Colors.green.shade200 : Colors.red.shade200;
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bg,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onPressed: _showResult ? null : () => setState(() => _selected = choice),
                child: Align(alignment: Alignment.centerLeft, child: Text(choice)),
              ),
            );
          }),

          const SizedBox(height: 8),
          if (!_showResult)
            FilledButton(
              onPressed: _selected == null ? null : _lockAnswer,
              child: Text(t('Lås svar', 'Lock answer')),
            ),

          if (_showResult) ...[
            const SizedBox(height: 8),
            Text(
              _selected == q.answer
                  ? t('Rätt svar! 🎉', 'Correct! 🎉')
                  : t('Fel. Rätt var: ${q.answer}', 'Wrong. Correct: ${q.answer}'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Visa inte "Nästa" om spelet redan avslutas pga 3 fel
            if (_wrong < 3)
              FilledButton.icon(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _next,
                label: Text(t('Nästa fråga', 'Next question')),
              ),
          ],

          const SizedBox(height: 24),
          if (q.attribution.isNotEmpty && q.attribution != 'TBD')
            Text(
              q.attribution,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

class _QuestionImageBlock extends StatelessWidget {
  final Question question;
  final AppLocale locale;
  const _QuestionImageBlock({required this.question, required this.locale});

  String t(String sv, String en) => locale == AppLocale.sv ? sv : en;

  @override
  Widget build(BuildContext context) {
    final hasUrl = question.imageUrl.isNotEmpty && question.imageUrl != 'TBD';

    final Widget img = hasUrl
        ? Image.network(
            question.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(context),
          )
        : _placeholder(context);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: img,
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFDDF3E4), Color(0xFFC1E9D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 48, color: Colors.black.withOpacity(0.35)),
            const SizedBox(height: 8),
            Text(
              t('Ingen bild ännu', 'No image yet'),
              style: TextStyle(color: Colors.black.withOpacity(0.55)),
            ),
          ],
        ),
      ),
    );
  }
}
