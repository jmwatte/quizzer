import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helpers.dart';
import 'quiz_categories.dart';
import 'quiz_question.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider extends ChangeNotifier {
  QuizCategory? selectedCategory;

  void selectCategory(QuizCategory category) {
    selectedCategory = category;
    notifyListeners();
  }
}

class QuizListProvider extends ChangeNotifier {
  List<QuizCategory> quizzes = [];

  Future<void> loadQuizzes() async {
    var dbHelper = DatabaseHelper();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
    //bool isFirstRun = true;
    // var quizesFromJsons = <QuizCategory>[];
    if (isFirstRun) {
      // Get the asset manifest
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Get the paths of all JSON files in the assets folder
      final jsonPaths = manifestMap.keys
          .where((String key) => path.extension(key) == '.json')
          .where((String key) => key.startsWith('assets/quizes_jsons/'))
          .toList();

      // Load each JSON file and convert it to a ShortcutCategory object
      for (var jsonPath in jsonPaths) {
        final jsonString = await rootBundle.loadString(jsonPath);
        final jsonData = json.decode(jsonString);

        if (jsonData is List) {
          final quizCategoriesJsons = jsonData
              .map(
                  (item) => QuizCategory.fromJson(item as Map<String, dynamic>))
              .toList();
          quizzes.addAll(quizCategoriesJsons
              .where((quiz) => quiz.quizQuestions.length > 1));
        } else if (jsonData is Map) {
          final quiz = QuizCategory.fromJson(jsonData as Map<String, dynamic>);
          if (quiz.quizQuestions.length > 1) {
            quizzes.add(quiz);
          } else {
            throw Exception(
                'Quiz at $jsonPath should have more than one question.');
          }
        }
      }

      // Save quizzes to the database
      for (QuizCategory quiz in quizzes) {
        await dbHelper.saveQuizToDatabase(quiz);
      }

      await prefs.setBool('isFirstRun', false);

      // Return the completed list
    } else {
      quizzes = await dbHelper.loadQuizzesFromDatabase();
    }
    // return quizesFromJsons;
    notifyListeners();
  }

  Future<List<QuizCategory>> getQuizzes() async {
    var dbHelper = DatabaseHelper();
    quizzes = await dbHelper.loadQuizzesFromDatabase();
    notifyListeners();
    return quizzes;
  }

  Future<void> loadQuizzesFromDatabase() async {
    var dbHelper = DatabaseHelper();
    quizzes = await dbHelper.loadQuizzesFromDatabase();
    notifyListeners();
  }
  // void loadQuizzes() async {
  //   var dbHelper = DatabaseHelper();
  //   quizzes = await dbHelper.loadQuizzesFromDatabase();
  //   notifyListeners();
  // }

  void addQuiz(QuizCategory quiz) {
    quizzes.add(quiz);
    notifyListeners();
  }

  void updateQuiz(QuizCategory quiz) {
    int index = quizzes.indexWhere((item) => item.id == quiz.id);
    if (index != -1) {
      quizzes[index] = quiz;
      notifyListeners();
    }
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String twoDigitCentiseconds = (duration.inMilliseconds.remainder(1000) / 10)
      .floor()
      .toString()
      .padLeft(2, '0');
  return "$twoDigitMinutes:$twoDigitSeconds.$twoDigitCentiseconds";
}

List<Map<String, dynamic>> makeQuiz(String text) {
  List<String> pieces = text.trim().split(RegExp(r'\n\s*\n'));
  List<Map<String, dynamic>> categories = [];

  for (var piece in pieces) {
    List<String> lines = piece.split('\n');
    String category = lines[0];
    List<Map<String, String>> quiz = [];

    for (var i = 1; i < lines.length; i++) {
      List<String> parts = lines[i].split('\t');
      quiz.add({
        'question': parts[1],
        'answer': parts[0],
        'note': parts.length > 2 ? parts[2] : '',
      });
    }

    categories.add({
      'category': category,
      'quiz': quiz,
    });
  }

  return categories;
}

class QuizManager extends ChangeNotifier {
  List<QuizQuestion> copiedQuestions = [];

  void copySelected(List<QuizQuestion> selectedQuestions) {
    copiedQuestions = selectedQuestions
        .map((question) => QuizQuestion.clone(question))
        .toList();
    notifyListeners();
  }

  void pasteCopied(List<QuizQuestion> targetList) {
    targetList.addAll(copiedQuestions
        .map((question) => QuizQuestion.clone(question))
        .toList());
    notifyListeners();
  }
}


// String getSortTypeSuffix(SortType sortType) {
//   switch (sortType) {
//     case SortType.original:
//       return ' -o';
//     case SortType.reversed:
//       return ' -or';
//     case SortType.question:
//       return ' -q';
//     case SortType.questionReversed:
//       return ' -qr';
//     case SortType.answer:
//       return ' -a';
//     case SortType.answerReversed:
//       return ' -ar';
//     default:
//       return '';
//   }
// }