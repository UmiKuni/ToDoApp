import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/models/task.dart';
import 'package:todoapp/screens/task_create.dart';
import 'package:todoapp/screens/task_detail.dart';
import 'package:todoapp/utils/database_helper.dart';

class TaskList extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  const TaskList({super.key, required this.databaseHelper});

  @override
  State<StatefulWidget> createState() {
    return _TaskListState();
  }
}

class _TaskListState extends State<TaskList> {
  // ==================== Properties ====================
  List<Task> items = [];
  int count = 0;
  Map<int, bool> checkboxStates = {};
  final TextEditingController searchQuery = TextEditingController();
  final List<String> sortQuery = [
    "Latest Create",
    "Newest Create",
    "A to Z",
    "Z to A"
  ];
  final List<String> filterQuery = [
    'Completed',
    'Uncompleted',
    'Today',
    'This month',
    'This year'
  ];
  bool isReturned = false;
  String filterState = "";
  late String sortType;

  @override
  void initState() {
    super.initState();
    filterState = "";
    sortType = sortQuery[0];
    updateListView(sortType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Tasks",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        actions: [
          if (isReturned) ...[
            IconButton(
                onPressed: () {
                  updateListView(sortType);
                },
                icon: Icon(Icons.cancel))
          ],
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => searchDialog(context));
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              // Xử lý khi chọn item
              switch (value) {
                case 'Sort By':
                  showDialog(
                      context: context,
                      builder: (context) => sortDialog(context));
                  break;
                case 'Filter':
                  showDialog(
                      context: context,
                      builder: (context) => filterDialog(context));
                  break;
                case 'Progress':
                  showDialog(
                      context: context,
                      builder: (context) => progressDialog(context));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'Sort By',
                child: Text('Sort By'),
              ),
              const PopupMenuItem<String>(
                value: 'Filter',
                child: Text('Filter'),
              ),
              const PopupMenuItem<String>(
                value: 'Progress',
                child: Text('Progress'),
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
                const SizedBox(width: 10, height: 50),
                IconButton(
                  icon: const Icon(Icons.sort_outlined),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => sortDialog(context));
                  },
                ),
                Text(
                  sortType + filterState,
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
            updateListView(sortType);
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  // ==================== Methods ====================
  ListView getTaskListView() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        bool isChecked = checkboxStates[items[index].id] ?? false;
        return ListTile(
          tileColor: (checkboxStates[items[index].id] == true)
              ? Colors.black12
              : Colors.white70,
          title: Text(items[index].title),
          subtitle: Text(items[index].duedate),
          leading: Checkbox(
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  checkboxStates[items[index].id ?? 0] = value ?? false;
                });
              }),
          trailing: IconButton(
              onPressed: () {
                _deleteItem(context, items[index]);
                updateListView(sortType);
              },
              icon: const Icon(Icons.delete)),
          onTap: () async {
            Task? result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TaskDetail(modifierTask: items[index])),
            );
            if (result != null) {
              _updateItem(context, result);
              updateListView(sortType);
            }
          },
        );
      },
    );
  }

  void _deleteItem(BuildContext context, Task task) async {
    int result = await widget.databaseHelper.deleteTask(task.id);
    if (result != 0) {
      _showSnackBar("Task Deleted Successfully!");
      updateListView(sortType);
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
    int result = await widget.databaseHelper.insertTask(task);
    if (result != 0) {
      _showSnackBar("Task Added Successfully!");
    }
  }

  void _updateItem(BuildContext, Task task) async {
    int result = await widget.databaseHelper.updateTask(task);
    if (result != 0) {
      _showSnackBar("Updated Successfully!");
    }
  }

  void updateListView(String sortQuery) {
    final Future<Database> dbFuture = widget.databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = widget.databaseHelper.getTaskList();
      taskListFuture.then((taskList) {
        setState(() {
          filterState = "";
          isReturned = false;
          items = sortWithQuery(sortQuery, taskList);
          sortType = sortQuery;
          count = taskList.length;
        });
      });
    });
  }

  void searchList(String query) {
    final Future<Database> dbFuture = widget.databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = widget.databaseHelper.searchTask(query);
      taskListFuture.then((taskList) {
        setState(() {
          isReturned = true;
          items = taskList;
          count = taskList.length;
        });
      });
    });
  }

  List<Task> sortWithQuery(String query, List<Task> newList) {
    if (query != sortType) {
      switch (query) {
        case 'Latest Create':
          newList = _sortLatestCreate(newList);
          break;
        case 'Newest Create':
          newList = _sortNewestCreate(newList);
          break;
        case 'A to Z':
          newList = _sortAtoZ(newList);
          break;
        case 'Z to A':
          newList = _sortZtoA(newList);
          break;
      }
    }
    return newList;
  }

  List<Task> _sortLatestCreate(List<Task> list) {
    int size = list.length;
    for (int i = 0; i < size - 1; i++) {
      for (int j = i + 1; j < size; j++) {
        if (list[i].id! > list[j].id!) {
          Task pre = list[i];
          list[i] = list[j];
          list[j] = pre;
        }
      }
    }
    return list;
  }

  List<Task> _sortNewestCreate(List<Task> list) {
    int size = list.length;
    for (int i = 0; i < size - 1; i++) {
      for (int j = i + 1; j < size; j++) {
        if (list[i].id! < list[j].id!) {
          Task pre = list[i];
          list[i] = list[j];
          list[j] = pre;
        }
      }
    }
    return list;
  }

  List<Task> _sortAtoZ(List<Task> list) {
    int size = list.length;
    for (int i = 0; i < size - 1; i++) {
      for (int j = i + 1; j < size; j++) {
        if (list[i]
                .title[0]
                .toLowerCase()
                .compareTo(list[j].title[0].toLowerCase()) >
            0) {
          Task pre = list[i];
          list[i] = list[j];
          list[j] = pre;
        }
      }
    }
    return list;
  }

  List<Task> _sortZtoA(List<Task> list) {
    int size = list.length;
    for (int i = 0; i < size - 1; i++) {
      for (int j = i + 1; j < size; j++) {
        if (list[j]
                .title[0]
                .toLowerCase()
                .compareTo(list[i].title[0].toLowerCase()) >
            0) {
          Task pre = list[i];
          list[i] = list[j];
          list[j] = pre;
        }
      }
    }
    return list;
  }

  void filterListView(String query) {
    int size = items.length;
    List<Task> filterList = [];

    switch (query) {
      case 'Completed':
        for (int i = 0; i < size; i++) {
          if (checkboxStates[items[i].id] == true) {
            filterList.add(items[i]);
          }
        }
        break;
      case 'Uncompleted':
        for (int i = 0; i < size; i++) {
          if (checkboxStates[items[i].id] == false ||
              checkboxStates[items[i].id] == null) {
            filterList.add(items[i]);
          }
        }
        break;
      case 'This year':
        int currentYear = DateTime.now().year;
        for (int i = 0; i < size; i++) {
          DateTime dt = DateFormat("d MMM yyyy").parse(items[i].duedate);
          if (dt.year == currentYear) {
            filterList.add(items[i]);
          }
        }
        break;
      case 'This month':
        int currentYear = DateTime.now().year;
        int currentMonth = DateTime.now().month;
        for (int i = 0; i < size; i++) {
          DateTime dt = DateFormat("d MMM yyyy").parse(items[i].duedate);
          if (dt.year == currentYear && dt.month == currentMonth) {
            filterList.add(items[i]);
          }
        }
        break;
      case 'Today':
        int currentDate = DateTime.now().day;
        int currentYear = DateTime.now().year;
        int currentMonth = DateTime.now().month;
        for (int i = 0; i < size; i++) {
          DateTime dt = DateFormat("d MMM yyyy").parse(items[i].duedate);
          if (dt.year == currentYear &&
              dt.month == currentMonth &&
              dt.day == currentDate) {
            filterList.add(items[i]);
          }
        }
        break;
    }
    setState(() {
      if (!filterState.contains(query)) {
        filterState += " | $query";
      }
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
            updateListView(sortType);
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
            } else {
              updateListView(sortType);
            }
          },
        ),
      ],
    );
  }

  Widget sortDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Sort By"),
      content: SizedBox(
        width: double.maxFinite, // Take maximum width
        height: 230, // Fixed height or adjust as needed
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sortQuery.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: (sortQuery[index] == sortType)
                  ? Icon(
                      Icons.check_circle) // Hiện biểu tượng nếu điều kiện đúng
                  : Icon(Icons.circle_outlined),
              title: Text(sortQuery[index]),
              onTap: () {
                updateListView(sortQuery[index]);
                Navigator.pop(context, sortQuery[index]);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            updateListView(sortType);
            Navigator.of(context).pop(); // Close the dialog
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
        height: 270, // Fixed height or adjust as needed
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filterQuery.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.filter_alt),
              title: Text(filterQuery[index]),
              onTap: () {
                filterListView(filterQuery[index]);
                Navigator.pop(context, filterQuery[index]);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            updateListView(sortType);
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }

  Widget progressDialog(BuildContext context) {
    int comp = 0;
    int uncomp = 0;
    int size = items.length;
    for (int i = 0; i < size; i++) {
      if (checkboxStates[items[i].id] == true) {
        comp++;
      } else {
        uncomp++;
      }
    }
    int progress = (100 * comp / size).toInt();
    return AlertDialog(
      title: Text("Current Progress: $progress%"),
      content: SizedBox(
          width: double.maxFinite, // Take maximum width
          height: 170,
          child: Column(
            children: [
              ListTile(title: Text("Total tasks: " + count.toString())),
              ListTile(title: Text("Completed tasks: " + comp.toString())),
              ListTile(title: Text("Uncompleted tasks: " + uncomp.toString())),
            ],
          )),
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
