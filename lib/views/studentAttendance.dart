import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final User? user;

  StudentAttendanceScreen({required this.user});

  @override
  _StudentAttendanceScreenState createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final List<String> attendedStudents = [];
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  Widget build(BuildContext context) {
    final displayName = widget.user?.displayName ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Screen'),
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
                      child: Text("Scan a QR code"),
                    ),
                  ),
                ],
              ),
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
                    title: Text(attendedStudents[index] ?? ''),
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

      if (scannedData != null) {
        final studentName = await getStudentNameFromFirestore(scannedData);
        if (studentName != null) {
          setState(() {
            attendedStudents.add(studentName);
          });
          final studentClass = await getStudentClassFromFirestore(scannedData);
          if (studentClass != null) {
            await updateAttendanceRecord(studentClass, studentName);
          }
        }
      }
    });
  }

  Future<String?> getStudentNameFromFirestore(String studentId) async {
    try {
      final studentDoc = await FirebaseFirestore.instance.collection('Students').doc(studentId).get();
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
      final studentDoc = await FirebaseFirestore.instance.collection('Students').doc(studentId).get();
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

  Future<void> updateAttendanceRecord(String studentClass, String studentName) async {
    final currentDate = DateTime.now();
    final formattedDate = '${currentDate.year}-${currentDate.month}-${currentDate.day}';

    final attendanceDocRef = FirebaseFirestore.instance.collection('Attendance').doc(studentClass);

    final existingData = await attendanceDocRef.get();

    if (existingData.exists) {
      final updatedData = existingData.data() as Map<String, dynamic>;
      final attendanceList = updatedData[formattedDate] as List<dynamic>? ?? [];
      attendanceList.add(studentName);

      await attendanceDocRef.update({
        formattedDate: attendanceList,
      });
    } else {
      await attendanceDocRef.set({
        formattedDate: [studentName],
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
