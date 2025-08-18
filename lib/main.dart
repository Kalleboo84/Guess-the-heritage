import 'package:flutter/material.dart';
import 'package:guess_the_heritage/ui/home_screen.dart';
import 'package:guess_the_heritage/services/background_music.dart' as music;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // ✅ Starta bakgrundsmusiken direkt när appen startar (loopar vidare).
    music.BackgroundMusic.instance.ensureStarted();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
