import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:todoapp/models/task.dart';

class DatabaseHelper {

  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database;             // Singleton Database

  String taskTable = 'task_table';
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colFrequency = "frequency";
  String colDueDate = "duedate";

  DatabaseHelper._createInstance();

  factory DatabaseHelper(){

    _databaseHelper ??= DatabaseHelper._createInstance();

    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path to store the database
    Directory directory = await getApplicationDocumentsDirectory();

    // Ensure correct path for the database file (add the separator)
    String path = '${directory.path}/task.db';  // Add '/' between path and file name

    // Open/Create the database at the path
    var tasksDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return tasksDatabase;
  }


  void _createDb(Database db, int newVersion) async {
    
    await db.execute(
      'CREATE TABLE $taskTable('
      '$colId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$colTitle TEXT, '
      '$colDescription TEXT, '
      '$colFrequency TEXT, '
      '$colDueDate TEXT)');

    await db.execute(
      'CREATE TABLE user_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'username TEXT UNIQUE, '
      'password TEXT)');
  }

// ==================== REGION: API ====================
  // Fetch Operations
  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.database;

    var result = await db.query(taskTable);
    return result;
  }

  // Insert Operations
  Future<int> insertTask(Task task) async {
    Database db = await this.database;
    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  // Update Operations
  Future<int> updateTask(Task task) async {
    Database db = await this.database;
    var result = await db.update(taskTable, task.toMap(), where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  // Delete Operations
  Future<int> deleteTask(int? id) async {
    Database db = await this.database;
    var result = await db.rawDelete('DELETE FROM $taskTable WHERE $colId = $id');
    return result;
  }

  // Get number of Task object in dtb
  Future<int?> getCount() async {
    Database db = await this.database;

    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) FROM $taskTable');
    int? result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the List of Map object from dtb and convert it to List of Task object
  Future<List<Task>> getTaskList() async {
    var taskMapList = await getTaskMapList();
    int count = taskMapList.length;

    List<Task> taskList = [];

    for(int i = 0; i < count; i++){
      taskList.add(Task.fromMapObject(taskMapList[i]));
    }

    return taskList;
  }
  
  // Search Operations
  Future<List<Task>> searchTask(String query) async {
    Database db = await this.database;

    var result = await db.rawQuery('SELECT * FROM $taskTable WHERE $colTitle LIKE ?', ['%$query%']);

    int count = result.length;
    List<Task> taskList = [];

    for(int i = 0; i < count; i++){
      taskList.add(Task.fromMapObject(result[i]));
    }

    return taskList;
  }

  // Register new user
  Future<int> registerUser(String username, String password) async {
    Database db = await this.database;
    try {
      var result = await db.insert('user_table', {
        'username': username,
        'password': password,
      });
      return result;
    } catch (e) {
      // Return -1 if username already exists or error occurs
      return -1;
    }
  }

  // Login user
  Future<bool> loginUser(String username, String password) async {
    Database db = await this.database;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS user_table('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'username TEXT UNIQUE, '
      'password TEXT)'
    );
    var result = await db.query(
      'user_table',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }
// ==================== END REGION ====================
}