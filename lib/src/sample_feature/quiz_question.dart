
import 'package:flutter/material.dart';

class QuizQuestion {
  String question;
  String answer;
  String note;
  TextEditingController questionController;
  TextEditingController answerController;
  TextEditingController noteController;

  QuizQuestion({
    required this.question,
    required this.answer,
    required this.note,
  })  : questionController = TextEditingController(text: question),
        answerController = TextEditingController(text: answer),
        noteController = TextEditingController(text: note);

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      answer: json['answer'],
      note: json['note'] ?? '',  // Provide a default value for the 'note' field
    );
  }
}
