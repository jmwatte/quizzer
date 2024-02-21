import 'package:flutter/foundation.dart';
import 'package:watch_it/watch_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'database_helpers.dart';
import 'construct_quiz_screen.dart';
import 'helpers.dart';
import 'quiz_categories.dart';
import '../settings/settings_view.dart';
import 'quiz_item_details_view.dart';
import 'sorting_handler.dart';

class QuizItemsListView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const QuizItemsListView({
    super.key,
  });

  static const routeName = '/';
  @override
  QuizItemsListViewState createState() => QuizItemsListViewState();
}

class QuizItemsListViewState extends State<QuizItemsListView> {
  late Future<List<Quiz>> quizesFuture;

  @override
  void initState() {
    super.initState();
  }

  var dbHelper = DatabaseHelper();

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
    final items = watchPropertyValue((QuizListProvider m) => m.quizzes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: watchPropertyValue((QuizListProvider m) => m.quizzes.isNotEmpty)
          ? ListView(
              restorationId: 'quizListView',
              children: items.map((item) {
                return Slidable(
                  key: Key(item.title),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: <Widget>[
                      SlidableAction(
                        label: 'Test',
                        backgroundColor:
                            item.isTestQuiz ? Colors.blue : Colors.grey,
                        icon: Icons.check_circle,
                        onPressed: (context) {
                          setState(() {
                            if (kDebugMode) {
                              print(item.isTestQuiz);
                            }
                            item.isTestQuiz = !item.isTestQuiz;
                            if (kDebugMode) {
                              print(item.isTestQuiz);
                            }
                            dbHelper.updateQuiz(item);
                          });
                        },
                      ),
                      SlidableAction(
                        label: 'Random',
                        backgroundColor:
                            item.randomQuestions ? Colors.green : Colors.grey,
                        icon: Icons.shuffle,
                        onPressed: (context) {
                          setState(() {
                            if (kDebugMode) {
                              print(item.randomQuestions);
                            }
                            item.randomQuestions = !item.randomQuestions;
                            if (kDebugMode) {
                              print(item.randomQuestions);
                            }
                            dbHelper.updateQuiz(item);
                          });
                        },
                      ),
                      SlidableAction(
                        label: 'Sort',
                        backgroundColor: Colors.orange,
                        icon: Icons.sort,
                        onPressed: (context) async {
                          final newSortType = await showDialog<SortType>(
                            context: context,
                            builder: (BuildContext context) {
                              return const SortingDialog();
                            },
                          );

                          if (newSortType != null) {
                            setState(() {
                              item.selectedSortType = newSortType;
                            });
                            await dbHelper.updateQuiz(item);
                          }
                        },
                      ),
                    ],
                  ),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: <Widget>[
                      SlidableAction(
                        label: 'Edit',
                        backgroundColor: Colors.blue,
                        icon: Icons.edit,
                        onPressed: (context) async {
                          final updatedItem = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ConstructQuizScreen(item: item),
                            ),
                          );
                          if (updatedItem != null) {
                            setState(() {
                              int index = items.indexOf(item);
                              if (index != -1) {
                                items[index] = updatedItem;
                              }
                            });
                          }
                        },
                      ),
                      SlidableAction(
                        label: 'Delete',
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        onPressed: (context) {
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
                                      if (item.id != null) {
                                        await dbHelper
                                            .deleteQuizAndQuestions(item.id!);
                                        setState(() {
                                          items.remove(item);
                                        });
                                      } else {}
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(item.title),
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
                      di<QuizProvider>().selectQuiz(item);

                      Navigator.restorablePushNamed(
                        context,
                        QuizItemDetailsView.routeName,
                      );
                    },
                  ),
                );
              }).toList(),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
