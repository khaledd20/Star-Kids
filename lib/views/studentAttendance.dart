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

  String selectedClass = "kg1"; // تحديد الفصل الافتراضي
  String scanResultMessage = ''; // رسالة لعرضها بعد الفحص
  bool isScanningEnabled = true; // علم التحكم في تكرار الفحص
  Set<String> attendedStudents = {}; // استخدام مجموعة لتخزين أسماء الطلاب الحاضرين

  @override
  Widget build(BuildContext context) {
    final displayName = widget.user?.displayName ?? "المستخدم";

    return Directionality(
      textDirection: TextDirection.rtl, // تحديد اتجاه النص إلى اليمين (RTL)
      child: Scaffold(
        appBar: AppBar(
          title: Text('شاشة الحضور'),
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
                  'القائمة للمشرف',
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
                  // إغلاق القائمة والانتقال إلى شاشة حضور الطلاب
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StudentAttendanceScreen(user: null),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.manage_accounts), // أيقونة إدارة الطلاب
                title: Text('إضافة طالب'), // نص إدارة الطلاب
                onTap: () {
                  // إغلاق القائمة والانتقال إلى شاشة إضافة الطالب
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StudentAddingScreen(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.payment_sharp), // أيقونة الأمور المالية
                title: Text('الأمور المالية'), // نص الأمور المالية
                onTap: () {
                  // إغلاق القائمة والانتقال إلى شاشة إدارة الاقساط
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('مرحبًا بك في شاشة الحضور!'),
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
                'اختر الفصل:',
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
                'الطلاب الحاضرين:',
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
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      final scannedData = scanData.code;

      if (isScanningEnabled && scannedData != null) {
        isScanningEnabled = false; // تعطيل الفحص مؤقتًا

        final studentName = await getStudentNameFromFirestore(scannedData);
        if (studentName != null) {
          final studentClass = await getStudentClassFromFirestore(scannedData);
          if (studentClass != null) {
            if (studentClass == selectedClass) {
              if (!await isStudentAlreadyMarked(studentName)) {
                attendedStudents.add(studentName); // تحديث قائمة الطلاب الحاضرين
                await markAttendance(selectedClass, studentName);
                setState(() {
                  scanResultMessage = "تم الفحص بنجاح";
                });
              } else {
                setState(() {
                  scanResultMessage = "تم الفحص مسبقًا";
                });
              }
            } else {
              setState(() {
                scanResultMessage = "فصل خاطئ";
              });
            }
          }
        }

        // تمكين الفحص بعد تأخير 2 ثانية
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
      print('خطأ في جلب بيانات الطالب: $e');
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
      print('خطأ في جلب بيانات الطالب: $e');
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
      'status': 'حاضر',
    };

    if (existingData.exists) {
      final updatedData = existingData.data() as Map<String, dynamic>;

      // التأكد من وجود مجموعة الفصل المحددة
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
      // إنشاء سجل حضور جديد للتاريخ المحدد
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

        // التحقق مما إذا كان اسم الطالب موجودًا بالفعل في بيانات الحضور
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
