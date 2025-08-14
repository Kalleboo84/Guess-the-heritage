import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess the Heritage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4B8053),
          brightness: Brightness.light,
          primary: const Color(0xFF4B8053),
          secondary: const Color(0xFFE4F2E1),
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F2E1),
      appBar: AppBar(
        title: const Text('Guess the Heritage'),
        backgroundColor: const Color(0xFF4B8053),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Starta spel'),
                onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const QuizScreen())),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Inställningar'),
                onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.info_outline),
                label: const Text('Om'),
                onPressed: () => showAboutDialog(
                  context: context,
                  applicationName: 'Guess the Heritage',
                  applicationVersion: '0.1.0',
                  children: const [Text('Ett mjukt, grönt quiz om världens kulturarv.')],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  bool musicOn = true;
  double volume = 0.6;
  String language = 'sv';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inställningar'),
        backgroundColor: const Color(0xFF4B8053),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Musik'),
            value: musicOn,
            onChanged: (v) => setState(() => musicOn = v),
          ),
          ListTile(
            title: const Text('Volym'),
            subtitle: Slider(
              value: volume, onChanged: (v) => setState(() => volume = v), min: 0, max: 1),
          ),
          ListTile(
            title: const Text('Språk (demo)'),
            subtitle: DropdownButton<String>(
              value: language,
              onChanged: (v) { if (v != null) setState(() => language = v); },
              items: const [
                DropdownMenuItem(value: 'sv', child: Text('Svenska')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Fler språk och kartvy kommer i nästa version.'),
          )
        ],
      ),
    );
  }
}

class QuizItem {
  final String id;
  final Map<String, dynamic> titles, country, coords, wikipedia, image, options, answerKey;
  final int century;
  final String continent, region, iso2;
  QuizItem({
    required this.id,
    required this.titles,
    required this.country,
    required this.coords,
    required this.century,
    required this.wikipedia,
    required this.image,
    required this.options,
    required this.answerKey,
    required this.continent,
    required this.region,
    required this.iso2,
  });
  factory QuizItem.fromJson(Map<String, dynamic> j) => QuizItem(
    id: j['id'],
    titles: j['titles'],
    country: j['country'],
    coords: Map<String, dynamic>.from(j['coords']),
    century: j['century'],
    wikipedia: j['wikipedia'],
    image: j['image'],
    options: j['options'],
    answerKey: j['answer_key'],
    continent: j['continent'] ?? '',
    region: j['region'] ?? '',
    iso2: j['iso2'] ?? '',
  );
  String title(String lang) => (titles[lang] ?? titles['en']) as String;
  List<dynamic> opts(String lang) => (options[lang] ?? options['en']) as List<dynamic>;
  String correct(String lang) => (answerKey[lang] ?? answerKey['en']) as String;
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}
class _QuizScreenState extends State<QuizScreen> {
  List<QuizItem> _all = [];
  int _index = 0, _score = 0, _lifelines = 3;
  String _lang = 'sv';
  final _audio = AudioPlayer();
  final List<String> _tracks = []; // lägg filer i assets/audio och lista dem här
  bool _musicStarted = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _startMusicIfNeeded() async {
    if (_musicStarted || _tracks.isEmpty) return;
    _musicStarted = true;
    int current = 0;
    await _audio.setVolume(0.6);
    await _audio.play(AssetSource(_tracks[current]));
    _audio.onPlayerComplete.listen((_) async {
      current = (current + 1) % _tracks.length;
      await _audio.play(AssetSource(_tracks[current])); // spelar klart, byter spår
    });
  }

  Future<void> _load() async {
    final s = await rootBundle.loadString('assets/data/questions.json');
    final j = json.decode(s);
    final list = (j['questions'] as List).map((e) => QuizItem.fromJson(e)).toList();
    list.shuffle(Random());
    _all = list.take(30).toList(); // 30 frågor per runda
    setState(() {});
    await _startMusicIfNeeded();
  }

  void _answer(String choice) {
    final item = _all[_index];
    final correct = item.correct(_lang);
    final isCorrect = choice == correct;
    if (isCorrect) _score++;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCorrect ? 'Rätt!' : 'Fel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rätt svar: $correct'),
            const SizedBox(height: 8),
            Text('Land: ${item.country[_lang] ?? item.country['en']}'),
            Text('Kontinent: ${item.continent}'),
            Text('Århundrade: ${item.century > 0 ? "${item.century}:e" : "${-item.century}:e f.Kr."}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _index++;
                if (_index >= _all.length) {
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => ResultScreen(score: _score, total: _all.length)));
                }
              });
            },
            child: const Text('Nästa'),
          )
        ],
      ),
    );
  }

  void _useLifeline() {
    if (_lifelines <= 0) return;
    setState(() => _lifelines--);
  }

  @override
  Widget build(BuildContext context) {
    if (_all.isEmpty || _index >= _all.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Laddar...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final item = _all[_index];
    final opts = List<String>.from(item.opts(_lang));
    final displayOpts = _lifelines < 3 ? _reduceOptions(opts, item.correct(_lang)) : opts;

    return Scaffold(
      backgroundColor: const Color(0xFFE4F2E1),
      appBar: AppBar(
        title: Text('Fråga ${_index + 1} / ${_all.length}'),
        backgroundColor: const Color(0xFF4B8053),
        foregroundColor: Colors.white,
        actions: [Center(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('Poäng: $_score')))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Livlinor: $_lifelines'), Text('Kontinent: ${item.continent}'),
          ]),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6EE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4B8053).withOpacity(0.2)),
            ),
            alignment: Alignment.center,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Bild från Wikimedia hämtas i nästa version'),
            ),
          ),
          const SizedBox(height: 12),
          ...displayOpts.map((o) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              onPressed: () => _answer(o),
              child: Padding(padding: const EdgeInsets.all(12.0), child: Text(o)),
            ),
          )),
          const Spacer(),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: _lifelines > 0 ? _useLifeline : null,
              icon: const Icon(Icons.spa),
              label: const Text('Livlina (-2 svar)'),
            )),
          ]),
        ]),
      ),
    );
  }

  List<String> _reduceOptions(List<String> opts, String correct) {
    final wrong = opts.where((e) => e != correct).toList()..shuffle();
    final keepWrong = wrong.take(1).toList();
    final reduced = [correct, ...keepWrong]..shuffle();
    return reduced;
  }
}

class ResultScreen extends StatelessWidget {
  final int score, total;
  const ResultScreen({super.key, required this.score, required this.total});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4F2E1),
      appBar: AppBar(
        title: const Text('Resultat'),
        backgroundColor: const Color(0xFF4B8053),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Du fick $score av $total rätt!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false),
            child: const Text('Till startsidan'),
          )
        ]),
      ),
    );
  }
}
