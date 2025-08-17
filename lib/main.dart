import 'package:flutter/material.dart';
import 'package:guess_the_heritage/ui/home_screen.dart'; // korrekt package-import
import 'services/background_music.dart' as music;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initiera bakgrundsmusiken (påverkar inte UI)
  await music.BackgroundMusic.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // Inga UI-förändringar här, bara visar startsidan
      home: HomeScreen(),
    );
  }
}
