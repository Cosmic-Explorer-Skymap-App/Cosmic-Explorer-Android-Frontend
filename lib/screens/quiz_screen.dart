import 'package:flutter/material.dart';
import '../theme/space_theme.dart';
import '../data/quiz_data.dart';
import '../services/quiz_service.dart';
import '../data/quiz_l10n.dart';
import 'package:cosmic_explorer/l10n/generated/app_localizations.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late QuizService _quiz;
  int? _selectedAnswer;
  bool _answered = false;
  late AnimationController _animController;
  late Animation<double> _slideAnim;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Localizations.localeOf(context).languageCode;
    final localizedData = getLocalizedQuiz(lang, quizData);
    _quiz = QuizService(localizedData);
  }

  @override
  void initState() {
    super.initState();
    // _quiz initialized in didChangeDependencies
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _quiz.answer(index);
    });
  }

  void _nextQuestion() {
    _quiz.nextQuestion();
    if (_quiz.isFinished) {
      setState(() {});
      return;
    }
    _animController.reset();
    setState(() {
      _selectedAnswer = null;
      _answered = false;
    });
    _animController.forward();
  }

  void _restart() {
    _animController.reset();
    setState(() {
      _quiz.reset();
      _selectedAnswer = null;
      _answered = false;
    });
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: SpaceTheme.gradientBackground,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _quiz.isFinished ? _buildResult() : _buildQuestion(),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _quiz.currentQuestion;
    final l10n = AppLocalizations.of(context)!;
    return SlideTransition(
      position: Tween(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(_slideAnim),
      child: FadeTransition(
        opacity: _slideAnim,
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              l10n.quizScreenTitle,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            // Progress
            Row(
              children: [
                Text(
                  '${l10n.quizQuestionPrefix} ${_quiz.currentIndex + 1}/${_quiz.totalQuestions}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_quiz.currentIndex + 1) / _quiz.totalQuestions,
                      backgroundColor: SpaceTheme.surfaceCard,
                      valueColor: const AlwaysStoppedAnimation(
                          SpaceTheme.nebulaPurple),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Question
            Container(
              padding: const EdgeInsets.all(20),
              decoration: SpaceTheme.glassCard,
              child: Text(
                q.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20),

            // Options
            ...List.generate(q.options.length, (i) {
              final isCorrect = q.correctIndex == i;
              final isSelected = _selectedAnswer == i;
              Color borderColor = SpaceTheme.dividerColor;

              if (_answered) {
                if (isCorrect) {
                  borderColor = Colors.green;
                } else if (isSelected) {
                  borderColor = SpaceTheme.marsRed;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => _onAnswer(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _answered && isCorrect
                          ? Colors.green.withValues(alpha: 0.1)
                          : _answered && isSelected && !isCorrect
                              ? SpaceTheme.marsRed.withValues(alpha: 0.1)
                              : SpaceTheme.surfaceCard.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _answered && isCorrect
                                ? Colors.green
                                : _answered && isSelected
                                    ? SpaceTheme.marsRed
                                    : SpaceTheme.surfaceCardLight,
                          ),
                          child: Center(
                            child: _answered
                                ? Icon(
                                    isCorrect
                                        ? Icons.check
                                        : isSelected
                                            ? Icons.close
                                            : null,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : Text(
                                    String.fromCharCode(65 + i),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            q.options[i],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Explanation
            if (_answered) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: SpaceTheme.glassCard.copyWith(
                  border: Border.all(
                    color: SpaceTheme.cosmicBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  q.explanation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SpaceTheme.starWhite,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpaceTheme.nebulaPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _quiz.isFinished ? l10n.quizButtonResults : l10n.quizButtonNext,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final l10n = AppLocalizations.of(context)!;
    final pct = _quiz.scorePercentage;
    String emoji;
    String message;

    if (pct >= 80) {
      emoji = '🌟';
      message = l10n.quizResultMessageExcellent;
    } else if (pct >= 50) {
      emoji = '🚀';
      message = l10n.quizResultMessageGood;
    } else {
      emoji = '🔭';
      message = l10n.quizResultMessageTryAgain;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(
            '${_quiz.score}/${_quiz.totalQuestions}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 48,
                  color: SpaceTheme.nebulaPurple,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _restart,
            style: ElevatedButton.styleFrom(
              backgroundColor: SpaceTheme.nebulaPurple,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.quizButtonRestart,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

