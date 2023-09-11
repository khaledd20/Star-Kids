import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'studentAdd.dart';
import 'studentAttendance.dart';

class InstallmentsScreen extends StatefulWidget {
  @override
  _InstallmentsScreenState createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController classController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController receiptNumberController = TextEditingController();
  DateTime? selectedDate;
  String? selectedClass;
  List<String> studentList = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateController.text = "${selectedDate!.toLocal()}".split(' ')[0];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Installments'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Moderator Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.navigate_next),
              title: Text('Attendance'),
              onTap: () {
                // Close the drawer and navigate to the studentAttendance
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StudentAttendanceScreen(user: null),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts), // Icon for Student Management
              title: Text('Student Add'), // Text for Student Management
              onTap: () {
                // Close the drawer and navigate to the StudentAddingScreen
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StudentAddingScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.payment_sharp), // Icon for Student Management
              title: Text('Finance'), // Text for Student Management
              onTap: () {
                // Close the drawer and navigate to the StudentManagementScreen
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => InstallmentsScreen(),
                ));
              },
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                    ),
                  );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Enter Installment Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Classes').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final classes = snapshot.data!.docs;

                  List<DropdownMenuItem<String>> classDropdownItems = [];

                  for (var classDoc in classes) {
                    final className = classDoc['name'];
                    classDropdownItems.add(
                      DropdownMenuItem<String>(
                        value: className,
                        child: Text(className),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Class'),
                    value: selectedClass,
                    items: classDropdownItems,
                    onChanged: (value) {
                      setState(() {
                        selectedClass = value;
                        studentList.clear(); // Clear the student list when class changes
                      });
                    },
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Students').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || selectedClass == null) {
                    return CircularProgressIndicator();
                  }

                  final students = snapshot.data!.docs;
                  List<String> studentsInSelectedClass = [];

                  for (var studentDoc in students) {
                    final studentData = studentDoc.data() as Map<String, dynamic>;
                    final studentClass = studentData['class'];

                    if (studentClass == selectedClass) {
                      final studentName = studentData['name'];
                      studentsInSelectedClass.add(studentName);
                    }
                  }

                  studentList = List.from(studentsInSelectedClass); // Convert to List<String>

                  List<DropdownMenuItem<String>> studentDropdownItems = [];

                  for (var studentName in studentsInSelectedClass) {
                    studentDropdownItems.add(
                      DropdownMenuItem<String>(
                        value: studentName,
                        child: Text(studentName),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Student Name'),
                    value: studentList.isNotEmpty ? studentList[0] : null,
                    items: studentDropdownItems,
                    onChanged: (value) {
                      setState(() {
                        studentNameController.text = value ?? '';
                      });
                    },
                  );
                },
              ),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date'),
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                controller: receiptNumberController,
                decoration: InputDecoration(labelText: 'Receipt Number'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Get the values from the text controllers
                  final amount = double.parse(amountController.text);
                  final date = dateController.text;
                  final receiptNumber = receiptNumberController.text;

                  // Save the installment data to Firestore in the "Finance" collection
                  await _firestore.collection('Finance').add({
                    'class': selectedClass,
                    'studentName': studentList.isNotEmpty ? studentList[0] : '',
                    'amount': amount,
                    'date': date,
                    'receiptNumber': receiptNumber,
                  });

                  // Retrieve the student's fees and feesLeft from the Students collection
                  final studentSnapshot = await _firestore
                      .collection('Students')
                      .where('name', isEqualTo: studentList.isNotEmpty ? studentList[0] : '')
                      .get();

                  if (studentSnapshot.docs.isNotEmpty) {
                    final studentData = studentSnapshot.docs[0].data() as Map<String, dynamic>;
                    final feesLeft = studentData['feesLeft'] ?? 0.0;

                    // Calculate the new feesLeft value
                    final newFeesLeft = feesLeft - amount;

                    // Update the feesLeft field in the Students collection
                    await studentSnapshot.docs[0].reference.update({'feesLeft': newFeesLeft});

                    // Get the current value of the installments field
                    final installmentsLeft = studentData['installmentsLeft'] ?? 0;

                    // Calculate the new value of installmentsLeft
                    final newInstallmentsLeft  = installmentsLeft - 1;


                    // Update the installmentsLeft field in the Students collection
                    await studentSnapshot.docs[0].reference.update({'installmentsLeft': newInstallmentsLeft });
                  }

                  // Clear the text controllers after saving
                  amountController.clear();
                  dateController.clear();
                  receiptNumberController.clear();
                },
                child: Text('Save Installment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InstallmentsScreen(),
  ));
}
