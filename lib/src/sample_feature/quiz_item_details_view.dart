import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzer/src/sample_feature/construct_quiz_screen.dart';
import 'package:quizzer/src/sample_feature/helpers.dart';
import 'package:quizzer/src/sample_feature/quiz_categories.dart';
import 'package:quizzer/src/sample_feature/quiz_result_screen.dart';
import 'package:quizzer/src/sample_feature/quiz_question.dart';

typedef ContextCallback = void Function(BuildContext context);

class QuizItemDetailsView extends StatefulWidget {
  final ContextCallback onBack;
  static const routeName = '/quizItem';

  const QuizItemDetailsView({required this.onBack, super.key});

  @override
  QuizItemDetailsViewState createState() => QuizItemDetailsViewState();
}

class QuizItemDetailsViewState extends State<QuizItemDetailsView> {
  DateTime? questionStartTime;
  Duration questionTime = Duration.zero;
  Duration totalTime = Duration.zero;
  Map<QuizQuestion, Duration> questionTimes = {};
  bool isSwapped = false;
  late List<QuizQuestion> answers;
  QuizQuestion? correctAnswer;
  QuizQuestion? selectedAnswer;
  Color backgroundColor = Colors.white;
  late QuizCategory category;
  List<QuizQuestion>? remainingQuestions;
  late Map<QuizQuestion, int> correctAnswers;
  late Map<QuizQuestion, int> incorrectAnswers;
  late QuizQuestion currentQuestion;
  Map<QuizQuestion, Duration> correctAnswerTimes = {};
  Map<QuizQuestion, Duration> incorrectAnswerTimes = {};
  Timer? timer;
  // Define ValueNotifiers for questionTime and totalTime
  ValueNotifier<Duration> questionTimeNotifier = ValueNotifier(Duration.zero);
  ValueNotifier<Duration> totalTimeNotifier = ValueNotifier(Duration.zero);

  //bool randomOrNot=true;
  bool isTestQuiz = false;

// Update the timer in initState to update the ValueNotifiers
  @override
  void initState() {
    super.initState();
    questionStartTime = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      final currentTime = DateTime.now().difference(questionStartTime!);
      questionTimeNotifier.value = currentTime;
      totalTimeNotifier.value =
          totalTimeNotifier.value + const Duration(seconds: 1);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final selectedCategory =
        Provider.of<CategoryProvider>(context, listen: false).selectedCategory;
    if (selectedCategory == null) {
      throw StateError('No category selected');
    }
    category = selectedCategory.sortQuiz(selectedCategory.selectedSortType);
//here we can add the logic to sort the questions and answers

    incorrectAnswers = <QuizQuestion, int>{};
    remainingQuestions = List.from(category.quizQuestions);
    correctAnswers = <QuizQuestion, int>{};
    if (remainingQuestions == null) {
      throw StateError('remainingQuestions is null');
    } else {
      switch (category.randomQuestions) {
        case true:
          currentQuestion =
              remainingQuestions![Random().nextInt(remainingQuestions!.length)];
          questionStartTime = DateTime.now();

          break;
        case false:
          currentQuestion = remainingQuestions![0];
          questionStartTime = DateTime.now();
          break;
        default:
      }
    }
    answers = _generateAnswers();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer?.cancel();
    super.dispose();
  }

  void answerQuestion(QuizQuestion answer) {
    timer?.cancel();
    setState(() {
      questionTime = DateTime.now().difference(questionStartTime!);
      totalTime += questionTime;
      questionTimes.update(
          currentQuestion, (existing) => existing + questionTime,
          ifAbsent: () => questionTime);
      //  questionStartTime =
      //    DateTime.now(); // Reset questionStartTime for the next question
      correctAnswer = currentQuestion;
      if (answer == currentQuestion) {
        correctAnswers.update(currentQuestion, (existing) => existing + 1,
            ifAbsent: () => 1);
        correctAnswerTimes.update(
            currentQuestion, (existing) => existing + questionTime,
            ifAbsent: () => questionTime);
      } else {
        selectedAnswer = answer;
        incorrectAnswers.update(currentQuestion, (existing) => existing + 1,
            ifAbsent: () => 1);
        incorrectAnswerTimes.update(
            currentQuestion, (existing) => existing + questionTime,
            ifAbsent: () => questionTime);
      }
      // If it's a testQuiz, remove the question whether it's answered correctly or not
      if (category.isTestQuiz || answer == currentQuestion) {
        remainingQuestions!.remove(currentQuestion);
      }
    });

    Future.delayed(
      Duration(milliseconds: answer == correctAnswer ? 1000 : 3000),
      () {
        setState(() {
          correctAnswer = null;
          selectedAnswer = null;
          if (remainingQuestions!.isNotEmpty) {
            // Check if there are any questions left
            QuizQuestion newQuestion;
            //if random is true then we randomize the questions
            if (category.randomQuestions) {
              do {
                if (remainingQuestions!.length > 1) {
                  do {
                    newQuestion = remainingQuestions!.elementAt(
                        Random().nextInt(remainingQuestions!.length));
                  } while (newQuestion == currentQuestion);
                } else {
                  newQuestion = remainingQuestions!.first;
                }
              } while (newQuestion == currentQuestion);
            } else {
              //if random is false then we do not randomize the questions
              if (remainingQuestions!.length > 1) {
                newQuestion = remainingQuestions![0];
              } else {
                newQuestion = remainingQuestions!.first;
              }
            }
            questionStartTime = DateTime.now();

            timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
              final currentTime = DateTime.now().difference(questionStartTime!);
              questionTimeNotifier.value = currentTime;
              totalTimeNotifier.value =
                  totalTimeNotifier.value + const Duration(seconds: 1);
            });

            // Reset questionStartTime for the next question
            currentQuestion = newQuestion;
            answers = _generateAnswers();
          } else {
            // Quiz is over
            timer?.cancel();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultsScreen(
                  category: category.category,
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
                  return Text(
                      '${formatDuration(value)} / ${formatDuration(totalTimeNotifier.value)}');
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
      // In your build method

      body: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(10), // Add some padding
              color: Colors
                  .grey[200], // Change this to your desired background color
              child: Center(
                child: ListTile(
                  title: Text(
                    isSwapped
                        ? currentQuestion.answer
                        : currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 24, // Change this to your desired font size
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.black, // Change this to your desired color
                    ),
                    textAlign: TextAlign
                        .center, // Center the text within the Text widget
                  ),
                  subtitle: Text(
                    (!isSwapped && currentQuestion.note.isNotEmpty)
                        ? '(${currentQuestion.note})'
                        : '',
                    style: const TextStyle(
                      fontSize: 16, // Change this to your desired font size
                      color: Colors.black, // Change this to your desired color
                    ),
                    textAlign: TextAlign
                        .center, // Center the text within the Text widget
                  ),
                  onLongPress: () async {
                    final updatedItem = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ConstructQuizScreen(item: category),
                      ),
                    );
                    if (updatedItem != null) {
                      setState(() {
                        // Replace the old
                        var ql = Provider.of<QuizListProvider>(context,
                            listen: false);
                        ql.updateQuiz(updatedItem);
                        // QuizCategory object with the updated one
                        category = updatedItem;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          // Iterate over the answers list and create a ListTile for each answer
          ...answers.map((answer) => ListTile(
                onTap: () => answerQuestion(answer),
                // Set the tileColor based on the correctness of the answer
                tileColor: answer == correctAnswer
                    ? Colors.green // Correct answer is green
                    : answer == selectedAnswer
                        ? Colors.red // Selected answer is red
                        : null, // Default color for other answers
                title: ListTile(
                  title: Text(
                    isSwapped ? answer.question : answer.answer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18, // Change this to your desired font size
                    ),
                  ),
                  subtitle: Text(
                    (isSwapped && answer.note.isNotEmpty)
                        ? '(${answer.note})' // Show note if answer is swapped and note is not empty
                        : '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16, // Change this to your desired font size
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

//
  List<QuizQuestion> _generateAnswers() {
    final answers = [currentQuestion];
    final incorrectAnswers = category.quizQuestions
        .where((shortcut) => shortcut != currentQuestion)
        .toList();

    // Check if there are any incorrect answers
    if (incorrectAnswers.isNotEmpty) {
      // First random selection
      var firstIncorrect =
          incorrectAnswers.removeAt(Random().nextInt(incorrectAnswers.length));
      answers.add(firstIncorrect);

      // Second random selection
      // Make sure the second incorrect answer is not the same as the first one
      if (incorrectAnswers.isNotEmpty) {
        var secondIncorrect =
            incorrectAnswers[Random().nextInt(incorrectAnswers.length)];
        answers.add(secondIncorrect);
      }
    }

    answers.shuffle();
    return answers;
  }
}
