import 'package:flutter/material.dart';
import 'package:guess_the_heritage/ui/home_screen.dart';
import 'package:guess_the_heritage/services/background_music.dart' as music;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await music.BackgroundMusic.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Enda ändringen: MaterialApp är nu const (ingen UI-förändring)
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
