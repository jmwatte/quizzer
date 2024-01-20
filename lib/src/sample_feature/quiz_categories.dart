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
  String category;
  List<QuizQuestion> quizQuestions;
  bool randomQuestions = false;
  bool isTestQuiz = false;
  SortType selectedSortType = SortType.original;

  QuizCategory({required this.category, required this.quizQuestions});

  factory QuizCategory.fromJson(Map<String, dynamic> jsonData) {
    List<QuizQuestion> questions = [];
    var questionsFromJson = jsonData['quiz'];

    if (questionsFromJson is List) {
      questions = questionsFromJson.map((question) => QuizQuestion.fromJson(question)).toList();
    } else if (questionsFromJson is Map) {
      questions.add(QuizQuestion.fromJson(questionsFromJson as Map<String, dynamic>));
    }

    return QuizCategory(
      category: jsonData['category'],
      quizQuestions: questions,
    );
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
        sortedQuestions = List.from(quizQuestions)..sort((a, b) => a.question.compareTo(b.question));
        break;
      case SortType.questionReversed:
        sortedQuestions = List.from(quizQuestions)..sort((a, b) => b.question.compareTo(a.question));
        break;
      case SortType.answer:
        sortedQuestions = List.from(quizQuestions)..sort((a, b) => a.answer.compareTo(b.answer));
        break;
      case SortType.answerReversed:
        sortedQuestions = List.from(quizQuestions)..sort((a, b) => b.answer.compareTo(a.answer));
        break;
    }

    return QuizCategory(category: category, quizQuestions: sortedQuestions);
  }
}