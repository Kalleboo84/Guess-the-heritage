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
    // Viktigt: inte const MaterialApp (annars "invalid constant" om något inuti inte är helt const)
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
