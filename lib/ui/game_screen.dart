import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../services/lang.dart' as i18n;
import 'widgets/top_controls_bar.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<_Question> _questions = [];
  int _index = 0;
  int _correct = 0;
  int _wrong = 0;

  // 50/50
  int _lifelines = 3;
  Set<int> _disabledChoiceIdx = <int>{};

  // Markering av valt svar (för att låsa mellan klick och nästa)
  int? _selectedIdx;
  bool _answered = false;

  bool get _loaded => _questions.isNotEmpty;
  int get _total => _questions.length;
  _Question get _q => _questions[_index];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/questions.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final items = data['questions'] as List<dynamic>;
      final qs = items
          .map((e) => _Question.fromJson(e as Map<String, dynamic>))
          .where((q) => q.choices.length == 4)
          .toList();

      setState(() {
        _questions
          ..clear()
          ..addAll(qs);
      });
    } catch (e) {
      // Om något går fel, visa ett minimalt fallback.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(i18n.t('Kunde inte ladda frågor.', 'Failed to load questions.'))),
        );
      }
    }
  }

  void _use5050() {
    if (_lifelines <= 0 || !_loaded) return;
    // Ta bort två felaktiga alternativ slumpmässigt.
    final correctIdx = _q.choices.indexOf(_q.answer);
    final wrongs = <int>[0, 1, 2, 3]..remove(correctIdx);
    wrongs.shuffle(Random());
    setState(() {
      _lifelines -= 1;
      // Inaktivera två första felaktiga
      _disabledChoiceIdx = wrongs.take(2).toSet();
    });
  }

  void _onAnswerTap(int idx) {
    if (_answered || !_loaded) return;
    setState(() {
      _answered = true;
      _selectedIdx = idx;

      final tapped = _q.choices[idx];
      final isCorrect = tapped == _q.answer;
      if (isCorrect) {
        _correct++;
      } else {
        _wrong++;
      }
    });

    // Avsluta efter 3 fel -> tillbaka till startsidan
    if (_wrong >= 3) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.of(context).pop(); // Tillbaka till HomeScreen
      });
      return;
    }

    // Nästa fråga efter kort delay
    Future.delayed(const Duration(milliseconds: 600), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    setState(() {
      _answered = false;
      _selectedIdx = null;
      _disabledChoiceIdx.clear();

      _index = (_index + 1).clamp(0, _total == 0 ? 0 : _total - 1);
      // Om sista frågan var besvarad, börja om från 0 (eller navigera till resultatvy om du vill)
      if (_index == _total - 1 && _answered == false) {
        // Låt det fortsätta snurra; vill du avsluta på slutet kan du Navigera här.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔝 Samma toppkontroller (ljud + språk) som på startsidan
          const TopControlsBar(),

          // Själva spelinnehållet – med luft under toppraden
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 56.0),
              child: _loaded ? _buildGameBody() : _buildLoading(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildGameBody() {
    // Progress "1/50" (ingen text "Question")
    final progress = '${_index + 1}/${_total}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Rad: Progress i mitten, 50/50-livlina till höger
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Poäng till vänster (valfritt men uppskattat)
              Text(
                i18n.t('Poäng: $_correct', 'Score: $_correct'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                progress,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _FiftyButton(
                remaining: _lifelines,
                onPressed: _lifelines > 0 ? _use5050 : null,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Bild
        if (_q.imageUrl != null && _q.imageUrl!.isNotEmpty)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _q.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: Text(
                    i18n.t('Ingen bild', 'No image'),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ),
          )
        else
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              i18n.t('Ingen bild', 'No image'),
              style: const TextStyle(color: Colors.black54),
            ),
          ),

        const SizedBox(height: 12),

        // Frågetext
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _q.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Svarsknappar
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, idx) {
              final choice = _q.choices[idx];
              final isDisabled = _disabledChoiceIdx.contains(idx);
              final isSelected = _selectedIdx == idx;
              final isCorrect = choice == _q.answer;

              Color bg = Colors.white;
              Color border = Colors.grey.shade300;
              if (_answered && isSelected) {
                bg = isCorrect ? Colors.green.shade50 : Colors.red.shade50;
                border = isCorrect ? Colors.green : Colors.red;
              }

              return Opacity(
                opacity: isDisabled ? 0.45 : 1.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: bg,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: border),
                    ),
                  ),
                  onPressed: isDisabled || _answered
                      ? null
                      : () => _onAnswerTap(idx),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      choice,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Attribution (om finns)
        if (_q.attribution != null && _q.attribution!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              _q.attribution!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }
}

/// 50/50-knapp med räknare (3 → 2 → 1 → 0)
class _FiftyButton extends StatelessWidget {
  final int remaining;
  final VoidCallback? onPressed;

  const _FiftyButton({
    required this.remaining,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${i18n.t('Livlina 50/50', 'Lifeline 50/50')} ($remaining)';

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.help_outline_rounded),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Inre datamodell för frågan (endast vad vi använder här)
class _Question {
  final String question;
  final List<String> choices;
  final String answer;
  final String? imageUrl;
  final String? attribution;
  final String? century;

  _Question({
    required this.question,
    required this.choices,
    required this.answer,
    this.imageUrl,
    this.attribution,
    this.century,
  });

  factory _Question.fromJson(Map<String, dynamic> m) {
    final rawChoices = (m['choices'] as List<dynamic>).cast<String>();
    return _Question(
      question: m['question'] as String,
      choices: List<String>.from(rawChoices),
      answer: m['answer'] as String,
      imageUrl: m['imageUrl'] as String?,
      attribution: m['attribution'] as String?,
      century: m['century'] as String?,
    );
  }
}
