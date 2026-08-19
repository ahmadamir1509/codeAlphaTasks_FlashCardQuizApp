import 'package:flutter/material.dart';

class FlashcardWidget extends StatelessWidget {
  final String text;
  final bool isAnswer;

  const FlashcardWidget({
    super.key,
    required this.text,
    required this.isAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAnswer
              ? [Colors.deepPurple, Colors.deepPurple.shade300]
              : [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAnswer ? Colors.deepPurple : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAnswer ? Icons.lightbulb : Icons.help_outline,
                size: 32,
                color: isAnswer ? Colors.white70 : Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isAnswer ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}