import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'construct_quiz_screen.dart';
import 'helpers.dart';
import 'quiz.dart';
import 'quiz_result_screen.dart';
import 'quiz_question.dart';

typedef ContextCallback = void Function(BuildContext context);

class QuizItemDetailsView extends WatchingStatefulWidget {
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
  late Quiz quiz;
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
  bool _isLongPressing = false;

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
    final selectedQuiz = di<QuizProvider>().selectedQuiz;
    if (selectedQuiz == null) {
      throw StateError('No quiz selected');
    }
    quiz = selectedQuiz.sortQuiz(selectedQuiz.selectedSortType);
//here we can add the logic to sort the questions and answers

    incorrectAnswers = <QuizQuestion, int>{};
    remainingQuestions = List.from(quiz.quizQuestions);
    correctAnswers = <QuizQuestion, int>{};
    if (remainingQuestions == null) {
      throw StateError('remainingQuestions is null');
    } else {
      switch (quiz.randomQuestions) {
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
      if (quiz.isTestQuiz || answer == currentQuestion) {
        remainingQuestions!.remove(currentQuestion);
      }
    });

    Future.delayed(
      Duration(
          milliseconds: di<QuizListProvider>().selectedQuestionType ==
                      QuestionType.study ||
                  di<QuizListProvider>().selectedQuestionType ==
                      QuestionType.noChoices
              ? 0
              : answer == correctAnswer
                  ? di<QuizListProvider>().correctAnswerTime
                  : di<QuizListProvider>().incorrectAnswerTime),
      () {
        setState(() {
          correctAnswer = null;
          selectedAnswer = null;
          if (remainingQuestions!.isNotEmpty) {
            // Check if there are any questions left
            QuizQuestion newQuestion;
            //if random is true then we randomize the questions
            if (quiz.randomQuestions) {
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
                  title: quiz.title,
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
          ListTile(
            tileColor: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 99, 83, 16)
                : Colors.yellow[400],
            title: Text(
              isSwapped ? currentQuestion.answer : currentQuestion.question,
              style: const TextStyle(
                fontSize: 24, // Change this to your desired font size
                fontWeight: FontWeight.bold, // Make the text bold
                // color: Colors.black, // Change this to your desired color
              ),
              textAlign:
                  TextAlign.center, // Center the text within the Text widget
            ),
            subtitle: Text(
              (!isSwapped && currentQuestion.note.isNotEmpty)
                  ? '(${currentQuestion.note})'
                  : ' ',
              style: const TextStyle(
                fontSize: 16, // Change this to your desired font size
                // color: Colors.black, // Change this to your desired color
              ),
              textAlign:
                  TextAlign.center, // Center the text within the Text widget
            ),
            onLongPress: () async {
              final updatedItem = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConstructQuizScreen(item: quiz),
                ),
              );
              if (updatedItem != null) {
                setState(() {
                  // Replace the old
                  var ql = di<QuizListProvider>();

                  ql.updateQuiz(updatedItem);
                  // Quiz object with the updated one
                  quiz = updatedItem;
                });
              }
            },
          ),
          // Iterate over the answers list and create a ListTile for each answer
          switch (watchPropertyValue(
              (QuizListProvider m) => m.selectedQuestionType)) {
            QuestionType.multipleChoices => Expanded(
                child: ListView.builder(
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    final answer = answers[index];
                    return ListTile(
                      onTap: () => answerQuestion(answer),
                      // Set the tileColor based on the correctness of the answer
                      tileColor: correctAnswer == null
                          ? index % 2 == 0
                              ? Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromARGB(255, 6, 82, 145)
                                  : const Color.fromARGB(255, 77, 178, 250)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color.fromARGB(255, 53, 146, 212)
                                  : const Color.fromARGB(255, 67, 156, 229)
                          : answer == correctAnswer
                              ? Colors.green // Correct answer is green
                              : answer == selectedAnswer
                                  ? Colors.red // Selected answer is red
                                  : null, // Default color for other answers
                      title: ListTile(
                        title: Visibility(
                          visible: answers.length > 1,
                          child: Text(
                            isSwapped ? answer.question : answer.answer,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize:
                                  18, // Change this to your desired font size
                            ),
                          ),
                        ),
                        subtitle: Text(
                          (isSwapped && answer.note.isNotEmpty)
                              ? '(${answer.note})' // Show note if answer is swapped and note is not empty
                              : ' ',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize:
                                16, // Change this to your desired font size
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            QuestionType.study => ListTile(
                onTap: () => answerQuestion(currentQuestion),
                // Set the tileColor based on the correctness of the answer
                tileColor: Colors.green, // Correct answer is green

                title: ListTile(
                  title: FittedBox(
                    child: Text(
                      isSwapped
                          ? splitLongString(currentQuestion.question)
                          : splitLongString(currentQuestion.answer),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18, // Change this to your desired font size
                      ),
                    ),
                  ),
                  subtitle: Text(
                    (isSwapped && currentQuestion.note.isNotEmpty)
                        ? '(${splitLongString(currentQuestion.note)})' // Show note if answer is swapped and note is not empty
                        : ' ',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16, // Change this to your desired font size
                    ),
                  ),
                ),
              ),
            QuestionType.noChoices => Expanded(
                child: Stack(
                  children: [
                    _isLongPressing
                        ? ListTile(
                            title: FittedBox(
                              child: Text(
                                isSwapped
                                    ? splitLongString(currentQuestion.question)
                                    : splitLongString(currentQuestion.answer),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize:
                                      18, // Change this to your desired font size
                                ),
                              ),
                            ),
                            subtitle: Text(
                              (isSwapped && currentQuestion.note.isNotEmpty)
                                  ? '(${splitLongString(currentQuestion.note)})' // Show note if answer is swapped and note is not empty
                                  : ' ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize:
                                    16, // Change this to your desired font size
                              ),
                            ),
                          )
                        : Container(),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                        onLongPressStart: (details) {
                          setState(() {
                            _isLongPressing = true;
                          });
                        },
                        onLongPressEnd: (details) {
                          setState(() {
                            _isLongPressing = false;
                          });
                          answerQuestion(currentQuestion);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 150, // Adjust this to your desired height
                          color:
                              Colors.blue, // Adjust this to your desired color
                          child: const Center(
                              child: Text("Tap and hold to answer")),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          }
        ],
      ),
    );
  }

//
  List<QuizQuestion> _generateAnswers() {
    final answers = [currentQuestion];
    final incorrectAnswers = quiz.quizQuestions
        .where((shortcut) => shortcut != currentQuestion)
        .toList();
    int amountOfAlternatives = di<QuizListProvider>().amountOfAnswers;
    for (int i = 0; i < amountOfAlternatives; i++) {
      if (incorrectAnswers.isNotEmpty) {
        var randomAnswer = incorrectAnswers
            .removeAt(Random().nextInt(incorrectAnswers.length));
        answers.add(randomAnswer);
      }
    }
    // Check if there are any incorrect answers
    // if (incorrectAnswers.isNotEmpty) {
    //   // First random selection
    //   var firstIncorrect =
    //       incorrectAnswers.removeAt(Random().nextInt(incorrectAnswers.length));
    //   answers.add(firstIncorrect);

    // Second random selection
    // Make sure the second incorrect answer is not the same as the first one
    // if (incorrectAnswers.isNotEmpty) {
    //   var secondIncorrect =
    //       incorrectAnswers[Random().nextInt(incorrectAnswers.length)];
    //   answers.add(secondIncorrect);
    // }
    //}

    answers.shuffle();
    return answers;
  }
}
