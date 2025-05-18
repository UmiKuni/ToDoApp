import 'package:flutter/material.dart';
import 'package:todoapp/screens/login.dart';
import 'package:todoapp/screens/register.dart';
import 'package:todoapp/screens/task_create.dart';
import 'package:todoapp/screens/task_list.dart';
import 'package:todoapp/utils/database_helper.dart';

void main() {
  final databaseHelper = DatabaseHelper();
  runApp(MyApp(db: databaseHelper));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.db});
  final DatabaseHelper db;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/Login',
      routes: {
        '/Login': (context) => LoginScreen(databaseHelper: db),
        '/Register': (context) => RegisterScreen(databaseHelper: db),
        '/': (context) => TaskList(databaseHelper: db),
        '/AddTasks': (context) => const TaskCreate(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
    );
  }
}
