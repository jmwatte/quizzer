import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helpers.dart';
import 'quiz.dart';
import 'quiz_question.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizProvider extends ChangeNotifier {
  Quiz? selectedQuiz;

  void selectQuiz(Quiz quiz) {
    selectedQuiz = quiz;
    notifyListeners();
  }
}

class QuizListProvider extends ChangeNotifier {
  late SharedPreferences prefs;
  List<Quiz> quizzes = [];
  late int _amountOfAnswers;
  int get amountOfAnswers => _amountOfAnswers;
  late int _correctAnswerTime;
  int get correctAnswerTime => _correctAnswerTime;
  late int _incorrectAnswerTime;
  int get incorrectAnswerTime => _incorrectAnswerTime;
  late QuestionType _selectedQuestionStyle;
  QuestionType get selectedQuestionType => _selectedQuestionStyle;

  set selectedQuestionType(QuestionType selectedQuestionType) {
    if (selectedQuestionType != _selectedQuestionStyle) {
      _selectedQuestionStyle = selectedQuestionType;
      prefs.setInt('selectedQuestionStyle', selectedQuestionType.index);
      notifyListeners();
    }
  }

  /// Adds a new quiz to the list of quizzes.
  ///
  /// The [quiz] parameter represents the quiz to be added.
  /// After adding the quiz, it notifies the listeners.
  void addQuiz(Quiz quiz) {
    quizzes.add(quiz);
    notifyListeners();
  }

  set correctAnswerTime(int value) {
    if (value < 0) {
      value = 0;
    }
    _correctAnswerTime = value;
    prefs.setInt('correctAnswerTime', value);
    notifyListeners();
  }

  set incorrectAnswerTime(int value) {
    if (value < 0) {
      value = 0;
    }
    _incorrectAnswerTime = value;
    prefs.setInt('incorrectAnswerTime', value);
    notifyListeners();
  }

  set amountOfAnswers(int value) {
    if (value < 0) {
      value = 0;
    }
    _amountOfAnswers = value;
    prefs.setInt('amountOfAnswers', value);
    notifyListeners();
  }

  QuizListProvider() {
    // loadQuizzes();
    loadprefs();
  }
  loadprefs() async {
    prefs = await SharedPreferences.getInstance();
    _amountOfAnswers = prefs.getInt('amountOfAnswers') ?? 2;
    _correctAnswerTime = prefs.getInt('correctAnswerTime') ?? 1000;
    _incorrectAnswerTime = prefs.getInt('incorrectAnswerTime') ?? 2000;
    _selectedQuestionStyle =
        QuestionType.values[prefs.getInt('selectedQuestionStyle') ?? 1];
    notifyListeners();
  }

  Future<void> loadQuizzes() async {
    var dbHelper = DatabaseHelper();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
    //bool isFirstRun = true;
    if (isFirstRun) {
      // Get the asset manifest
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Get the paths of all JSON files in the assets folder
      final jsonPaths = manifestMap.keys
          .where((String key) => path.extension(key) == '.json')
          .where((String key) => key.startsWith('assets/quizes_jsons/'))
          .toList();

      // Load each JSON file and convert it to a quiz object
      for (var jsonPath in jsonPaths) {
        final jsonString = await rootBundle.loadString(jsonPath);
        final jsonData = json.decode(jsonString);

        if (jsonData is List) {
          final quizesJsons = jsonData
              .map((item) => Quiz.fromJson(item as Map<String, dynamic>))
              .toList();
          quizesJsons
              .where((quiz) => quiz.quizQuestions.length > 1)
              .forEach((quiz) => addQuiz(quiz));
          // quizzes.addAll(quizCategoriesJsons
          //     .where((quiz) => quiz.quizQuestions.length > 1));
        } else if (jsonData is Map) {
          final quiz = Quiz.fromJson(jsonData as Map<String, dynamic>);
          if (quiz.quizQuestions.length > 1) {
            addQuiz(quiz);
            //quizzes.add(quiz);
          } else {
            throw Exception(
                'Quiz at $jsonPath should have more than one question.');
          }
        }
      }

      // Save quizzes to the database
      for (Quiz quiz in quizzes) {
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

  /// Retrieves a list of Quiz objects by loading quizzes from the database.
  ///
  /// Returns a Future that resolves to a List of Quiz objects.
  /// The list of quizzes is obtained by calling the `loadQuizzesFromDatabase` method
  /// of the `DatabaseHelper` class. After loading the quizzes, the `notifyListeners`
  /// method is called to notify any listeners of changes. Finally, the list of quizzes
  /// is returned.
  Future<List<Quiz>> getQuizzes() async {
    var dbHelper = DatabaseHelper();
    quizzes = await dbHelper.loadQuizzesFromDatabase();
    notifyListeners();
    return quizzes;
  }

  /// Loads quizzes from the database asynchronously.
  ///
  /// This method initializes a [DatabaseHelper] instance and uses it to load quizzes from the database.
  /// The loaded quizzes are then assigned to the `quizzes` variable and the listeners are notified.
  Future<void> loadQuizzesFromDatabase() async {
    var dbHelper = DatabaseHelper();
    quizzes = await dbHelper.loadQuizzesFromDatabase();
    notifyListeners();
  }

  /// Updates the given [quiz] in the list of quizzes.
  ///
  /// It searches for the quiz with the same ID as the given [quiz] and replaces it with the updated [quiz].
  /// After updating the quiz, it notifies the listeners.
  void updateQuiz(Quiz quiz) {
    int index = quizzes.indexWhere((item) => item.id == quiz.id);
    if (index != -1) {
      quizzes[index] = quiz;
      notifyListeners();
    }
  }

  /// Saves the [quiz] to the database.
  ///
  /// If the [quiz] does not have an ID, it saves the [quiz] quiz to the database
  /// and assigns the generated ID to the [quiz]. Otherwise, it updates the existing
  /// [quiz] quiz in the database.
  void saveQuizToDatabase(Quiz quiz) async {
    var dbHelper = DatabaseHelper();
    if (quiz.id == null) {
      await dbHelper.saveQuizToDatabase(quiz);
    } else {
      await dbHelper.updateQuiz(quiz);
    }
    quizzes = await dbHelper.loadQuizzesFromDatabase();
    notifyListeners();
  }

  /// Deletes a quiz from the database.
  ///
  /// This function takes a [Quiz] object as a parameter and deletes the corresponding quiz from the database.
  /// It uses the [DatabaseHelper] class to perform the deletion operation.
  ///
  /// Example usage:
  /// ```dart
  /// Quiz quiz = Quiz(id: 1, name: 'History');
  /// deleteQuizFromDatabase(quiz);
  /// ```
  void deleteQuizFromDatabase(Quiz quiz) async {
    var dbHelper = DatabaseHelper();
    await dbHelper.deleteQuizAndQuestions(quiz.id!);
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

/// Parses a text into a list of quiz categories and their corresponding quizzes.
///
/// This function takes a [text] string as input and splits it into separate quizzes.
/// Each quiz consists of a quit titlename and a list of quiz questions.
/// The text should be formatted with each quiz separated by empty lines and each quiz question separated by tabs.
/// The format of each line should be: "answer\tquestion\tnote" (note is optional).
/// The function returns a list of maps, where each map represents a quiz  and contains the quiz name and a list of quiz questions.
List<Map<String, dynamic>> makeQuiz(String text) {
  List<String> pieces = text.trim().split(RegExp(r'\n\s*\n'));
  List<Map<String, dynamic>> quizzes = [];

  for (var piece in pieces) {
    List<String> lines = piece.split('\n');
    String quiz = lines[0];
    List<Map<String, String>> questions = [];

    for (var i = 1; i < lines.length; i++) {
      List<String> parts = lines[i].split('\t');
      questions.add({
        'question': parts[1],
        'answer': parts[0],
        'note': parts.length > 2 ? parts[2] : '',
      });
    }

    quizzes.add({
      'Quiz': quiz,
      'Questions': questions,
    });
  }

  return quizzes;
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

String splitLongString(String input) {
  int middle = 15;
  int span = 0;
  String wordgroup = '';
  var words = input.split(" ");
  String subword = '';
  for (var word in words) {
    if (word.length > middle) {
      wordgroup += "$word\n";
      subword = '';
    } else {
      if (subword.length + word.length < middle - span) {
        subword += "$word ";
      } else {
        subword += '\n';
        wordgroup = "$wordgroup$subword";
        subword = '';
        subword += "$word ";
      }
    }
    // if (subword.length > middle - span) {
    //   // This line should append 'subword' to 'wordgroup' and add a newline.
    //   // However, 'subword' is being reset to an empty string every time it exceeds 'middle - span'.
    //   // Therefore, if 'subword' is not empty, it should be appended to 'wordgroup'.
    //   if (subword.isNotEmpty) {
    //     wordgroup = "$wordgroup$subword\n";
    //     subword = ''; // Reset 'subword' after adding it to 'wordgroup'.
    //   }
    //   // subword = '';
    // }
  }
  if (subword.isNotEmpty) {
    wordgroup = "$wordgroup$subword";
  }
  return wordgroup.trim();
  // int splitAt = 15;
  // int splitWidth = 9;
  // if (input.length <= splitAt) {
  //   return input;
  // } else {
  //   int gr = 1;
  //   for (int i = 1; i < input.length; i = i + splitAt) {
  //     var hit =
  //         input.indexOf(" ", min(input.length, gr * splitAt - splitWidth));
  //     if (hit == -1) break;
  //     gr++;
  //     input = input.replaceFirst(" ", "\n", hit - 2);
  //   }
}

enum QuestionType {
  study,
  noChoices,
  multipleChoices,
}
// Split the string into substrings
//return input;
