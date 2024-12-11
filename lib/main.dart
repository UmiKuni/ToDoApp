import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        '/': (context) => const MyHomePage(title: "All Tasks"),
        '/AddTasks': (context) => const AddTasksPage(title: "Add Tasks"),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Danh sách chứa các map với các key title, description, frequency, datetime
  List<Map<String, dynamic>> items = [];

  // Hàm để thêm giá trị vào danh sách
  void _addItem(Map<String, dynamic> newItem) {
    setState(() {
      items.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return TaskItem(
                    title: items[index]['title'],
                    description: items[index]['description'],
                    date: items[index]['date'],
                    frequency: items[index]['frequency'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic>? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTasksPage(title: "Add Tasks")),
          );
          if (result != null) {
            _addItem(result);
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskItem extends StatelessWidget{
  final String title;
  final String description;
  final String date;
  final String frequency;

  bool isChecked = true;

  TaskItem({required this.title, required this.description, required this.date, required this.frequency});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        height: 70,
        child: Row(
          children: [
            Checkbox(
                value: isChecked,
                onChanged: (bool? value) {

                }
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    Text(date + " | ", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(frequency + " | ", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(description, style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                )
              ],
            ),
            GestureDetector(
              onTap: (){

              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.delete, size: 20, color: Colors.grey),
              ),
            )
          ],
        ),
      )
    );
  }
}

class AddTasksPage extends StatefulWidget {
  const AddTasksPage({super.key, required this.title});

  final String title;

  @override
  State<AddTasksPage> createState() => _AddTasksPage();
}

class _AddTasksPage extends State<AddTasksPage>{
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  String? selectedFrequency; // Giá trị được chọn
  final List<String> frequencies = ["Daily", "Weekly", "Monthly", "Yearly"]; // Danh sách các lựa chọn

  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding bên ngoài
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 50),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start, // Căn chỉnh các phần tử
              children: [
                Text('Title'),
              ],
            ),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start, // Căn chỉnh các phần tử
              children: [
                Text('Description'),
              ],
            ),
            TextField(
              controller: _description,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start, // Căn chỉnh các phần tử
              children: [
                Text('Select Frequency'),
              ],
            ),
            DropdownButton<String>(
              value: selectedFrequency,
              isExpanded: true, // Mở rộng chiều rộng dropdown
              hint: Text("Select Frequency"),
              items: frequencies.map((String frequency) {
                return DropdownMenuItem<String>(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedFrequency = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start, // Căn chỉnh các phần tử
              children: [
                Text('Due Date'),
              ],
            ),
            InkWell(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Select Due Date",
                  suffixIcon: Icon(Icons.calendar_today), // Biểu tượng lịch
                ),
                child: Text(
                  selectedDate != null
                      ? "${selectedDate!.toLocal()}".split(' ')[0]
                      : "",
                ),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  Map<String, dynamic> newItem = {
                    'title': _title.text,
                    'description': _description.text,
                    'frequency': selectedFrequency,
                    'date': DateFormat('d MMM').format(selectedDate!),
                  };
                  Navigator.pop(context, newItem);
                },
                child: const Text(
                  "Add",
                  style: TextStyle(
                    color: Colors.white, // Đặt màu văn bản
                    fontSize: 15,       // Kích thước chữ
                    fontWeight: FontWeight.normal, // Đậm chữ (nếu cần)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.black, // Đặt màu văn bản
                    fontSize: 15,       // Kích thước chữ
                    fontWeight: FontWeight.normal, // Đậm chữ (nếu cần)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}