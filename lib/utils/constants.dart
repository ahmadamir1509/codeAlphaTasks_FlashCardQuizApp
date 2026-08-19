class AppConstants {
  AppConstants._();

  static const String appName = "FlashMaster";
  static const int splashDuration = 3; // seconds

  // Hive Box Names
  static const String flashcardBox = "flashcardBox";
  static const String settingsBox = "settingsBox";
  static const String quizHistoryBox = "quizHistoryBox";

  // Default Categories
  static const List<String> defaultCategories = [
    "Programming",
    "Science",
    "Math",
    "English",
    "General Knowledge",
  ];

  // Quiz Types
  static const String mcq = "MCQ";
  static const String trueFalse = "True/False";
  static const String fillBlank = "Fill in the Blank";
}