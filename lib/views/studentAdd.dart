import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'Installments.dart';
import 'login_screen.dart';
import 'studentAttendance.dart';

class StudentAddingScreen extends StatefulWidget {
  @override
  _StudentAddingScreenState createState() =>
      _StudentAddingScreenState();
}

class _StudentAddingScreenState extends State<StudentAddingScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController feesController = TextEditingController();
  final TextEditingController feesLeftController = TextEditingController();
  final TextEditingController installmentsController = TextEditingController();
  final TextEditingController installmentsLeftController =
      TextEditingController();

  String? selectedClassId;
  DateTime? selectedDate;

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
        birthdayController.text = "${selectedDate!.toLocal()}".split(' ')[0];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Adding'),
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
                'Welcome to the Student Adding Page!',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                'Students:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Students').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final students = snapshot.data!.docs;

                  return Column(
                    children: students.map((student) {
                      final studentData =
                          student.data() as Map<String, dynamic>;
                      final studentId = student.id;
                      final studentName = studentData['name'] ?? '';
                      final studentBirthday = studentData['birthday'] ?? '';
                      final studentClass = studentData['class'] ?? '';
                      final studentFees = studentData['fees'] ?? '';
                      final studentFeesLeft = studentData['feesLeft'] ?? '';
                      final studentInstallments =
                          studentData['installments'] ?? '';
                      final studentInstallmentsLeft =
                          studentData['installmentsLeft'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          child: ExpansionTile(
                            title: Text('Name: $studentName'),
                            children: [
                              ListTile(
                                title: Text('Birthday: $studentBirthday'),
                              ),
                              ListTile(
                                title: Text('Class: $studentClass'),
                              ),
                              ListTile(
                                title: Text('Fees: $studentFees'),
                              ),
                              ListTile(
                                title: Text('Fees Left: $studentFeesLeft'),
                              ),
                              ListTile(
                                title:
                                    Text('Installments: $studentInstallments'),
                              ),
                              ListTile(
                                title: Text(
                                    'Installments Left: $studentInstallmentsLeft'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Add Student:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ExpansionTile(
                title: Text('Add New Student'),
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextFormField(
                    controller: birthdayController,
                    decoration: InputDecoration(labelText: 'Birthday'),
                    onTap: () => _selectDate(context), // Show date picker when tapped
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Classes').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }

                      final classes = snapshot.data!.docs;
                      List<DropdownMenuItem<String>> classDropdownItems = [];

                      for (var classDoc in classes) {
                        final classData = classDoc.data() as Map<String, dynamic>;
                        final className = classData['name'] ?? '';
                        final classId = classDoc.id;

                        classDropdownItems.add(
                          DropdownMenuItem<String>(
                            value: classId,
                            child: Text(className),
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Class'),
                        value: selectedClassId,
                        items: classDropdownItems,
                        onChanged: (value) {
                          setState(() {
                            selectedClassId = value;
                          });
                        },
                      );
                    },
                  ),
                  TextFormField(
                    controller: feesController,
                    decoration: InputDecoration(labelText: 'Fees'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: feesLeftController,
                    decoration: InputDecoration(labelText: 'Fees Left'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: installmentsController,
                    decoration: InputDecoration(labelText: 'Installments'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: installmentsLeftController,
                    decoration: InputDecoration(labelText: 'Installments Left'),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final newStudentDocRef = await FirebaseFirestore.instance.collection('Students').add({
                        'name': nameController.text,
                        'birthday': birthdayController.text,
                        'class': selectedClassId,
                        'fees': double.parse(feesController.text),
                        'feesLeft': double.parse(feesLeftController.text),
                        'installments': int.parse(installmentsController.text),
                        'installmentsLeft': int.parse(installmentsLeftController.text),
                      });

                      if (newStudentDocRef != null) {
                        setState(() {
                          nameController.clear();
                          birthdayController.clear();
                          classController.clear();
                          feesController.clear();
                          feesLeftController.clear();
                          installmentsController.clear();
                          installmentsLeftController.clear();
                          selectedClassId = null;
                        });
                      } else {
                        print('Error adding new student to Firestore.');
                      }
                    },
                    child: Text('Add Student'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
