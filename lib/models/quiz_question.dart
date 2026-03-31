class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
  String get correctAnswer => options[correctIndex];

  QuizQuestion copyWith({
    String? question,
    List<String>? options,
    String? explanation,
  }) {
    return QuizQuestion(
      id: id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctIndex: correctIndex,
      explanation: explanation ?? this.explanation,
    );
  }
}
