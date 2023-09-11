import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Installments.dart';
import 'login_screen.dart';
import 'studentAdd.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final User? user;

  StudentAttendanceScreen({required this.user});

  @override
  _StudentAttendanceScreenState createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  String selectedClass = "kg1"; // Default class selection
  String scanResultMessage = ''; // Message to show after scanning
  bool isScanningEnabled = true; // Control flag for scanning frequency
  Set<String> attendedStudents = {}; // Use a Set to store attended student names

  @override
  Widget build(BuildContext context) {
    final displayName = widget.user?.displayName ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Screen'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to the Attendance Screen!'),
            Text('User: $displayName'),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 300,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(scanResultMessage),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Choose Class:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedClass,
              onChanged: (newValue) {
                setState(() {
                  selectedClass = newValue!;
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
            Text(
              'Attended Students:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: attendedStudents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(attendedStudents.elementAt(index) ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      final scannedData = scanData.code;

      if (isScanningEnabled && scannedData != null) {
        isScanningEnabled = false; // Disable scanning temporarily

        final studentName = await getStudentNameFromFirestore(scannedData);
        if (studentName != null) {
          final studentClass = await getStudentClassFromFirestore(scannedData);
          if (studentClass != null) {
            if (studentClass == selectedClass) {
              if (!await isStudentAlreadyMarked(studentName)) {
                attendedStudents.add(studentName); // Update the attended students list
                await markAttendance(selectedClass, studentName);
                setState(() {
                  scanResultMessage = "Scanned Successfully";
                });
              } else {
                setState(() {
                  scanResultMessage = "Already Scanned";
                });
              }
            } else {
              setState(() {
                scanResultMessage = "Wrong Class";
              });
            }
          }
        }

        // Enable scanning after a delay of 2 seconds
        Future.delayed(Duration(seconds: 2), () {
          isScanningEnabled = true;
        });
      }
    });
  }

  Future<String?> getStudentNameFromFirestore(String studentId) async {
    try {
      final studentDoc =
          await FirebaseFirestore.instance.collection('Students').doc(studentId).get();
      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        final studentName = studentData['name'] as String?;
        return studentName;
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
    return null;
  }

  Future<String?> getStudentClassFromFirestore(String studentId) async {
    try {
      final studentDoc =
          await FirebaseFirestore.instance.collection('Students').doc(studentId).get();
      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        final studentClass = studentData['class'] as String?;
        return studentClass;
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
    return null;
  }

  Future<void> markAttendance(String selectedClass, String studentName) async {
    final currentDate = DateTime.now();
    final formattedDate = '${currentDate.year}-${currentDate.month}-${currentDate.day}';

    final attendanceDocRef =
        FirebaseFirestore.instance.collection('Attendance').doc(formattedDate);

    final existingData = await attendanceDocRef.get();

    final studentAttendanceData = {
      'studentName': studentName,
      'status': 'present',
    };

    if (existingData.exists) {
      final updatedData = existingData.data() as Map<String, dynamic>;

      // Ensure that the selected class subcollection exists
      if (!updatedData.containsKey(selectedClass)) {
        updatedData[selectedClass] = {
          'attendanceData': [studentAttendanceData],
        };
      } else {
        final classAttendanceData = updatedData[selectedClass]['attendanceData'] as List<dynamic>;
        classAttendanceData.add(studentAttendanceData);
      }

      await attendanceDocRef.update(updatedData);
    } else {
      // Create a new attendance record for the selected date
      final newAttendanceData = {
        selectedClass: {
          'attendanceData': [studentAttendanceData],
        },
      };

      await attendanceDocRef.set(newAttendanceData);
    }
  }

  Future<bool> isStudentAlreadyMarked(String studentName) async {
    final currentDate = DateTime.now();
    final formattedDate = '${currentDate.year}-${currentDate.month}-${currentDate.day}';

    final attendanceDocRef =
        FirebaseFirestore.instance.collection('Attendance').doc(formattedDate);

    final existingData = await attendanceDocRef.get();

    if (existingData.exists) {
      final updatedData = existingData.data() as Map<String, dynamic>;

      if (updatedData.containsKey(selectedClass)) {
        final classAttendanceData = updatedData[selectedClass]['attendanceData'] as List<dynamic>;

        // Check if the student name is already present in the attendance data
        return classAttendanceData.any((entry) => entry['studentName'] == studentName);
      }
    }

    return false;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
