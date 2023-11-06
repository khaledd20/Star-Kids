import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'installment_receipt.dart';
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
  String? selectedStudent; // Add selectedStudent variable
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
    return Directionality(
      textDirection: TextDirection.rtl, // Set textDirection to right-to-left (rtl)
      child: Scaffold(
        appBar: AppBar(
          title: Text('شاشة الأقساط'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 30, 57)
              ),
                child: Text(
                  'قائمة المشرف',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.navigate_next),
                title: Text('الحضور'),
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
                title: Text('إضافة طالب'), // Text for Student Management
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
                title: Text('الأقساط'), // Text for Student Management
                onTap: () {
                  // Close the drawer and navigate to the StudentManagementScreen
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => InstallmentsScreen(),
                  ));
                },
              ),
              ListTile(
                title: Text('تسجيل الخروج'),
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
                  'إدخال تفاصيل القسط:',
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
                      decoration: InputDecoration(labelText: 'الصف'),
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
                      decoration: InputDecoration(labelText: 'اسم الطالب'),
                      value: selectedStudent,
                      items: studentDropdownItems,
                      onChanged: (value) {
                        setState(() {
                          selectedStudent = value ?? '';
                        });
                      },
                    );
                  },
                ),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'المبلغ'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'التاريخ'),
                  onTap: () => _selectDate(context),
                ),
                TextFormField(
                  controller: receiptNumberController,
                  decoration: InputDecoration(labelText: 'رقم الإيصال'),
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
                      'studentName': selectedStudent,
                      'amount': amount,
                      'date': date,
                      'receiptNumber': receiptNumber,
                    });

                    // Retrieve the student's data from the Students collection
                    final studentSnapshot = await _firestore
                        .collection('Students')
                        .where('name', isEqualTo: selectedStudent)
                        .get();

                    if (studentSnapshot.docs.isNotEmpty) {
                      final studentData = studentSnapshot.docs[0].data() as Map<String, dynamic>;
                      final feesLeft = studentData['feesLeft'] ?? 0.0;
                      final studentFees = studentData['fees'] ?? 0.0;
                      final installments = studentData['installments'] ?? 0;
                      final installmentsLeft = studentData['installmentsLeft'] ?? 0;

                      // Calculate the new feesLeft value
                      final newFeesLeft = feesLeft - amount;

                      // Calculate the new installmentsLeft value
                      final newInstallmentsLeft = installmentsLeft - 1;

                      // Update the feesLeft field in the Students collection
                      await studentSnapshot.docs[0].reference.update({'feesLeft': newFeesLeft});

                      // Update the installmentsLeft field in the Students collection
                      await studentSnapshot.docs[0].reference.update({'installmentsLeft': newInstallmentsLeft});

                      // Navigate to the InstallmentReceiptScreen with additional student data
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => InstallmentReceiptScreen(
                            selectedClass: selectedClass ?? '', // Provide a default value
                            studentName: selectedStudent ?? '',
                            amount: amount,
                            date: date,
                            receiptNumber: receiptNumber,
                            studentFeesLeft: newFeesLeft,
                            studentInstallments: installments,
                            studentInstallmentsLeft: newInstallmentsLeft,
                          ),
                        ),
                      );
                    }

                    // Clear the text controllers after saving
                    amountController.clear();
                    dateController.clear();
                    receiptNumberController.clear();
                  },
                  child: Text('حفظ القسط'),
                ),
              ],
            ),
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