import 'package:flutter/material.dart';
import 'package:quizzer/src/sample_feature/helpers.dart';
import 'package:quizzer/src/sample_feature/quiz_question.dart';

class ResultsScreen extends StatelessWidget {
  final String category;
  final Map<QuizQuestion, int> correctAnswers;
  final Map<QuizQuestion, int> incorrectAnswers;
  final Map<QuizQuestion, Duration> correctAnswersTimes;
  final Map<QuizQuestion, Duration> incorrectAnswersTimes;
  final Map<QuizQuestion, Duration> questionTimes;
  final Duration totalTime;

  const ResultsScreen({
    required this.category,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.correctAnswersTimes,
    required this.incorrectAnswersTimes,
    required this.questionTimes,
    required this.totalTime,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    var sortedEntries = questionTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
return PopScope(
  onPopInvoked: (popIntent){
    if (popIntent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      });
  }},
  child: Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: sortedEntries.length,
        itemBuilder: (context, index) {
          var entry = sortedEntries[index];
          var incorrectAttempts = incorrectAnswers[entry.key];
          var correctTime = correctAnswersTimes[entry.key];
          var incorrectTime = incorrectAnswersTimes[entry.key];
          return ListTile(
            title: Text(
                '${entry.key.answer} - ${entry.key.question}: ${formatDuration(entry.value)}'),
            subtitle: incorrectAttempts != null
                ? Text(
                    'Incorrect attempts: $incorrectAttempts (${formatDuration(incorrectTime!)})\nCorrect after: ${formatDuration(correctTime!)}')
                : Text(
                    'Correct on first attempt: ${formatDuration(correctTime!)}'),
          );
        },
      ),
    ));
  }
}
