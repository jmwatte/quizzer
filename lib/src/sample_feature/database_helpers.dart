/// DatabaseHelper provides helper methods to initialize the database,
/// save and load quiz categories and questions, and perform CRUD operations.
/// It uses SQFlite to manage the SQLite database.
library;

import 'dart:io' as io;

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'quiz.dart';
import 'quiz_question.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database? _db;

  DatabaseHelper.internal();

  /// Retrieves the singleton instance of the DatabaseHelper.

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String pathd = path.join(documentsDirectory.path, "main.db");
    var theDb = await openDatabase(pathd, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE Quiz(id INTEGER PRIMARY KEY , title TEXT, randomQuestions INTEGER, isTestQuiz INTEGER, selectedSortType INTEGER)");
    await db.execute(
        "CREATE TABLE Questions(id INTEGER PRIMARY KEY, question TEXT, answer TEXT, note TEXT, quizId INTEGER, orderindex INTEGER, FOREIGN KEY(quizId) REFERENCES Quiz(id))");
  }

  Future<Quiz?> updateQuiz(Quiz quiz) async {
    var dbClient = await db;
    Quiz? updatedQuiz;

    int updateRes = await dbClient!.update(
      "Quiz",
      quiz.toMap(),
      where: "id = ?",
      whereArgs: [quiz.id],
    );

    if (updateRes > 0) {
      await dbClient
          .delete("Questions", where: "quizId = ?", whereArgs: [quiz.id]);

      for (int i = 0; i < quiz.quizQuestions.length; i++) {
        QuizQuestion quizQuestion = quiz.quizQuestions[i];

        Map<String, dynamic> quizQuestionMap = quizQuestion.toMap();
        quizQuestionMap['quizId'] = quiz.id;
        quizQuestionMap['orderindex'] = i;

        await dbClient.insert(
          'Questions',
          quizQuestionMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      List<Map> maps = await dbClient.query(
        "Quiz",
        columns: [
          "id",
          "title",
          "randomQuestions",
          "isTestQuiz",
          "selectedSortType"
        ],
        where: "id = ?",
        whereArgs: [quiz.id],
      );

      if (maps.isNotEmpty) {
        updatedQuiz = await Quiz.fromMap(maps.first as Map<String, dynamic>);
      }
    }

    return updatedQuiz;
  }

//here we delete the Quizes and all the questions that are in that quiz and have the same quizId
  Future<int> deleteQuizAndQuestions(int id) async {
    var dbClient = await db;
    int res = await dbClient!.delete("Quiz", where: "id = ?", whereArgs: [id]);
    await dbClient.delete("Questions", where: "quizId = ?", whereArgs: [id]);
    return res;
  }

  Future<void> saveQuizToDatabase(Quiz quiz) async {
    var dbClient = await DatabaseHelper().db;

    int quizId = await dbClient!.insert(
      'Quiz',
      quiz.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    quiz.id = quizId;

    for (int i = 0; i < quiz.quizQuestions.length; i++) {
      QuizQuestion quizQuestion = quiz.quizQuestions[i];

      Map<String, dynamic> quizQuestionMap = quizQuestion.toMap();
      quizQuestionMap['quizId'] = quizId;
      quizQuestionMap['orderindex'] = i;

      await dbClient.insert(
        'Questions',
        quizQuestionMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Quiz>> loadQuizzesFromDatabase() async {
    var dbClient = await db;
    List<Map<String, dynamic>> quizMaps =
        await dbClient!.query('Quiz'); //get the
    List<Quiz> quizes = [];

    for (var quizMap in quizMaps) {
      int quizId = quizMap['id'];
      List<QuizQuestion> quizQuestions = await fetchQuizQuestions(quizId);

      Quiz quiz = await Quiz.fromMap(quizMap);
      quiz.quizQuestions = quizQuestions;
      quizes.add(quiz);
    }

    return quizes;
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(int quizId) async {
    var dbClient = await db;
    List<Map> result = await dbClient!.query(
      "Questions",
      where: "quizId = ?",
      whereArgs: [quizId],
      orderBy: 'orderindex ASC',
    );

    return result
        .map((item) => QuizQuestion.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
