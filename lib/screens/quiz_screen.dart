import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submit(QuizProvider provider) {
    if (_answerController.text.trim().isEmpty) return;
    provider.submitAnswer(_answerController.text.trim());
  }

  void _goNext(BuildContext context, QuizProvider provider) {
    if (provider.isLastQuestion) {
      final result = provider.finishQuiz();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } else {
      provider.nextQuestion();
      _answerController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();
    final question = provider.currentQuestion;

    if (question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No quiz questions available.')),
      );
    }

    final isCorrect = provider.answered &&
        provider.userAnswer != null &&
        _normalizeCompare(provider.userAnswer!, question.correctAnswer);

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${provider.currentIndex + 1}/${provider.questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: provider.progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Score: ${provider.correctCount}/${provider.currentIndex + (provider.answered ? 1 : 0)}',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                question.flashcard.question,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _answerController,
                      enabled: !provider.answered,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Type your answer here',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!provider.answered)
                      ElevatedButton(
                        onPressed: () => _submit(provider),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Submit Answer'),
                      ),
                    if (provider.answered)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isCorrect ? Colors.green : Colors.red).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isCorrect ? Colors.green : Colors.red),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isCorrect ? 'Correct!' : 'Wrong Answer',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (!isCorrect) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Correct answer: ${question.correctAnswer}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (provider.answered)
              ElevatedButton(
                onPressed: () => _goNext(context, provider),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(provider.isLastQuestion ? 'Finish Quiz' : 'Next Question'),
              ),
          ],
        ),
      ),
    );
  }

  // Same normalization logic as provider, used here only for UI color decision
  bool _normalizeCompare(String a, String b) {
    String normalize(String text) => text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s]'), '');
    return normalize(a) == normalize(b);
  }
}