import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../providers/flashcard_provider.dart';
import '../utils/constants.dart';
import 'create_flashcard_screen.dart';
import 'my_flashcards_screen.dart';
import 'study_mode_screen.dart';
import 'quiz_setup_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = context.watch<FlashcardProvider>();
    final totalCards = flashcardProvider.flashcards.length;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final menuItems = [
      {
        'title': 'Study Flashcards',
        'subtitle': 'Review and memorize',
        'icon': Icons.menu_book_rounded,
        'color': Colors.deepPurple,
        'progress': 0.8,
        'screen': const StudyModeScreen(),
      },
      {
        'title': 'Quiz Mode',
        'subtitle': 'Test your knowledge',
        'icon': Icons.quiz_rounded,
        'color': Colors.orange,
        'progress': 0.5,
        'screen': const QuizSetupScreen(),
      },
      {
        'title': 'Create Flashcard',
        'subtitle': 'Add a new card',
        'icon': Icons.add_card_rounded,
        'color': Colors.green,
        'progress': 0.3,
        'screen': const CreateFlashcardScreen(),
      },
      {
        'title': 'My Flashcards',
        'subtitle': '$totalCards cards saved',
        'icon': Icons.folder_copy_rounded,
        'color': Colors.blue,
        'progress': 0.6,
        'screen': const MyFlashcardsScreen(),
      },
      {
        'title': 'Progress',
        'subtitle': 'Track your growth',
        'icon': Icons.insights_rounded,
        'color': Colors.pink,
        'progress': 0.4,
        'screen': const ProgressScreen(),
      },
      {
        'title': 'Settings',
        'subtitle': 'Preferences & options',
        'icon': Icons.settings_rounded,
        'color': Colors.teal,
        'progress': 0.2,
        'screen': const SettingsScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _AppDrawer(menuItems: menuItems),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ---------- Top bar: hamburger + avatar/greeting ----------
              Builder(
                builder: (context) => Row(
                  children: [
                    IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
                    ),
                    const SizedBox(width: 4),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.deepPurple.shade200,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, Learner!",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            AppConstants.appName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Stats row ----------
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(label: "Cards", value: "$totalCards"),
                    _VerticalDivider(),
                    // TODO: replace with real streak count from provider
                    const _StatItem(label: "Streak", value: "0d"),
                    _VerticalDivider(),
                    // TODO: replace with real study-time tracking from provider
                    const _StatItem(label: "Studied", value: "0m"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---------- Start button ----------
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudyModeScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Start",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- List of options ----------
              Expanded(
                child: AnimationLimiter(
                  child: ListView.separated(
                    itemCount: menuItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 450),
                        child: SlideAnimation(
                          verticalOffset: 40,
                          child: FadeInAnimation(
                            child: _OptionListCard(
                              title: item['title'] as String,
                              subtitle: item['subtitle'] as String,
                              icon: item['icon'] as IconData,
                              color: item['color'] as Color,
                              progress: item['progress'] as double,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => item['screen'] as Widget,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Stat item widget ====================
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}

// ==================== List card widget (image-inspired) ====================
class _OptionListCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;
  final VoidCallback onTap;

  const _OptionListCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodySmall?.color),
          ],
        ),
      ),
    );
  }
}

// ==================== Hamburger Drawer ====================
class _AppDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;

  const _AppDrawer({required this.menuItems});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.deepPurple.shade200,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => item['screen'] as Widget,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}