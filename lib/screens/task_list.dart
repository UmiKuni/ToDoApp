import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/screens/task_create.dart';
import 'package:todoapp/screens/task_detail.dart';
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
  final TextEditingController searchQuery = TextEditingController();
  final List<String> sortQuery = ["Created Date", "A - Z", "Z - A", "Due date"];
  final List<String> filterQuery = ["Completed", "Uncompleted", "This year", "This month"];
  bool isReturned = false;
  String sortType = "Created Date";

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Tasks", style: TextStyle(fontWeight: FontWeight.w500),),
        actions: [
          if(isReturned)...[
            IconButton(
                onPressed: (){
                  updateListView();
                },
                icon: Icon(Icons.cancel))
          ],
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (context) => searchDialog(context)
              );
            },),
          PopupMenuButton<String>(
            onSelected: (String value) {
              // Xử lý khi chọn item
              print('You selected: $value');
              switch(value){
                case 'Sort By':
                  break;
                case 'Filter':
                  showDialog(
                      context: context,
                      builder: (context) => filterDialog(context)
                  );
                  break;
                case 'Progress':
                  showDialog(
                      context: context,
                      builder: (context) => progressDialog(context)
                  );
                  break;
                case 'Settings':
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Sort By',
                child: Text('Sort By'),
              ),
              PopupMenuItem<String>(
                value: 'Filter',
                child: Text('Filter'),

              ),
              PopupMenuItem<String>(
                value: 'Progress',
                child: Text('Progress'),

              ),
              PopupMenuItem<String>(
                value: 'Settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                SizedBox(width: 10, height: 50),
                Icon(Icons.sort_outlined),
                Text(
                  sortType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.deepOrange,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
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
          onTap: () async {
            Task? result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskDetail(modifierTask: items[index])),
            );
            if (result != null) {
              _updateItem(context, result);
              updateListView();
            }
          },
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
      _showSnackBar("Task Added Successfully!");
    }
  }

  void _updateItem(BuildContext, Task task) async {
    int result = await databaseHelper.updateTask(task);
    if(result != 0){
      _showSnackBar("Updated Successfully!");
    }
  }

  void updateListView(){
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList();
      taskListFuture.then((taskList){
        setState(() {
          isReturned = false;
          items = taskList;
          count = taskList.length;
        });
      });
    });
  }

  void searchList(String query) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.searchTask(query);
      taskListFuture.then((taskList){
        setState(() {
          isReturned = true;
          items = taskList;
          count = taskList.length;
        });
      });
    });

  }

  void sortListView(String query){

  }

  void filterListView(String query){
    int count = items.length;
    List<Task> filterList = [];

    switch(query){
      case 'Completed':
        for(int i = 0; i < count; i++){
          if(checkboxStates[items[i].id] == true){
            filterList.add(items[i]);
          }
        }
        break;
      case 'Uncompleted':
        for(int i = 0; i < count; i++){
          if(checkboxStates[items[i].id] == false){
            filterList.add(items[i]);
          }
        }
        break;
      case 'This year':
        int currentYear = DateTime.now().year;
        for(int i = 0; i < count; i++){
          DateTime dt = DateFormat("d MMM yyyy").parse(items[i].duedate);
          if(dt.year == currentYear ){
            filterList.add(items[i]);
          }
        }
        break;
      case 'This month':
        int currentYear = DateTime.now().year;
        int currentMonth = DateTime.now().month;
        for(int i = 0; i < count; i++){
          DateTime dt = DateFormat("d MMM yyyy").parse(items[i].duedate);
          if(dt.year == currentYear && dt.month == currentMonth){
            filterList.add(items[i]);
          }
        }
        break;
    }
    setState(() {
      isReturned = true;
      items = filterList;
      count = filterList.length;
    });
  }

  Widget searchDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Searching'),
      content: TextField(
        controller: searchQuery,
        decoration: const InputDecoration(
          hintText: 'Find tasks',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            updateListView();
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        ElevatedButton(
          child: const Text('Find'),
          onPressed: () {
            String inputValue = searchQuery.text;
            if (inputValue.isNotEmpty) {
              // Process the input
              searchList(inputValue);
              Navigator.of(context).pop(); // Close the dialog
            }
            else {
              updateListView();
            }
          },
        ),
      ],
    );
  }

  Widget filterDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter"),
      content: SizedBox(
        width: double.maxFinite, // Take maximum width
        height: 250, // Fixed height or adjust as needed
        child: ListView.builder(
        shrinkWrap: true,
        itemCount: filterQuery.length,
        itemBuilder: (context, index){
          return ListTile(
            title: Text(filterQuery[index]),
            onTap: (){
              filterListView(filterQuery[index]);
              Navigator.pop(context, filterQuery[index]);
            },
          );},
      ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            updateListView();
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }

  Widget progressDialog(BuildContext context){
    int comp = 0;
    int uncomp = 0;
    int size = items.length;
    for (int i = 0; i < size; i++){
      if(checkboxStates[items[i].id] == true){
        comp++;
      }
      else{
        uncomp++;
      }
    }
    int progress = (100 * comp/size).toInt();
    return AlertDialog(
      title: Text("Current Progress: $progress%"),
      content: SizedBox(
        width: double.maxFinite, // Take maximum width
        height: 170,
        child: Column(
          children: [
            ListTile(
                title: Text("Total tasks: " + count.toString())
            ),
            ListTile(
                title: Text("Completed tasks: " + comp.toString())
            ),
            ListTile(
                title: Text("Uncompleted tasks: " + uncomp.toString())
            ),
          ],
        )
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}

