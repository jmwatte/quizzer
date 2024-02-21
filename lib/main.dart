import 'package:flutter/material.dart';
import 'src/sample_feature/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/app.dart';
import 'package:watch_it/watch_it.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  await di<SettingsController>().loadSettings();
  await di<QuizListProvider>().loadQuizzes();

  runApp(MyApp());
}

setupDependencyInjection() async {
  di.registerSingleton<SettingsService>(SettingsService());
  di.registerSingleton<SettingsController>(SettingsController());
  di.registerSingleton<QuizProvider>(QuizProvider());
  di.registerSingleton<QuizManager>(QuizManager());
  di.registerSingleton<QuizListProvider>(QuizListProvider());
  di.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance());
}
