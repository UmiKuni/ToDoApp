import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/screens/task_create.dart';
import 'package:todoapp/screens/task_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/', // Đường dẫn mặc định
      routes: {
        '/': (context) => const TaskList(),
        '/AddTasks': (context) => const TaskCreate(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
    );
  }
}



