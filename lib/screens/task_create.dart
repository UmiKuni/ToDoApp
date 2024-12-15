import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/models/task.dart';

class TaskCreate extends StatefulWidget {
  const TaskCreate({super.key});

  @override
  State<StatefulWidget> createState(){
    return _TaskCreateState();
  }
}

class _TaskCreateState extends State<TaskCreate>{
  // ==================== Properties ====================
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  final List<String> frequencies = ["Daily", "Weekly", "Monthly", "Yearly"]; // Danh sách các lựa chọn
  String? selectedFrequency;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        title: const Text("Create Task", style: TextStyle(fontWeight: FontWeight.w500)),
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
                Text('Description'),
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
                Text('Select Frequency'),
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
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  if(title.text == "" || description.text == "" || selectedFrequency == null || selectedDate == null){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter valid information"),
                      ),
                    );
                  }
                  else{
                    Task newItem = Task(title.text, description.text, selectedFrequency!, DateFormat('d MMM yyyy').format(selectedDate!));
                    Navigator.pop(context, newItem);
                  }
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

  // ==================== Methods ====================

}