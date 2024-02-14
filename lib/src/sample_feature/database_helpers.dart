/// DatabaseHelper provides helper methods to initialize the database,
/// save and load quiz categories and questions, and perform CRUD operations.
/// It uses SQFlite to manage the SQLite database.
library;

import 'dart:io' as io;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'quiz_categories.dart';
import 'quiz_question.dart';
import 'package:sqflite/sqflite.dart';

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
        "CREATE TABLE QuizCategories(id INTEGER PRIMARY KEY, category TEXT, randomQuestions INTEGER, isTestQuiz INTEGER, selectedSortType INTEGER)");
    await db.execute(
        "CREATE TABLE Quizzes(id INTEGER PRIMARY KEY, question TEXT, answer TEXT, note TEXT, categoryId INTEGER, orderindex INTEGER, FOREIGN KEY(categoryId) REFERENCES QuizCategories(id))");
  }

  Future<int> saveQuizCategory(QuizCategory quizCategory) async {
    var dbClient = await db;
    int res = await dbClient!.insert("QuizCategories", quizCategory.toMap());
    quizCategory.id = res;
    return res;
  }

  Future<QuizCategory?> updateQuizCategory(QuizCategory quizCategory) async {
    var dbClient = await db;
    QuizCategory? updatedQuizCategory;

    int updateRes = await dbClient!.update(
      "QuizCategories",
      quizCategory.toMap(),
      where: "id = ?",
      whereArgs: [quizCategory.id],
    );

    if (updateRes > 0) {
      await dbClient.delete("Quizzes",
          where: "categoryId = ?", whereArgs: [quizCategory.id]);

      for (int i = 0; i < quizCategory.quizQuestions.length; i++) {
        QuizQuestion quizQuestion = quizCategory.quizQuestions[i];

        Map<String, dynamic> quizQuestionMap = quizQuestion.toMap();
        quizQuestionMap['categoryId'] = quizCategory.id;
        quizQuestionMap['orderindex'] = i;

        await dbClient.insert(
          'Quizzes',
          quizQuestionMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      List<Map> maps = await dbClient.query(
        "QuizCategories",
        columns: [
          "id",
          "category",
          "randomQuestions",
          "isTestQuiz",
          "selectedSortType"
        ],
        where: "id = ?",
        whereArgs: [quizCategory.id],
      );

      if (maps.isNotEmpty) {
        updatedQuizCategory =
            await QuizCategory.fromMap(maps.first as Map<String, dynamic>);
      }
    }

    return updatedQuizCategory;
  }

  Future<int> deleteQuizCategory(int id) async {
    var dbClient = await db;
    await dbClient!.delete("QuizCategories", where: "id = ?", whereArgs: [id]);
    int res = await dbClient
        .delete("QuizCategories", where: "id = ?", whereArgs: [id]);
    return res;
  }

  Future<void> saveQuizToDatabase(QuizCategory quizCategory) async {
    var dbClient = await DatabaseHelper().db;

    int categoryId = await dbClient!.insert(
      'QuizCategories',
      quizCategory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    quizCategory.id = categoryId;

    for (int i = 0; i < quizCategory.quizQuestions.length; i++) {
      QuizQuestion quizQuestion = quizCategory.quizQuestions[i];

      Map<String, dynamic> quizQuestionMap = quizQuestion.toMap();
      quizQuestionMap['categoryId'] = categoryId;
      quizQuestionMap['orderindex'] = i;

      await dbClient.insert(
        'Quizzes',
        quizQuestionMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<QuizCategory>> loadQuizzesFromDatabase() async {
    var dbClient = await db;
    List<Map<String, dynamic>> categoryMaps =
        await dbClient!.query('QuizCategories');
    List<QuizCategory> quizCategories = [];

    for (var categoryMap in categoryMaps) {
      int categoryId = categoryMap['id'];
      List<QuizQuestion> quizQuestions = await fetchQuizQuestions(categoryId);

      QuizCategory quizCategory = await QuizCategory.fromMap(categoryMap);
      quizCategory.quizQuestions = quizQuestions;

      quizCategories.add(quizCategory);
    }

    return quizCategories;
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(int categoryId) async {
    var dbClient = await db;
    List<Map> result = await dbClient!.query(
      "Quizzes",
      where: "categoryId = ?",
      whereArgs: [categoryId],
      orderBy: 'orderindex ASC',
    );

    return result
        .map((item) => QuizQuestion.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
