import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'archievedStudents.dart';
import 'financeReport.dart';
import 'login_screen.dart';
import 'studentManagement.dart';
import 'userManagement.dart';

class AttendanceReportScreen extends StatefulWidget {
  @override
  _AttendanceReportScreenState createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? selectedDate;
  String? selectedClass;

  List<Map<String, String>> attendanceData = []; // List to store attendance data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Report'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select Date:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(selectedDate != null
                  ? "${selectedDate!.toLocal()}".split(' ')[0]
                  : 'Select a Date'),
            ),
            SizedBox(height: 20),
            Text(
              'Select Class:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedClass,
              onChanged: (newValue) {
                setState(() {
                  selectedClass = newValue;
                });
              },
              items: <String>['kg1', 'kg2', 'pre-kg']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedDate != null && selectedClass != null) {
                  _loadAttendanceData(selectedDate!, selectedClass!);
                }
              },
              child: Text('Load Attendance Data'),
            ),
            SizedBox(height: 20),
            // Display attendance data here
            if (attendanceData.isNotEmpty)
              Expanded( // Wrap your ListView.builder with Expanded
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Data:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Expanded( // Wrap your ListView.builder with Expanded
                      child: ListView.builder(
                        itemCount: attendanceData.length,
                        itemBuilder: (context, index) {
                          final studentData = attendanceData[index];
                          return ListTile(
                            title: Text('Student: ${studentData["studentName"]}'),
                            subtitle: Text('Status: ${studentData["status"]}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        attendanceData.clear(); // Clear existing attendance data
      });
    }
  }
  Future<List<String>> fetchStudents(String selectedClass) async {
  try {
    final DocumentSnapshot classSnapshot = await _firestore.collection('Classes').doc(selectedClass).get();

    if (classSnapshot.exists) {
      final students = classSnapshot['students'] as List<dynamic>;
      return students.cast<String>(); // Convert to List<String>
    } else {
      // Handle the case when the class document does not exist.
      return [];
    }
  } catch (e) {
    print('Error fetching students: $e');
    return [];
  }
}

  void _loadAttendanceData(DateTime date, String selectedClass) async {
  // Firestore query to fetch attendance data
  final formattedDate = '${date.year}-${date.month}-${date.day}';
  final query = _firestore.collection('Attendance').doc(formattedDate);

  try {
    query.get().then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        final attendanceDataMap = documentSnapshot.data() as Map<String, dynamic>;

        if (attendanceDataMap != null && attendanceDataMap.containsKey(selectedClass)) {
          final attendanceDataList = attendanceDataMap[selectedClass]['attendanceData'] as List<dynamic>;

          // Fetch students from the "Classes" collection
          final students = await fetchStudents(selectedClass);

          // Create a map to track student attendance status
          Map<String, String> studentAttendance = {};

          // Initialize all students as absent
          for (var student in students) {
            studentAttendance[student] = 'absent';
          }

          // Mark students as attended
          for (var item in attendanceDataList) {
            final studentName = item['studentName'] as String;
            final status = item['status'] as String;
            studentAttendance[studentName] = status;
          }

          // Convert the map to a list for display
          List<Map<String, String>> data = [];
          studentAttendance.forEach((studentName, status) {
            data.add({
              'studentName': studentName,
              'status': status,
            });
          });

          setState(() {
            attendanceData = data;
          });
        } else {
          // Handle the case when the selected class does not exist for the given date.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No attendance data available for the selected class on this date.'),
            ),
          );
        }
      } else {
        // Handle the case when the document for the selected date does not exist.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No attendance data available for the selected date. Document does not exist.'),
          ),
        );
      }
    }).catchError((error) {
      print('Error fetching attendance data: $error');
    });
  } catch (e) {
    print('Error fetching students: $e');
  }
}


}
