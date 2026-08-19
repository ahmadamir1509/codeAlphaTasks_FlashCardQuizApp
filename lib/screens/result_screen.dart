import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quiz_result_model.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_setup_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final QuizResultModel result;

  const ResultScreen({super.key, required this.result});

  String _performanceMessage(double percentage) {
    if (percentage >= 90) return "Outstanding! You're a FlashMaster! 🏆";
    if (percentage >= 70) return "Great job! Keep it up! 🎉";
    if (percentage >= 50) return "Good effort! Practice more. 💪";
    return "Keep studying, you'll improve! 📚";
  }

  Color _performanceColor(double percentage) {
    if (percentage >= 70) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = _performanceColor(result.percentage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
                border: Border.all(color: color, width: 4),
              ),
              child: Center(
                child: Text(
                  '${result.percentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _performanceMessage(result.percentage),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total',
                    value: '${result.totalQuestions}',
                    color: Colors.blue,
                    icon: Icons.quiz_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Correct',
                    value: '${result.correctAnswers}',
                    color: Colors.green,
                    icon: Icons.check_circle_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Wrong',
                    value: '${result.wrongAnswers}',
                    color: Colors.red,
                    icon: Icons.cancel_rounded,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                final flashcards = context.read<FlashcardProvider>().flashcards;
                context.read<QuizProvider>().generateQuiz(flashcards);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizSetupScreen()),
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Restart Quiz'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go Home'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}