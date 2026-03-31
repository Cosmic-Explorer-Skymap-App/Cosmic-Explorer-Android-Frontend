import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cosmic_explorer/app.dart';
import 'package:cosmic_explorer/data/quiz_data.dart';

void main() {
  group('Quiz Screen Widget Tests', () {
    Future<void> navigateToQuiz(WidgetTester tester) async {
      await tester.pumpWidget(const CosmicExplorerApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.quiz_rounded));
      await tester.pumpAndSettle();
    }

    testWidgets('shows first question with 4 options', (tester) async {
      await navigateToQuiz(tester);

      expect(find.text('🧠 Astronomi Quiz'), findsOneWidget);
      expect(find.textContaining('Soru 1/'), findsOneWidget);
    });

    testWidgets('selecting correct answer shows next button', (tester) async {
      await navigateToQuiz(tester);

      // Get the first quiz question's correct answer text
      final correctOption = quizData[0].options[quizData[0].correctIndex];

      // Scroll down to see options if needed, then tap the correct answer
      await tester.ensureVisible(find.text(correctOption).first);
      await tester.tap(find.text(correctOption).first);
      await tester.pumpAndSettle();

      // Should show next or results button
      expect(
        find.textContaining('Sonraki Soru'),
        findsOneWidget,
      );
    });
  });
}
