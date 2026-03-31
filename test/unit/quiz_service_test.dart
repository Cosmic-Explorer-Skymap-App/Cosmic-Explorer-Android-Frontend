import 'package:flutter_test/flutter_test.dart';
import 'package:cosmic_explorer/models/quiz_question.dart';
import 'package:cosmic_explorer/services/quiz_service.dart';
import 'package:cosmic_explorer/data/quiz_data.dart';

void main() {
  group('QuizQuestion', () {
    test('isCorrect returns true for correct answer', () {
      const q = QuizQuestion(
        id: 'test_q',
        question: 'Test?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 2,
        explanation: 'Because.',
      );
      expect(q.isCorrect(2), true);
      expect(q.isCorrect(0), false);
      expect(q.isCorrect(3), false);
    });

    test('correctAnswer returns the right option', () {
      const q = QuizQuestion(
        id: 'test_q2',
        question: 'Test?',
        options: ['Alpha', 'Beta', 'Gamma'],
        correctIndex: 1,
        explanation: 'Reason.',
      );
      expect(q.correctAnswer, 'Beta');
    });
  });

  group('QuizService', () {
    late QuizService service;

    setUp(() {
      service = QuizService(const [
        QuizQuestion(
          id: 'q1',
          question: 'Q1',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          explanation: 'E1',
        ),
        QuizQuestion(
          id: 'q2',
          question: 'Q2',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 2,
          explanation: 'E2',
        ),
        QuizQuestion(
          id: 'q3',
          question: 'Q3',
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 1,
          explanation: 'E3',
        ),
      ]);
    });

    test('initial state is correct', () {
      expect(service.currentIndex, 0);
      expect(service.score, 0);
      expect(service.isFinished, false);
      expect(service.totalQuestions, 3);
    });

    test('answering correctly increments score', () {
      final correct = service.answer(0); // Correct for Q1
      service.nextQuestion();
      expect(correct, true);
      expect(service.score, 1);
      expect(service.currentIndex, 1);
    });

    test('answering incorrectly does not increment score', () {
      final correct = service.answer(3); // Wrong for Q1
      service.nextQuestion();
      expect(correct, false);
      expect(service.score, 0);
      expect(service.currentIndex, 1);
    });

    test('finishing quiz sets isFinished', () {
      service.answer(0); // Q1 correct
      service.nextQuestion();
      service.answer(2); // Q2 correct
      service.nextQuestion();
      service.answer(1); // Q3 correct
      service.nextQuestion();
      expect(service.isFinished, true);
      expect(service.score, 3);
    });

    test('scorePercentage calculation', () {
      service.answer(0); // correct
      service.nextQuestion();
      service.answer(0); // wrong (correct is 2)
      service.nextQuestion();
      service.answer(1); // correct
      service.nextQuestion();
      expect(service.score, 2);
      expect(service.scorePercentage, closeTo(66.67, 0.1));
    });

    test('reset clears state', () {
      service.answer(0);
      service.nextQuestion();
      service.answer(2);
      service.nextQuestion();
      service.reset();
      expect(service.currentIndex, 0);
      expect(service.score, 0);
      expect(service.isFinished, false);
    });

    test('answering after finish returns false', () {
      service.answer(0);
      service.nextQuestion();
      service.answer(2);
      service.nextQuestion();
      service.answer(1);
      service.nextQuestion();
      expect(service.isFinished, true);
      final result = service.answer(0);
      expect(result, false);
      expect(service.score, 3); // Score unchanged
    });
  });

  group('Quiz Data', () {
    test('all questions should have exactly 4 options', () {
      for (final q in quizData) {
        expect(q.options.length, 4,
            reason: '"${q.question}" should have 4 options');
      }
    });

    test('correctIndex should be valid', () {
      for (final q in quizData) {
        expect(q.correctIndex, greaterThanOrEqualTo(0));
        expect(q.correctIndex, lessThan(q.options.length));
      }
    });

    test('all questions should have non-empty explanations', () {
      for (final q in quizData) {
        expect(q.explanation.isNotEmpty, true);
      }
    });
  });
}
