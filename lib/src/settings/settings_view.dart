// ignore_for_file: unnecessary_const

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';
import '../sample_feature/construct_quiz_screen.dart';
import '../sample_feature/quiz_categories.dart';
import '../sample_feature/sorting_handler.dart';
import 'settings_controller.dart';
import '/src/sample_feature/helpers.dart';
//import '/src/sample_feature/database_helpers.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget with WatchItMixin {
  //final VoidCallback onResetDatabase;
  SettingsView(
      {super.key}); //, required this.controller, required this.onResetDatabase});

  static const routeName = '/settings';
  // final SettingsController controller;
  // final DatabaseHelper dbhelper = DatabaseHelper();

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
            // Glue the SettingsController to the theme selection DropdownButton.
            //
            // When a user selects a theme from the dropdown list, the
            // SettingsController is updated, which rebuilds the MaterialApp.
            child: DropdownButton<ThemeMode>(
              // Read the selected themeMode from the controller
              value: controller.themeMode,
              // Call the updateThemeMode method any time the user selects a theme.
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
          // Display a file picker when the user taps the button.
          Row(children: [
            Tooltip(
              message:
                  "The txtfile should be in the format:\n\nCategory\nQuestion\tAnswer\nQuestion\tAnswer\n\nCategory\nQuestion\tAnswer\nQuestion\tAnswer\n\netc.\n\n so that is a TAB between answer and Question \nand no empty line below category",
              child: ElevatedButton(
                  child: const Text('Import Quiz'),
                  onPressed: () async {
                    // Wait for the user to select a text file.
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['txt'],
                    );
                    if (result != null) {
                      // Read the text file.
                      String text =
                          await File(result.files.single.path!).readAsString();
                      // Convert the text to a Quiz object.
                      var quiz = makeQuiz(text);
                      // String jsonData = jsonEncode(quiz);
                      //save the quiz as a json file in the app's documents directory.
                      //await saveQuiz(jsonData);
                      Quiz quizCategory = Quiz.fromJson(quiz[0]);

                      di<QuizListProvider>().saveQuizToDatabase(quizCategory);
                    }
                  }),
            ),
            ElevatedButton(
              child: const Text('Create Quiz'),
              onPressed: () => createAndSaveQuizCategory(context),
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

                        const SizedBox(width: 20), // give it width
                        Text(
                          watchPropertyValue((QuizListProvider m) =>
                              m.amountOfAnswers.toString()),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 20), // give it width
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
// 2 buttons to increment or decrement the value of amountOfAnswers
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

                        const SizedBox(width: 20), // give it width
                        Text(
                          watchPropertyValue((QuizListProvider m) =>
                              m.correctAnswerTime.toString()),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 20), // give it width
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

                        const SizedBox(width: 20), // give it width
                        Text(
                          watchPropertyValue((QuizListProvider m) =>
                              m.incorrectAnswerTime.toString()),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 20), // give it width
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
// Future<bool> resetDatabase() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.setBool('isFirstRun', true);
//   return true;
// }

// void showRestartDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Restart Required'),
//         content: Text('Please restart the app to apply changes.'),
//         actions: <Widget>[
//           TextButton(
//             child: Text('OK'),
//             onPressed: () {
//               SystemNavigator.pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

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

  void createAndSaveQuizCategory(BuildContext context) async {
    // Open the EditQuizScreen and wait for the user to create a QuizCategory.
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

    // If the QuizCategory is well-formed, save it to the database.
    // if (quizCategory != null &&
    //     quizCategory.category.isNotEmpty &&
    //     quizCategory.quizQuestions
    //         .every((q) => q.question.isNotEmpty && q.answer.isNotEmpty)) {
    //   await dbhelper.saveQuizCategory(quizCategory);
    // } else {
    //   // Handle the case where the QuizCategory is not well-formed.
    // }
  }

//this method is not used in this app
  Future<void> saveQuiz(jsonData) async {
    // Write the JSON data to a file
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
