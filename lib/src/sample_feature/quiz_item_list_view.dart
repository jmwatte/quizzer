import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:quizzer/src/sample_feature/database_helpers.dart';
import 'package:quizzer/src/sample_feature/construct_quiz_screen.dart';
import 'package:quizzer/src/sample_feature/helpers.dart';
import 'package:quizzer/src/sample_feature/quiz_categories.dart';
import '../settings/settings_view.dart';
import 'quiz_item_details_view.dart';
import 'package:quizzer/src/settings/settings_controller.dart';

/// Displays a list of SampleItems.
class QuizItemsListView extends StatefulWidget {
  const QuizItemsListView({super.key, required this.settingsController});
//  amethod that loads all the json files from the assets folder
  final SettingsController settingsController;

  static const routeName = '/';
  @override
  QuizItemsListViewState createState() => QuizItemsListViewState();
}

class QuizItemsListViewState extends State<QuizItemsListView> {
  late Future<List<QuizCategory>> quizesFuture;
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = widget
        .settingsController; // Use the SettingsController passed from the parent widget
    // quizesFuture = loadQuizes();
  }

  var dbHelper = DatabaseHelper();

  // Future<List<QuizCategory>>loadQuizes() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;
  //   //bool isFirstRun = true;
  //   var quizesFromJsons = <QuizCategory>[];
  //   if (isFirstRun) {
  //     // Get the asset manifest
  //     final manifestContent = await rootBundle.loadString('AssetManifest.json');
  //     final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  //     // Get the paths of all JSON files in the assets folder
  //     final jsonPaths = manifestMap.keys
  //         .where((String key) => path.extension(key) == '.json')
  //         .where((String key) => key.startsWith('assets/quizes_jsons/'))
  //         .toList();

  //     // Load each JSON file and convert it to a ShortcutCategory object
  //     for (var jsonPath in jsonPaths) {
  //       final jsonString = await rootBundle.loadString(jsonPath);
  //       final jsonData = json.decode(jsonString);

  //       if (jsonData is List) {
  //         final quizCategoriesJsons = jsonData
  //             .map(
  //                 (item) => QuizCategory.fromJson(item as Map<String, dynamic>))
  //             .toList();
  //         quizesFromJsons.addAll(quizCategoriesJsons
  //             .where((quiz) => quiz.quizQuestions.length > 1));
  //       } else if (jsonData is Map) {
  //         final quiz = QuizCategory.fromJson(jsonData as Map<String, dynamic>);
  //         if (quiz.quizQuestions.length > 1) {
  //           quizesFromJsons.add(quiz);
  //         } else {
  //           throw Exception(
  //               'Quiz at $jsonPath should have more than one question.');
  //         }
  //       }
  //       }

  //       // Save quizzes to the database
  //     for (QuizCategory quiz in quizesFromJsons) {
  //       await saveQuizToDatabase(quiz);
  //     }

  //     await prefs.setBool('isFirstRun', false);

  //     // Return the completed list
  //   } else {
  //     quizesFromJsons = await dbHelper.loadQuizzesFromDatabase();
  //   }
  //   return quizesFromJsons;
  // }

  // saveQuizToDatabase(QuizCategory quiz) async {
  //   await dbHelper.saveQuizToDatabase(quiz);
  // }

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
  // void resetDatabase() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isFirstRun', true);
  //   await loadQuizes();
  // }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsController,
      builder: (BuildContext context, Widget? child) {
        return Consumer<QuizListProvider>(
            builder: (context, quizListProvider, child) {
          // if (quizListProvider.quizzes == null) {
          //   return const Scaffold(
          //     body: Center(
          //       child:
          //           CircularProgressIndicator(), // Show a loading spinner while waiting
          //     ),
          //   );
          // } else  {
          // showDialog(
          //   context: context,
          //   builder: (BuildContext context) {
          //     return AlertDialog(
          //       title: const Text('Error'),
          //       content: Text('${snapshot.error}'),
          //       actions: <Widget>[
          //         TextButton(
          //           child: const Text('OK'),
          //           onPressed: () {
          //             Navigator.of(context).pop();
          //           },
          //         ),
          //       ],
          //     );
          //   },
          // );
          // return Container(); // Return an empty container when an error occurs

          final items = quizListProvider.quizzes;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Quiz categories'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, SettingsView.routeName);
                  },
                ),
              ],
            ),
            body: ListView.builder(
              restorationId: 'quizListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
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
                          dbHelper
                              .updateQuizCategory(item); // Update the database
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
                          dbHelper
                              .updateQuizCategory(item); // Update the database
                        });
                      },
                    ),
                    IconSlideAction(
                      caption: 'Sort',
                      color: Colors.orange,
                      icon: Icons.sort,
                      onTap: () async {
                        final newSortType = await showDialog<SortType>(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text('Choose sorting method'),
                              children: <Widget>[
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, SortType.original);
                                  },
                                  child: const Text('Original'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, SortType.reversed);
                                  },
                                  child: const Text('Reversed'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, SortType.question);
                                  },
                                  child: const Text('question'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(
                                        context, SortType.questionReversed);
                                  },
                                  child: const Text('questionReversed'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, SortType.answer);
                                  },
                                  child: const Text('answer'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(
                                        context, SortType.answerReversed);
                                  },
                                  child: const Text('answerReversed'),
                                ),
                                // Add more SimpleDialogOptions for more sorting methods
                              ],
                            );
                          },
                        );

                        if (newSortType != null) {
                          setState(() {
                            item.selectedSortType = newSortType;
                          });
                          await dbHelper.updateQuizCategory(item);
                        }
                      },
                    ),
                  ],
                  secondaryActions: <Widget>[
                    // Add your secondary actions here
                    IconSlideAction(
                      caption: 'Edit',
                      color: Colors.blue,
                      icon: Icons.edit,
                      onTap: () async {
                        final updatedItem = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ConstructQuizScreen(item: item),
                          ),
                        );
                        if (updatedItem != null) {
                          setState(() {
                            // Replace the old QuizCategory object with the updated one
                            int index = items.indexOf(item);
                            if (index != -1) {
                              items[index] = updatedItem;
                            }
                          });
                        }
                      },
                    ),
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this item?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Delete'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    // Replace with your delete function
                                    if (item.id != null) {
                                      await dbHelper
                                          .deleteQuizCategory(item.id!);
                                      setState(() {
                                        items.remove(item);
                                      });
                                    } else {
                                      // Handle the case where item.id is null
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
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
        });
      },
    );
  }
}
