import 'database_helpers.dart';
import 'package:flutter/material.dart';
import 'quiz_question.dart';
import 'sorting_handler.dart';

class Quiz {
  int? id;
  String title;
  List<QuizQuestion> quizQuestions;
  bool randomQuestions = false;
  bool isTestQuiz = false;
  SortType selectedSortType = SortType.original;
  TextEditingController quizTitleController;

  Quiz(
      {this.id,
      required this.title,
      required this.quizQuestions,
      required this.randomQuestions,
      required this.isTestQuiz,
      required this.selectedSortType})
      : quizTitleController = TextEditingController(text: title);

  factory Quiz.fromJson(Map<String, dynamic> jsonData) {
    List<QuizQuestion> questions = [];
    var questionsFromJson = jsonData['Questions'];

    if (questionsFromJson is List) {
      questions = questionsFromJson
          .map((question) => QuizQuestion.fromJson(question))
          .toList();
    } else if (questionsFromJson is Map) {
      questions.add(
          QuizQuestion.fromJson(questionsFromJson as Map<String, dynamic>));
    }

    return Quiz(
      title: jsonData['Quiz'],
      quizQuestions: questions,
      randomQuestions: jsonData['randomQuestions'] == 1,
      isTestQuiz: jsonData['isTestQuiz'] == 1,
      selectedSortType: SortType.values[jsonData['selectedSortType'] ?? 0],
    );
  }

  @override
  String toString() {
    return 'Quiz{id: $id, title: $title, randomQuestions: $randomQuestions, isTestQuiz: $isTestQuiz, selectedSortType: $selectedSortType}';
  }

  Quiz sortQuiz(SortType sortType) {
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

    return Quiz(
      title: title,
      quizQuestions: sortedQuestions,
      randomQuestions: randomQuestions,
      isTestQuiz: isTestQuiz,
      selectedSortType: selectedSortType,
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'randomQuestions': randomQuestions ? 1 : 0,
      'isTestQuiz': isTestQuiz ? 1 : 0,
      'selectedSortType': selectedSortType.index,
    };
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  static Future<Quiz> fromMap(Map<String, dynamic> map) async {
    var dbHelper = DatabaseHelper();
    List<QuizQuestion> quizQuestions =
        await dbHelper.fetchQuizQuestions(map['id']);
    return Quiz(
      id: map['id'],
      title: map['title'],
      randomQuestions: map['randomQuestions'] == 1,
      quizQuestions: quizQuestions,
      isTestQuiz: map['isTestQuiz'] == 1,
      selectedSortType: SortType.values[map['selectedSortType'] ?? 0],
    );
  }
}
