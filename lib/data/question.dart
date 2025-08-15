class Question {
  final String question;
  final List<String> choices;
  final String answer;
  final String imageUrl;     // "TBD" om saknas
  final String attribution;  // "TBD" om saknas
  final String century;

  Question({
    required this.question,
    required this.choices,
    required this.answer,
    required this.imageUrl,
    required this.attribution,
    required this.century,
  });

  factory Question.fromJson(Map<String, dynamic> j) {
    return Question(
      question: j['question'] as String,
      choices: (j['choices'] as List).map((e) => e.toString()).toList(),
      answer: j['answer'] as String,
      imageUrl: (j['imageUrl'] ?? '').toString(),
      attribution: (j['attribution'] ?? '').toString(),
      century: (j['century'] ?? '').toString(),
    );
  }
}
