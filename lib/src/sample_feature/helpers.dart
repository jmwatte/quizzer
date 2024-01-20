import 'package:flutter/material.dart';
import 'package:quizzer/src/sample_feature/quiz_categories.dart';
import 'package:quizzer/src/sample_feature/quiz_question.dart';

class CategoryProvider extends ChangeNotifier {
  QuizCategory? selectedCategory;

    void selectCategory(QuizCategory category) {
        selectedCategory = category;
        notifyListeners();
    }
}
String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String twoDigitCentiseconds = (duration.inMilliseconds.remainder(1000) / 10).floor().toString().padLeft(2, '0');
  return "$twoDigitMinutes:$twoDigitSeconds.$twoDigitCentiseconds";
}

List<Map<String, dynamic>> makeQuiz(String text) {
  List<String> pieces = text.trim().split(RegExp(r'\n\s*\n'));
  List<Map<String, dynamic>> categories = [];

  for (var piece in pieces) {
    //TODO split it also if there is a note on the line
    List<String> lines = piece.split('\n');
    String category = lines[0];
    List<Map<String, String>> quiz = [];

    for (var i = 1; i < lines.length; i++) {
      List<String> parts = lines[i].split('\t');
      //TODO add the note to the quiz
      quiz.add({
        'question': parts[1],
        'answer': parts[0],
        'note': parts.length > 2 ? parts[2] : '',
      });
    }

//TODO add the note to the qui
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
    copiedQuestions = List.from(selectedQuestions);
    notifyListeners();
  }

  void pasteCopied(List<QuizQuestion> targetList) {
    targetList.addAll(copiedQuestions);
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