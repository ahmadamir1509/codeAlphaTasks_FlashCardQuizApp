import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmResetProgress(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'This will unmark all flashcards as learned, remove favorites, '
          'and clear your quiz history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<FlashcardProvider>().resetProgress();
              await context.read<QuizProvider>().clearHistory();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress has been reset'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Appearance',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light Theme'),
                  secondary: const Icon(Icons.light_mode_rounded),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setTheme(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Theme'),
                  secondary: const Icon(Icons.dark_mode_rounded),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setTheme(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  secondary: const Icon(Icons.brightness_auto_rounded),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setTheme(mode);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Data',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.restart_alt_rounded, color: Colors.orange),
              title: const Text('Reset Progress'),
              subtitle: const Text('Clear learned status, favorites & quiz history'),
              onTap: () => _confirmResetProgress(context),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Account',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Sign out of your account'),
              onTap: () => _confirmLogout(context),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'FlashMaster v1.0.0',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}