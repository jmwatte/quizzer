import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzer/src/sample_feature/changnotifiers.dart';
import 'package:quizzer/src/sample_feature/result_screen.dart';
import 'package:quizzer/src/sample_feature/sample_item.dart';

/// Displays detailed information about a SampleItem.
typedef ContextCallback = void Function(BuildContext context);

class QuizItemDetailsView extends StatefulWidget {
  final ContextCallback onBack;
  static const routeName = '/sample_item';

  const QuizItemDetailsView({required this.onBack, Key? key}) : super(key: key);

  @override
  QuizItemDetailsViewState createState() => QuizItemDetailsViewState();
}

class QuizItemDetailsViewState extends State<QuizItemDetailsView> {
  DateTime? questionStartTime;
  Duration questionTime = Duration.zero;
  Duration totalTime = Duration.zero;
  Map<Shortcut, Duration> questionTimes = {};
  bool isSwapped = false;
  late List<Shortcut> answers;
  Shortcut? correctAnswer;
  Shortcut? selectedAnswer;
  Color backgroundColor = Colors.white;
  late ShortcutCategory category;
  List<Shortcut>? remainingQuestions;
  late Map<Shortcut, int> correctAnswers;
  late Map<Shortcut, int> incorrectAnswers;
  late Shortcut currentQuestion;
  Map<Shortcut, Duration> correctAnswerTimes = {};
  Map<Shortcut, Duration> incorrectAnswerTimes = {};
  Timer? timer;
  // Define ValueNotifiers for questionTime and totalTime
ValueNotifier<Duration> questionTimeNotifier = ValueNotifier(Duration.zero);
ValueNotifier<Duration> totalTimeNotifier = ValueNotifier(Duration.zero);

// Update the timer in initState to update the ValueNotifiers
@override
void initState() {
  super.initState();
  questionStartTime = DateTime.now();
  timer = Timer.periodic(
    const Duration(seconds: 1), 
    (Timer t) {
      final currentTime = DateTime.now().difference(questionStartTime!);
      questionTimeNotifier.value = currentTime;
      totalTimeNotifier.value = totalTimeNotifier.value + Duration(seconds: 1);
    }
  );
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedCategory =
        Provider.of<CategoryProvider>(context, listen: false).selectedCategory;
    if (selectedCategory == null) {
      throw StateError('No category selected');
    }
    category = selectedCategory;
    incorrectAnswers = <Shortcut, int>{};
    remainingQuestions = List.from(category.shortcuts);
    correctAnswers = <Shortcut, int>{};
    if (remainingQuestions == null) {
      throw StateError('remainingQuestions is null');
    } else {
      currentQuestion = remainingQuestions!
          .removeAt(Random().nextInt(remainingQuestions!.length));
      questionStartTime = DateTime.now();
    }
    answers = _generateAnswers();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer?.cancel();
    super.dispose();
  }

  void answerQuestion(Shortcut answer) {
    setState(() {
      questionTime = DateTime.now().difference(questionStartTime!);
      totalTime += questionTime;
      questionTimes.update(
          currentQuestion, (existing) => existing + questionTime,
          ifAbsent: () => questionTime);
      questionStartTime =
          DateTime.now(); // Reset questionStartTime for the next question
      correctAnswer = currentQuestion;
      if (answer == currentQuestion) {
        correctAnswers.update(currentQuestion, (existing) => existing + 1,
            ifAbsent: () => 1);
        remainingQuestions!.remove(answer);
        correctAnswerTimes.update(
            currentQuestion, (existing) => existing + questionTime,
            ifAbsent: () => questionTime);

        // Remove the question only when it's answered correctly
      } else {
        selectedAnswer = answer;
        incorrectAnswers.update(currentQuestion, (existing) => existing + 1,
            ifAbsent: () => 1);
        incorrectAnswerTimes.update(
            currentQuestion, (existing) => existing + questionTime,
            ifAbsent: () => questionTime);
      }
    });
    Future.delayed(
  Duration(milliseconds: answer == correctAnswer ? 1000 : 3000), () {
    setState(() {
      correctAnswer = null;
      selectedAnswer = null;
      if (remainingQuestions!.isNotEmpty) {
        // Check if there are any questions left
        Shortcut newQuestion;
        if (remainingQuestions!.length > 1) {
          do {
            newQuestion = remainingQuestions!
                .elementAt(Random().nextInt(remainingQuestions!.length));
          } while (newQuestion == currentQuestion);
        } else {
          newQuestion = remainingQuestions!.first;
        }
        currentQuestion = newQuestion;
        answers = _generateAnswers();
      } else {
        // Quiz is over
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              category: 'Your Category',
              incorrectAnswers: incorrectAnswers,
              correctAnswers: correctAnswers,
              questionTimes: questionTimes,
              correctAnswersTimes: correctAnswerTimes,
              incorrectAnswersTimes: incorrectAnswerTimes,
              totalTime: totalTime,
            ),
          ),
        );
      }
    });
  },
);
  }
// This is a helper function to format a Duration as mm:ss

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.onBack(context),
        ),
        actions: [
            Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ValueListenableBuilder<Duration>(
          valueListenable: questionTimeNotifier,
          builder: (context, value, child) {
            return Text('${formatDuration(value)} / ${formatDuration(totalTimeNotifier.value)}');
          },
        ),
      ),
    ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '${remainingQuestions?.length ?? 0}/${correctAnswers.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Switch(
              value: isSwapped,
              onChanged: (value) {
                setState(() {
                  isSwapped = value;
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(10), // Add some padding
              color: Colors
                  .grey[200], // Change this to your desired background color
              child: Center(
                child: Text(
                  isSwapped
                      ? '${currentQuestion.action}\n(${currentQuestion.note})'
                      : currentQuestion.shortcut,
                  style: const TextStyle(
                    fontSize: 24, // Change this to your desired font size
                    fontWeight: FontWeight.bold, // Make the text bold
                    color: Colors.black, // Change this to your desired color
                  ),
                  textAlign: TextAlign
                      .center, // Center the text within the Text widget
                ),
              ),
            ),
          ),
          ...answers
              .map((answer) => TextButton(
                    onPressed: () => answerQuestion(answer),
                    style: TextButton.styleFrom(
                      backgroundColor: answer == correctAnswer
                          ? Colors.green
                          : answer == selectedAnswer
                              ? Colors.red
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        isSwapped
                            ? answer.shortcut
                            : '${answer.action}\n(${answer.note})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18, // Change this to your desired font size
                          height:
                              1.5, // Change this to increase or decrease the line spacing
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  List<Shortcut> _generateAnswers() {
    final answers = [currentQuestion];
    final incorrectAnswers = category.shortcuts
        .where((shortcut) => shortcut != currentQuestion)
        .toList();

    // First random selection
    var firstIncorrect =
        incorrectAnswers.removeAt(Random().nextInt(incorrectAnswers.length));
    answers.add(firstIncorrect);

    // Second random selection
    // Make sure the second incorrect answer is not the same as the first one
    incorrectAnswers.remove(firstIncorrect);
    if (incorrectAnswers.isNotEmpty) {
      var secondIncorrect =
          incorrectAnswers[Random().nextInt(incorrectAnswers.length)];
      answers.add(secondIncorrect);
    }

    answers.shuffle();
    return answers;
  }
}
