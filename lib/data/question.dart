class Question {
  final String question;
  final List<String> choices;
  final String answer;
  final String imageUrl;
  final String attribution;
  final String century;

  Question({
    required this.question,
    required this.choices,
    required this.answer,
    required this.imageUrl,
    required this.attribution,
    required this.century,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String,
      choices: (json['choices'] as List).cast<String>(),
      answer: json['answer'] as String,
      imageUrl: (json['imageUrl'] as String?)?.trim() ?? '',
      attribution: (json['attribution'] as String?)?.trim() ?? '',
      century: (json['century'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'choices': choices,
        'answer': answer,
        'imageUrl': imageUrl,
        'attribution': attribution,
        'century': century,
      };
}
