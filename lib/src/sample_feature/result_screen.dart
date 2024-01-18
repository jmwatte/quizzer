import 'package:flutter/material.dart';
import 'package:quizzer/src/sample_feature/sample_item.dart';

class ResultsScreen extends StatelessWidget {
  final String category;
  final Map<Shortcut, int> correctAnswers;
  final Map<Shortcut, int> incorrectAnswers;
  final Map<Shortcut, Duration> correctAnswersTimes;
  final Map<Shortcut, Duration> incorrectAnswersTimes;
  final Map<Shortcut, Duration> questionTimes;
  final Duration totalTime;

  const ResultsScreen({
    required this.category,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.correctAnswersTimes,
    required this.incorrectAnswersTimes,
    required this.questionTimes,
    required this.totalTime,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var sortedEntries = questionTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
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
                '${entry.key.shortcut} - ${entry.key.action}: ${formatDuration(entry.value)}'),
            subtitle: incorrectAttempts != null
                ? Text(
                    'Incorrect attempts: $incorrectAttempts (${formatDuration(incorrectTime!)})\nCorrect after: ${formatDuration(correctTime!)}')
                : Text(
                    'Correct on first attempt: ${formatDuration(correctTime!)}'),
          );
        },
      ),
    );
  }
}
