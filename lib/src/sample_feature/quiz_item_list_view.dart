import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:quizzer/src/sample_feature/edit_quiz_screen.dart';
import 'package:quizzer/src/sample_feature/helpers.dart';
import 'package:quizzer/src/sample_feature/quiz_categories.dart';
import '../settings/settings_view.dart';
import 'quiz_item_details_view.dart';

/// Displays a list of SampleItems.
class QuizItemsListView extends StatefulWidget {
  const QuizItemsListView({super.key});
//  amethod that loads all the json files from the assets folder

  static const routeName = '/';
  @override
  QuizItemsListViewState createState() => QuizItemsListViewState();
}

class QuizItemsListViewState extends State<QuizItemsListView> {
  late Future<List<QuizCategory>>
      quizesFuture; //TODO we should have a list of quizes here

  @override
  void initState() {
    super.initState();
    quizesFuture = loadQuizes();
  }

  Future<List<QuizCategory>> loadQuizes() async {
    final quizesFromJsons = <QuizCategory>[];
    // Get the asset manifest
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Get the paths of all JSON files in the assets folder
    final jsonPaths = manifestMap.keys
        .where((String key) => path.extension(key) == '.json')
        .where((String key) => key.startsWith('assets/quizes_jsons/'))
        .toList();

    // Load each JSON file and convert it to a ShortcutCategory object
    for (var jsonPath in jsonPaths) {
      final jsonString = await rootBundle.loadString(jsonPath);
      final jsonData = json.decode(jsonString);

      if (jsonData is List) {
        final quizCategoriesJsons = jsonData
            .map((item) => QuizCategory.fromJson(item as Map<String, dynamic>))
            .toList();
        quizesFromJsons.addAll(
            quizCategoriesJsons.where((quiz) => quiz.quizQuestions.length > 1));
      } else if (jsonData is Map) {
        final quiz = QuizCategory.fromJson(jsonData as Map<String, dynamic>);
        if (quiz.quizQuestions.length > 1) {
          quizesFromJsons.add(quiz);
        } else {
          throw Exception(
              'Quiz at $jsonPath should have more than one question.');
        }
      }
    }
    // Return the completed list
    return quizesFromJsons;
  }

  String getSortTypeSuffix(SortType sortType) {
    switch (sortType) {
      case SortType.original:
        return ' -o';
      case SortType.reversed:
        return ' -or';
      case SortType.question:
        return ' -q';
      case SortType.questionReversed:
        return ' -qr';
      case SortType.answer:
        return ' -a';
      case SortType.answerReversed:
        return ' -ar';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuizCategory>>(
      future: quizesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(), // Show a loading spinner while waiting
            ),
          );
        } else if (snapshot.hasError) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('${snapshot.error}'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return Container(); // Return an empty container when an error occurs
        } else {
          final items = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Quiz categories'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  },
                ),
              ],
            ),
            body: ListView.builder(
              restorationId: 'quizListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
//TODO we should have a slider tile here. so we can select the quiz and do things with it like rename it, stick it in to a category see how many times we did it what are the difficult questions and the possiblity to assign the note to either the question or the answer
                return Slidable(
                  actionPane: const SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  actions: <Widget>[
                    // Add your actions here
                    IconSlideAction(
                      caption: 'Test',
                      color: item.isTestQuiz ? Colors.blue : Colors.grey,
                      icon: Icons.check_circle,
                      onTap: () {
                        setState(() {
                          if (kDebugMode) {
                            print(item.isTestQuiz);
                          }
                          item.isTestQuiz = !item.isTestQuiz;
                          if (kDebugMode) {
                            print(item.isTestQuiz);
                          }
                        });
                      },
                    ),
                    IconSlideAction(
                      caption: 'Random',
                      color: item.randomQuestions ? Colors.green : Colors.grey,
                      icon: Icons.shuffle,
                      onTap: () {
                        setState(() {
                          if (kDebugMode) {
                            print(item.randomQuestions);
                          }
                          item.randomQuestions = !item.randomQuestions;
                          if (kDebugMode) {
                            print(item.randomQuestions);
                          }
                        });
                      },
                    ),
                    IconSlideAction(
                      caption: 'Sort',
                      color: Colors.orange,
                      icon: Icons.sort,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text('Choose sorting method'),
                              children: <Widget>[
                                SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      // Set the selectedSortType of the QuizCategory
                                      item.selectedSortType = SortType.original;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Original'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      // Set the selectedSortType of the QuizCategory
                                      item.selectedSortType = SortType.reversed;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Reversed'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      // Set the selectedSortType of the QuizCategory
                                      item.selectedSortType = SortType.question;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('question'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      // Set the selectedSortType of the QuizCategory
                                      item.selectedSortType =
                                          SortType.questionReversed;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('questionReversed'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      // Set the selectedSortType of the QuizCategory
                                      item.selectedSortType = SortType.answer;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('answer'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      // Set the selectedSortType of the QuizCategory
                                      item.selectedSortType =
                                          SortType.answerReversed;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('answerReversed'),
                                ),
                                // Add more SimpleDialogOptions for more sorting methods
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                  secondaryActions: <Widget>[
                    // Add your secondary actions here
                    IconSlideAction(
                      caption: 'Edit',
                      color: Colors.blue,
                      icon: Icons.edit,
                      //TODO WE SHOULD BE ABLE TO EDIT THE QUIZ HERE
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditQuizScreen(item: item),
                          ),
                        );
                      },
                    ),
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      //TODO WE SHOULD BE ABLE TO DELETE THE QUIZ HERE
                      icon: Icons.delete,
                      onTap: () => print('Delete'),
                    ),
                  ],
                  child: ListTile(
                    title: Text(item.category),
                    subtitle: Text(
                        '${item.isTestQuiz ? 'T: ' : ''}${item.quizQuestions.length} questions${getSortTypeSuffix(item.selectedSortType)}${item.randomQuestions ? ' -r' : ''}'),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/Designer.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    onTap: () {
                      Provider.of<CategoryProvider>(context, listen: false)
                          .selectCategory(item);
                      Navigator.restorablePushNamed(
                        context,
                        QuizItemDetailsView.routeName,
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
