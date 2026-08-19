import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = context.watch<FlashcardProvider>();
    final quizProvider = context.watch<QuizProvider>();

    final totalCards = flashcardProvider.flashcards.length;
    final learnedCards = flashcardProvider.learnedCards.length;
    final quizAttempts = quizProvider.history.length;
    final highestScore = quizProvider.highestScore;
    final averageScore = quizProvider.averageScore;

    final learnedRatio = totalCards == 0 ? 0.0 : learnedCards / totalCards;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary stat cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _StatTile(
                label: 'Total Flashcards',
                value: '$totalCards',
                icon: Icons.style_rounded,
                color: Colors.deepPurple,
              ),
              _StatTile(
                label: 'Cards Learned',
                value: '$learnedCards',
                icon: Icons.check_circle_rounded,
                color: Colors.green,
              ),
              _StatTile(
                label: 'Quiz Attempts',
                value: '$quizAttempts',
                icon: Icons.quiz_rounded,
                color: Colors.orange,
              ),
              _StatTile(
                label: 'Highest Score',
                value: '${highestScore.toStringAsFixed(0)}%',
                icon: Icons.emoji_events_rounded,
                color: Colors.pink,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Learned progress pie chart
          Text(
            'Flashcards Learned',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: totalCards == 0
                ? const Center(
                    heightFactor: 3,
                    child: Text('No flashcards yet'),
                  )
                : SizedBox(
                    height: 180,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  value: learnedCards.toDouble(),
                                  color: Colors.green,
                                  title: '',
                                  radius: 45,
                                ),
                                PieChartSectionData(
                                  value: (totalCards - learnedCards).toDouble(),
                                  color: Colors.grey.shade300,
                                  title: '',
                                  radius: 45,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LegendDot(color: Colors.green, label: 'Learned ($learnedCards)'),
                              const SizedBox(height: 8),
                              _LegendDot(
                                color: Colors.grey.shade300,
                                label: 'Remaining (${totalCards - learnedCards})',
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${(learnedRatio * 100).toStringAsFixed(0)}% Complete',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // Quiz score bar chart (last attempts)
          Text(
            'Recent Quiz Scores',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
            height: 220,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: quizProvider.history.isEmpty
                ? const Center(child: Text('No quiz attempts yet'))
                : BarChart(
                    BarChartData(
                      maxY: 100,
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt() + 1}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(quizProvider.history
                          .map((r) => r.percentage)
                          .toList()),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Average Score: ${averageScore.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<double> scores) {
    // Show only the last 10 attempts to keep the chart readable
    final recent = scores.length > 10
        ? scores.sublist(scores.length - 10)
        : scores;

    return List.generate(recent.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: recent[index],
            color: Colors.deepPurple,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        ),
      ],
    );
  }
}