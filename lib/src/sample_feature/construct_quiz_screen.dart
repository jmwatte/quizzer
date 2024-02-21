import 'package:flutter/material.dart';
//import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:watch_it/watch_it.dart';
import 'database_helpers.dart';
import 'helpers.dart';
import 'quiz_categories.dart';
import 'quiz_question.dart';
import 'package:undo/undo.dart';

class ConstructQuizScreen extends StatefulWidget {
  final Quiz item;

  const ConstructQuizScreen({super.key, required this.item});

  @override
  ConstructQuizScreenState createState() => ConstructQuizScreenState();
}

class ConstructQuizScreenState extends State<ConstructQuizScreen> {
  late Quiz item;
  List<QuizQuestion> selectedQuestions = [];
  final cs = ChangeStack();
  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  @override
  void dispose() {
    super.dispose();
    // Save the changes to the database
  }

  void deleteSelected() {
    final removedQuestions = selectedQuestions.toList();
    cs.add(Change<List<QuizQuestion>>(
      removedQuestions,
      () {
        setState(() {
          item.quizQuestions
              .removeWhere((question) => selectedQuestions.contains(question));
          selectedQuestions.clear();
        });
      },
      (oldQuestions) {
        setState(() {
          item.quizQuestions.addAll(oldQuestions);
          selectedQuestions = oldQuestions;
        });
      },
      description: 'Delete selected questions',
    ));
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final oldQuestions = List<QuizQuestion>.from(item.quizQuestions);

    final QuizQuestion question = item.quizQuestions.removeAt(oldIndex);
    item.quizQuestions.insert(newIndex, question);

    final newQuestions = List<QuizQuestion>.from(item.quizQuestions);
    cs.add(Change<List<QuizQuestion>>(
      oldQuestions,
      () {
        setState(() {
          item.quizQuestions = newQuestions;
        });
      },
      (oldQuestions) {
        setState(() {
          item.quizQuestions = oldQuestions;
        });
      },
      description: 'Reorder questions',
    ));
  }

// int _findIndexOfKey(Key key) {
//   return item.quizQuestions.indexWhere((question) => Key(question.hashCode.toString()) == key);
// }
  void saveChanges() {
    // Save the changes to the database
    var dbHelper = DatabaseHelper();
    var quizListProvider = di<QuizListProvider>();
    if (item.title.isNotEmpty &&
        item.quizQuestions.length > 1 &&
        item.quizQuestions
            .every((q) => q.question.isNotEmpty && q.answer.isNotEmpty)) {
      if (item.id == null) {
        dbHelper.saveQuizToDatabase(item);
      } else {
        dbHelper.updateQuiz(item);
      }
    }
    // Load the updated list of quizzes from the database
    quizListProvider.loadQuizzesFromDatabase();
    // Return the updated QuizCategory object
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Editor'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              di<QuizManager>().copySelected(selectedQuestions);
            },
          ),
          IconButton(
            icon: const Icon(Icons.paste),
            onPressed: () {
              final oldQuestions = List<QuizQuestion>.from(item.quizQuestions);
              di<QuizManager>().pasteCopied(item.quizQuestions);
              final newQuestions = List<QuizQuestion>.from(item.quizQuestions);
              cs.add(Change<List<QuizQuestion>>(
                oldQuestions,
                () {
                  setState(() {
                    item.quizQuestions = newQuestions;
                  });
                },
                (oldQuestions) {
                  setState(() {
                    item.quizQuestions = oldQuestions;
                  });
                },
                description: 'Paste questions',
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                deleteSelected();
              });
            },
          ),
          IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () {
                if (cs.canUndo) {
                  cs.undo();
                }
              }),
          ElevatedButton(
            onPressed: saveChanges,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: item.quizTitleController,
              onChanged: (value) {
                setState(() {
                  item.title = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: _onReorder,
              children: item.quizQuestions
                  .map((question) => ListTile(
                      key: Key(question.hashCode.toString()),
                      title:

                          //this is the item that will be dragged

                          Padding(
                        // first and last attributes affect border drawn during dragging
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (selectedQuestions.contains(question)) {
                                  selectedQuestions.remove(question);
                                } else {
                                  selectedQuestions.add(question);
                                }
                              });
                            },
                            splashFactory: InkRipple.splashFactory,
                            child: Card(
                              color: selectedQuestions.contains(question)
                                  ? Colors.blue[100]
                                  : null,
                              margin: const EdgeInsets.all(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: question.questionController,
                                      onChanged: (value) {
                                        setState(() {
                                          question.question = value;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Question',
                                      ),
                                    ),
                                    TextField(
                                      controller: question.answerController,
                                      onChanged: (value) {
                                        setState(() {
                                          question.answer = value;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Answer',
                                      ),
                                    ),
                                    if (question.note.isNotEmpty)
                                      TextField(
                                        controller: question.noteController,
                                        onChanged: (value) {
                                          setState(() {
                                            question.note = value;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Note',
                                        ),
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            question.note = 'New Note';
                                          });
                                        },
                                        child: const Text('Add Note'),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )

                      // till here

                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new question when the button is pressed
          setState(() {
            int newIndex = item.quizQuestions.length;
            if (item.quizQuestions.isEmpty) {
              // If quizQuestions is empty, add two QuizQuestion objects
              item.quizQuestions.add(QuizQuestion(
                  id: 'question_$newIndex',
                  question: '',
                  answer: '',
                  note: ''));
              newIndex++;
              item.quizQuestions.add(QuizQuestion(
                  id: 'question_$newIndex',
                  question: '',
                  answer: '',
                  note: ''));
            } else {
              // If quizQuestions is not empty, add one QuizQuestion object
              item.quizQuestions.add(QuizQuestion(
                  id: 'question_$newIndex',
                  question: '',
                  answer: '',
                  note: ''));
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
