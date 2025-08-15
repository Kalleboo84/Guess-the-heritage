import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importera din app direkt från lib med relativ sökväg
import '../lib/main.dart';

void main() {
  testWidgets('Appen bygger en MaterialApp', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
