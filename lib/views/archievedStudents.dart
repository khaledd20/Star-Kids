import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'financeReport.dart';
import 'login_screen.dart';
import 'studentManagement.dart';
import 'userManagement.dart';

class ArchivedStudentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archived Students'),
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
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('User Managemnet Screen'),
              onTap: () {
                // Navigate to the ModeratorScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => userManagementScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('Student Management Screen'),
              onTap: () {
                // Navigate to the ModeratorScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StudentManagementScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('Finance report'),
              onTap: () {
                // Navigate to the ModeratorScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FinanceReportScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('Archived Students'),
              onTap: () {
                // Navigate to the ModeratorScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ArchivedStudentsScreen(),
                    ),
                  );
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Archived').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final archivedStudents = snapshot.data!.docs;

          if (archivedStudents.isEmpty) {
            return Center(child: Text('No archived students.'));
          }

          return ListView.builder(
            itemCount: archivedStudents.length,
            itemBuilder: (context, index) {
              final studentData = archivedStudents[index].data() as Map<String, dynamic>;
              final studentId = archivedStudents[index].id;
              final studentName = studentData['name'] ?? '';
              final studentBirthday = studentData['birthday'] ?? '';
              final studentClass = studentData['class'] ?? '';
              final studentFees = studentData['fees'] ?? '';
              final studentFeesLeft = studentData['feesLeft'] ?? '';
              final studentInstallments = studentData['installments'] ?? '';
              final studentInstallmentsLeft = studentData['installmentsLeft'] ?? '';

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
                        title: Text('Installments: $studentInstallments'),
                      ),
                      ListTile(
                        title: Text('Installments Left: $studentInstallmentsLeft'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await unarchiveStudent(studentId, studentData);
                            },
                            child: Text('Unarchive'), // Button to unarchive the student
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> unarchiveStudent(String studentId, Map<String, dynamic> studentData) async {
    try {
      // Create a reference to the "Students" collection
      final studentsCollection = FirebaseFirestore.instance.collection('Students');

      // Add the student data to the "Students" collection
      await studentsCollection.doc(studentId).set(studentData);

      // Delete the student from the "Archived" collection
      await FirebaseFirestore.instance.collection('Archived').doc(studentId).delete();
    } catch (e) {
      print('Error unarchiving student: $e');
    }
  }
}
