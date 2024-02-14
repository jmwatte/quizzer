import 'package:flutter/material.dart';
import 'package:quizzer/src/sample_feature/helpers.dart';
import 'src/app.dart';
import 'package:watch_it/watch_it.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  setupDependencyInjection();
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  runApp(

      // MultiProvider(
      //   providers: [
      //     ChangeNotifierProvider(
      //       create: (context) => CategoryProvider(),
      //     ),
      //     ChangeNotifierProvider(
      //       create: (context) => QuizManager(),
      //     ),
      //     ChangeNotifierProvider(
      //       create: (context) => QuizListProvider()..loadQuizzes(),
      //     ),
      //   ],
      MyApp(settingsController: settingsController));
}

setupDependencyInjection() {
  di.registerSingleton<CategoryProvider>(CategoryProvider());
  di.registerSingleton<QuizManager>(QuizManager());
  di.registerSingleton<QuizListProvider>(QuizListProvider());
}
