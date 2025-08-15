import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// OBS! Måste matcha 'name:' i pubspec.yaml.
// Om din pubspec säger name: guess_heritage — behåll raden nedan.
// Annars: ändra till package:<ditt_paketnamn>/main.dart
import 'package:guess_heritage/main.dart';

void main() {
  testWidgets('Appen bygger en MaterialApp', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
