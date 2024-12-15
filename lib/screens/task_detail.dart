import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/models/task.dart';

class TaskDetail extends StatefulWidget{
  final Task modifierTask;
  const TaskDetail({super.key, required this.modifierTask});

  @override
  State<StatefulWidget> createState(){
    return _TaskDetailState();
  }
}

class _TaskDetailState extends State<TaskDetail>{
  // ==================== Properties ====================
  late final TextEditingController title;
  late final TextEditingController description;
  final List<String> frequencies = ["Daily", "Weekly", "Monthly", "Yearly"];
  String? selectedFrequency;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller từ modifierTask
    title = TextEditingController(text: widget.modifierTask.title);
    description = TextEditingController(text: widget.modifierTask.description);
    selectedFrequency = widget.modifierTask.frequency;
    selectedDate = DateFormat("d MMM yyyy").parse(widget.modifierTask.duedate);
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên của controller
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Edit Task", style: TextStyle(fontWeight: FontWeight.w500)),
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
                Text('Title: '),
              ],
            ),
            TextField(
              controller: title,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start, // Căn chỉnh các phần tử
              children: [
                Text('Description: '),
              ],
            ),
            TextField(
              controller: description,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start, // Căn chỉnh các phần tử
              children: [
                Text('Frequency: '),
              ],
            ),
            DropdownButtonFormField<String>(
              value: selectedFrequency,
              isExpanded: true, // Mở rộng chiều rộng dropdown
              hint: const Text("Select Frequency"),
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start, // Căn chỉnh các phần tử
              children: [
                Text('Due Date: '),
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
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  if(title.text == "" || description.text == "" || selectedFrequency == null || selectedDate == null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("New information is not valid"),
                      ),
                    );
                  }
                  else{
                    Task newItem = Task.withId(widget.modifierTask.id, title.text, description.text, selectedFrequency!, DateFormat('d MMM yyyy').format(selectedDate!));
                    Navigator.pop(context, newItem);
                  }
                },
                child: const Text(
                  "Edit",
                  style: TextStyle(
                    color: Colors.white,
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