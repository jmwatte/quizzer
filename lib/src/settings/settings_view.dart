import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';
import '../sample_feature/construct_quiz_screen.dart';
import '../sample_feature/quiz.dart';
import '../sample_feature/sorting_handler.dart';
import 'settings_controller.dart';
import '/src/sample_feature/helpers.dart';

class SettingsView extends StatelessWidget with WatchItMixin {
  SettingsView({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final controller = di.get<SettingsController>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<ThemeMode>(
              value: controller.themeMode,
              onChanged: controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Theme'),
                )
              ],
            ),
          ),
          Row(children: [
            Tooltip(
              message:
                  "The txtfile should be in the format:\n\nQuiz\nQuestion\tAnswer\nQuestion\tAnswer\n\n\nQuestion\tAnswer\nQuestion\tAnswer\n\netc.\n\n so that is a TAB between answer and Question \nand no empty line below quiz",
              child: ElevatedButton(
                  child: const Text('Import Quiz'),
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['txt'],
                    );
                    if (result != null) {
                      String text =
                          await File(result.files.single.path!).readAsString();
                      var quizzes = makeQuiz(text);
                      Quiz quiz = Quiz.fromJson(quizzes[0]);

                      di<QuizListProvider>().saveQuizToDatabase(quiz);
                    }
                  }),
            ),
            ElevatedButton(
              child: const Text('Create Quiz'),
              onPressed: () => createAndSaveQuiz(context),
            ),
            ElevatedButton(
              child: const Text('Reset Database'),
              onPressed: () {
                resetDatabase().then((_) {
                  showRestartDialog(context);
                });
              },
            )
          ]),
          Column(children: [
            const Text("Question style:"),
            DropdownButton<QuestionType>(
              value: watchPropertyValue(
                  (QuizListProvider m) => m.selectedQuestionType),
              hint: const Text('Select a question style'),
              items: QuestionType.values.map((QuestionType type) {
                return DropdownMenuItem<QuestionType>(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (QuestionType? type) {
                di<QuizListProvider>().selectedQuestionType = type!;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    const Text('Amount of answers: '),
                    Row(
                      children: [
                        FloatingActionButton(
                          heroTag: 'decrement',
                          onPressed: () =>
                              di<QuizListProvider>().amountOfAnswers--,
                          tooltip: 'Decrement',
                          child: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          watchPropertyValue((QuizListProvider m) =>
                              m.amountOfAnswers.toString()),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 20),
                        FloatingActionButton(
                          heroTag: 'increment',
                          onPressed: () =>
                              di<QuizListProvider>().amountOfAnswers++,
                          tooltip: 'Increment',
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ]),
          Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    const Text('Correct answer time: '),
                    Row(
                      children: [
                        FloatingActionButton(
                          heroTag: 'decrementcorrect',
                          onPressed: () =>
                              di<QuizListProvider>().correctAnswerTime -= 100,
                          tooltip: 'Decrement',
                          child: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          watchPropertyValue((QuizListProvider m) =>
                              m.correctAnswerTime.toString()),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 20),
                        FloatingActionButton(
                          heroTag: 'incrementcorrect',
                          onPressed: () =>
                              di<QuizListProvider>().correctAnswerTime += 100,
                          tooltip: 'Increment',
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: [
                    const Text('Incorrect answer time: '),
                    Row(
                      children: [
                        FloatingActionButton(
                          heroTag: 'decrementincorrect',
                          onPressed: () =>
                              di<QuizListProvider>().incorrectAnswerTime -= 100,
                          tooltip: 'Decrement',
                          child: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          watchPropertyValue((QuizListProvider m) =>
                              m.incorrectAnswerTime.toString()),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 20),
                        FloatingActionButton(
                          heroTag: 'incrementincorrect',
                          onPressed: () =>
                              di<QuizListProvider>().incorrectAnswerTime += 100,
                          tooltip: 'Increment',
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ]),
        ]));
  }

  Future<void> resetDatabase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', true);
  }

  void showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Required'),
          content: const Text('Please restart the app to apply changes.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  void createAndSaveQuiz(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ConstructQuizScreen(
                  item: Quiz(
                title: 'change me',
                quizQuestions: [],
                randomQuestions: false,
                isTestQuiz: false,
                selectedSortType: SortType.original,
              ))),
    );
  }

  Future<void> saveQuiz(jsonData) async {
    FilePickerResult? result = (await FilePicker.platform.saveFile(
      dialogTitle: 'Save Quiz',
      type: FileType.custom,
      allowedExtensions: ['json'],
      fileName: 'quiz.json',
    )) as FilePickerResult?;

    if (result != null) {
      File file = File(result.files.single.path!);
      await file.writeAsString(jsonData);
    }
  }
}
