
import 'package:flutter/material.dart';

class QuizQuestion {
  final String id;
  String question;
  String answer;
  String note;
  TextEditingController questionController;
  TextEditingController answerController;
  TextEditingController noteController;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.answer,
    required this.note,
  })  : questionController = TextEditingController(text: question),
        answerController = TextEditingController(text: answer),
        noteController = TextEditingController(text: note);

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: UniqueKey().toString(),
      question: json['question'],
      answer: json['answer'],
      note: json['note'] ?? '',  // Provide a default value for the 'note' field
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'note': note,
    };
  }
  QuizQuestion.clone(QuizQuestion source)
    : this(
        id: source.id,
        question: source.question,
        answer: source.answer,
        note: source.note,
        // add other fields if there are any
      );
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id:map['id'].toString(),
      question: map['question'],
      answer: map['answer'],
      note: map['note'] ?? '',
    );
  }
}

