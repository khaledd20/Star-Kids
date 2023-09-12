import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'archievedStudents.dart';
import 'attendanceReport.dart';
import 'login_screen.dart';
import 'studentManagement.dart';
import 'userManagement.dart';

class FinanceReportScreen extends StatefulWidget {
  @override
  _FinanceReportScreenState createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? fromDate;
  DateTime? toDate;
  String studentNameFilter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Report'),
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
              title: Text('Attendance report'),
              onTap: () {
                // Navigate to the ModeratorScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AttendanceReportScreen(),
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
      body: Column(
        children: [
          _buildDateFilterRow(),
          _buildStudentNameFilterRow(),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    fromDate = null;
                    toDate = null;
                  });
                },
                child: Text('Reset Date Filters'),
              ),
              SizedBox(width: 20),
              
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Finance').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final installments = snapshot.data!.docs;

                if (installments.isEmpty) {
                  return Center(child: Text('No installments available.'));
                }

                final filteredInstallments = _filterInstallments(installments);

                if (filteredInstallments.isEmpty) {
                  return Center(child: Text('No installments within the selected date range.'));
                }

                return ListView.builder(
                  itemCount: filteredInstallments.length,
                  itemBuilder: (context, index) {
                    final installmentData = filteredInstallments[index].data() as Map<String, dynamic>;
                    final selectedClass = installmentData['class'] ?? '';
                    final studentName = installmentData['studentName'] ?? '';
                    final amount = installmentData['amount'] ?? 0.0;
                    final date = installmentData['date'] ?? '';
                    final receiptNumber = installmentData['receiptNumber'] ?? '';

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Class: $selectedClass'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Student Name: $studentName'),
                            Text('Amount: $amount'),
                            Text('Date: $date'),
                            Text('Receipt Number: $receiptNumber'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterRow() {
    return Row(
      children: [
        Text('From: '),
        TextButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: fromDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (selectedDate != null) {
              setState(() {
                fromDate = selectedDate;
              });
            }
          },
          child: Text(fromDate != null ? fromDate!.toString().split(' ')[0] : 'Select Date'),
        ),
        SizedBox(width: 20),
        Text('To: '),
        TextButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: toDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (selectedDate != null) {
              setState(() {
                toDate = selectedDate;
              });
            }
          },
          child: Text(toDate != null ? toDate!.toString().split(' ')[0] : 'Select Date'),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  Widget _buildStudentNameFilterRow() {
    return Row(
      children: [
        Text('Student Name: '),
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                studentNameFilter = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Enter student name',
            ),
          ),
        ),
      ],
    );
  }

  List<QueryDocumentSnapshot> _filterInstallments(List<QueryDocumentSnapshot> installments) {
    final fromDateCondition = fromDate ?? DateTime(2000);
    final toDateCondition = toDate ?? DateTime(2101);

    return installments.where((installment) {
      final installmentData = installment.data() as Map<String, dynamic>;

      if (!installmentData.containsKey('date') || !(installmentData['date'] is String)) {
        return false;
      }

      final dateStr = installmentData['date'] as String;
      final installmentDate = DateTime.parse(dateStr);

      final dateCondition =
          installmentDate.isAfter(fromDateCondition) && installmentDate.isBefore(toDateCondition);

      final studentNameCondition = studentNameFilter.isEmpty ||
          (installmentData['studentName'] as String).toLowerCase().contains(studentNameFilter.toLowerCase());

      return dateCondition && studentNameCondition;
    }).toList();
  }
}

void main() {
  runApp(MaterialApp(
    home: FinanceReportScreen(),
  ));
}
