import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/lang.dart';
import 'ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lang.load(); // ladda ev. sparat språkval
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
    lang.addListener(_onLang);
  }

  void _onLang() => setState(() {});
  @override
  void dispose() {
    lang.removeListener(_onLang);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess the Heritage',
      debugShowCheckedModeBanner: false,
      // ✅ Språk
      locale: lang.materialLocale(),
      supportedLocales: const [Locale('en'), Locale('sv')], // engelska alltid med
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Om du vill: följ systemets språk om inget override är valt
      localeResolutionCallback: (device, supported) {
        if (lang.followingSystem && device != null) {
          if (device.languageCode.toLowerCase() == 'sv') {
            return const Locale('sv');
          }
        }
        return const Locale('en');
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
