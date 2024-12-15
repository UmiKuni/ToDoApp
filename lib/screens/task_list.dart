import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/screens/task_create.dart';
import 'package:todoapp/utils/database_helper.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<StatefulWidget> createState(){
    return _TaskListState();
  }
}

class _TaskListState extends State<TaskList>{

  // ==================== Properties ====================
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Task> items = [];
  int count = 0;
  Map<int, bool> checkboxStates = {};

  @override
  void initState() {
    super.initState();
    updateListView();
    debugPrint('initState - Called once when screen is created');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Tasks"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: getTaskListView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Task? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskCreate()),
          );
          if (result != null) {
            _addItem(context, result);
            updateListView();
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  // ==================== Methods ====================
  ListView getTaskListView(){
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        bool isChecked = checkboxStates[items[index].id] ?? false;
        return ListTile(
          tileColor: Colors.white70,
          title: Text(items[index].title),
          subtitle: Text(items[index].duedate),
          leading: Checkbox(
              value: isChecked,
              onChanged: (bool? value){
                setState(() {
                  checkboxStates[items[index].id ?? 0] = value ?? false;
                });
              }),
          trailing: IconButton(
              onPressed: () { _deleteItem(context, items[index]); updateListView();},
              icon: const Icon(Icons.delete)
          ),
        );
      },
    );
  }

  void _deleteItem(BuildContext context, Task task) async {
    int result = await databaseHelper.deleteTask(task.id);
    if(result != 0){
      _showSnackBar("Task Deleted Successfully!");
      updateListView();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _addItem(BuildContext context, Task task) async {
    int result = await databaseHelper.insertTask(task);
    if(result != 0){
      _showSnackBar("Task Added Successfully! at ID: $result");
    }
    else{
      _showSnackBar("ID: $result");
    }
  }

  void updateListView(){
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList();
      taskListFuture.then((taskList){
        setState(() {
          items = taskList;
          count = taskList.length;
        });
      });
    });
  }
}

