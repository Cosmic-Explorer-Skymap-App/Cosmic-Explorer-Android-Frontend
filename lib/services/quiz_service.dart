import '../models/quiz_question.dart';

class QuizService {
  final List<QuizQuestion> questions;
  int _currentIndex = 0;
  int _score = 0;
  final List<int?> _answers = [];

  QuizService(this.questions) {
    _answers.addAll(List.filled(questions.length, null));
  }

  int get currentIndex => _currentIndex;
  int get score => _score;
  int get totalQuestions => questions.length;
  bool get isFinished => _currentIndex >= questions.length;
  QuizQuestion get currentQuestion => questions[_currentIndex];
  List<int?> get answers => List.unmodifiable(_answers);
  double get scorePercentage =>
      totalQuestions > 0 ? (_score / totalQuestions) * 100 : 0;

  bool answer(int selectedIndex) {
    if (isFinished) return false;
    _answers[_currentIndex] = selectedIndex;
    final correct = questions[_currentIndex].isCorrect(selectedIndex);
    if (correct) _score++;
    return correct;
  }

  void nextQuestion() {
    if (_currentIndex < questions.length) {
      _currentIndex++;
    }
  }

  void reset() {
    _currentIndex = 0;
    _score = 0;
    for (int i = 0; i < _answers.length; i++) {
      _answers[i] = null;
    }
  }
}
