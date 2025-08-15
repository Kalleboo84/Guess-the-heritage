import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'question.dart';

class QuestionRepository {
  static Future<List<Question>> loadFromAssets() async {
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = (data['questions'] as List).cast<Map<String, dynamic>>();
    return list.map(Question.fromJson).toList();
  }
}
