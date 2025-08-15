import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Viktigt: detta måste matcha name: i pubspec.yaml
// (jag utgår från: name: guess_heritage)
import 'package:guess_heritage/main.dart';

void main() {
  testWidgets('Appen bygger en MaterialApp', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
