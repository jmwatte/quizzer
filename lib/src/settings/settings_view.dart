import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'settings_controller.dart';
import 'package:quizzer/src/sample_feature/helpers.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
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
            Tooltip(
              //TODO it should be question answe note and the note should be optional
              message :"The txtfile should be in the format:\n\nCategory\nQuestion\tAnswer\nQuestion\tAnswer\n\nCategory\nQuestion\tAnswer\nQuestion\tAnswer\n\netc.\n\n so that is a TAB between answer and Question \nand no empty line below category",
              child: ElevatedButton(
                child: const Text('Import Quiz'),
                
              onPressed: () async {
                // Wait for the user to select a text file.
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['txt'],
                );
                if (result != null) {
                  // Read the text file.
                  String text = await File(result.files.single.path!).readAsString();
                  // Convert the text to a Quiz object.
                  var quiz = makeQuiz(text);
                 String jsonData = jsonEncode(quiz);
                        //save the quiz as a json file in the app's documents directory.
                  await saveQuiz(jsonData);
                }
                } 
                ),
            )
              ],
      ));
  }
  
  Future<void> saveQuiz(jsonData) async {
    // Write the JSON data to a file
    FilePickerResult? result= (await FilePicker.platform.saveFile(
      dialogTitle: 'Save Quiz',
      type: FileType.custom,
      allowedExtensions: ['json'],
      fileName: 'quiz.json',
    )) as FilePickerResult?;
    
    if(result !=null) {
        File file = File(result.files.single.path!);
        await file.writeAsString(jsonData);
      }
    }
  }
