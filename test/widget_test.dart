import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Måste matcha name: i pubspec.yaml (guess_the_heritage)
import 'package:guess_the_heritage/main.dart';

void main() {
  testWidgets('Appen bygger en MaterialApp', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
