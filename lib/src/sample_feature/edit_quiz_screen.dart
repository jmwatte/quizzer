import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizzer/src/sample_feature/helpers.dart';
import 'package:quizzer/src/sample_feature/quiz_categories.dart';
import 'package:quizzer/src/sample_feature/quiz_question.dart';
import 'package:undo/undo.dart';

class EditQuizScreen extends StatefulWidget {
  final QuizCategory item;

  const EditQuizScreen({super.key, required this.item});

  @override
  EditQuizScreenState createState() => EditQuizScreenState();
}

class EditQuizScreenState extends State<EditQuizScreen> {
  late QuizCategory item;
  List<QuizQuestion> selectedQuestions = [];
  final cs = ChangeStack();
  @override
  void initState() {
    super.initState();
    item = widget.item;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Editor'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Provider.of<QuizManager>(context, listen: false)
                  .copySelected(selectedQuestions);
            },
          ),
          IconButton(
            icon: const Icon(Icons.paste),
            onPressed: () {
              final oldQuestions = List<QuizQuestion>.from(item.quizQuestions);
              Provider.of<QuizManager>(context, listen: false)
                  .pasteCopied(item.quizQuestions);
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
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: item.category),
              onChanged: (value) {
                setState(() {
                  item.category = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: 80.0), // Add padding at the bottom
              itemCount: item.quizQuestions.length,
              itemBuilder: (context, index) {
                final question = item.quizQuestions[index];
                return Padding(
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
                                  labelText: 'answer',
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new question when the button is pressed
          setState(() {
            item.quizQuestions
                .add(QuizQuestion(question: '', answer: '', note: ''));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
