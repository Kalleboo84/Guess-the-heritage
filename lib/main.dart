import 'dart:async';
import 'package:flutter/material.dart';
import 'package:guess_the_heritage/ui/home_screen.dart';
import 'package:guess_the_heritage/services/background_music.dart' as music;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Rita UI direkt
  runApp(const MyApp());

  // Initiera bakgrundsmusiken i bakgrunden (blockerar inte start)
  unawaited(music.BackgroundMusic.instance.init());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
