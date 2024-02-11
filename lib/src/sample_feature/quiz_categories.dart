import 'package:quizzer/src/sample_feature/database_helpers.dart';
import 'package:flutter/material.dart';
import 'package:quizzer/src/sample_feature/quiz_question.dart';

enum SortType {
  original,
  reversed,
  question,
  questionReversed,
  answer,
  answerReversed,
}

class QuizCategory {
  int? id;
  String category;
  List<QuizQuestion> quizQuestions;
  bool randomQuestions = false;
  bool isTestQuiz = false;
  SortType selectedSortType = SortType.original;
  TextEditingController  categoryController;

  QuizCategory(
      {this.id,
        required this.category,
      required this.quizQuestions,
      required this.randomQuestions,
      required this.isTestQuiz,
      required this.selectedSortType}): categoryController = TextEditingController(text: category);


  factory QuizCategory.fromJson(Map<String, dynamic> jsonData) {
    List<QuizQuestion> questions = [];
    var questionsFromJson = jsonData['quiz'];

    if (questionsFromJson is List) {
      questions = questionsFromJson
          .map((question) => QuizQuestion.fromJson(question))
          .toList();
    } else if (questionsFromJson is Map) {
      questions.add(
          QuizQuestion.fromJson(questionsFromJson as Map<String, dynamic>));
    }

    return QuizCategory(
      category: jsonData['category'],
      quizQuestions: questions,
      randomQuestions: jsonData['randomQuestions'] == 1,
      isTestQuiz: jsonData['isTestQuiz'] == 1,
      selectedSortType: SortType.values[jsonData['selectedSortType'] ?? 0],
    );
  }

  //get id => null;
 @override
  String toString() {
    return 'QuizCategory{id: $id, category: $category, randomQuestions: $randomQuestions, isTestQuiz: $isTestQuiz, selectedSortType: $selectedSortType}';
  }
  QuizCategory sortQuiz(SortType sortType) {
    List<QuizQuestion> sortedQuestions;

    switch (sortType) {
      case SortType.original:
        sortedQuestions = List.from(quizQuestions);
        break;
      case SortType.reversed:
        sortedQuestions = quizQuestions.reversed.toList();
        break;
      case SortType.question:
        sortedQuestions = List.from(quizQuestions)
          ..sort((a, b) => a.question.compareTo(b.question));
        break;
      case SortType.questionReversed:
        sortedQuestions = List.from(quizQuestions)
          ..sort((a, b) => b.question.compareTo(a.question));
        break;
      case SortType.answer:
        sortedQuestions = List.from(quizQuestions)
          ..sort((a, b) => a.answer.compareTo(b.answer));
        break;
      case SortType.answerReversed:
        sortedQuestions = List.from(quizQuestions)
          ..sort((a, b) => b.answer.compareTo(a.answer));
        break;
    }

    return QuizCategory(
      category: category,
      quizQuestions: sortedQuestions,
      randomQuestions: randomQuestions,
      isTestQuiz: isTestQuiz,
      selectedSortType: selectedSortType,
    );
  }

  Map<String, dynamic> toMap() {
    var map=<String, dynamic>{
      'category': category,
      'randomQuestions': randomQuestions ? 1 : 0,
      'isTestQuiz': isTestQuiz ? 1 : 0,
      'selectedSortType': selectedSortType.index,
     // 'quizQuestions': jsonEncode(quizQuestions.map((q) => q.toMap()).toList()),
    };
if (id != null) {
    // Only include the id field in the map if it's not null
    map['id'] = id;
  }

    return map;
    // return {
    //   'id': id,
    //   'category': category,
    //   'randomQuestions': randomQuestions ? 1 : 0,
    //   'isTestQuiz': isTestQuiz ? 1 : 0,
    //   'selectedSortType': selectedSortType.index,
    //  // 'quizQuestions': jsonEncode(quizQuestions.map((q) => q.toMap()).toList()),
    // };
  }
  static Future<QuizCategory> fromMap(Map<String, dynamic> map) async {
  var dbHelper = DatabaseHelper();
    List<QuizQuestion> quizQuestions = await dbHelper.fetchQuizQuestions(map['id']);
//print(map['randomQuestions'] == 1);  // Add this
  //print(map['isTestQuiz'] == 1); 
    return QuizCategory(
      id: map['id'],
      category: map['category'],
      randomQuestions: map['randomQuestions'] == 1,
      quizQuestions: quizQuestions,
      isTestQuiz: map['isTestQuiz'] == 1,
      selectedSortType: SortType.values[map['selectedSortType'] ?? 0],
    );
  }
}
