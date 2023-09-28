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

  List<Map<String, String>> attendanceData = []; // قائمة لتخزين بيانات الحضور
  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 16.0);

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl, // Set textDirection to right-to-left (rtl)
      child: Scaffold(
      appBar: AppBar(
        title: Text('تقرير الحضور'),
        //  // المحاذاة إلى اليمين
      ),
      drawer: Drawer(
        child: ListView(
          padding: padding,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 183, 189, 0),
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
              title: Text('شاشة إدارة المستخدمين'),
              onTap: () {
                // انتقل إلى شاشة إدارة المستخدمين
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => userManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('شاشة إدارة الطلاب'),
              onTap: () {
                // انتقل إلى شاشة إدارة الطلاب
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StudentManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('تقرير المالية'),
              onTap: () {
                // انتقل إلى شاشة تقرير المالية
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FinanceReportScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('تقرير الحضور'),
              onTap: () {
                // انتقل إلى شاشة تقرير الحضور
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AttendanceReportScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('الطلاب المؤرشفين'),
              onTap: () {
                // انتقل إلى شاشة الطلاب المؤرشفين
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ArchivedStudentsScreen(),
                  ),
                );
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
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'اختر التاريخ:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(selectedDate != null
                  ? "${selectedDate!.toLocal()}".split(' ')[0]
                  : 'اختر تاريخًا'),
            ),
            SizedBox(height: 20),
            Text(
              'اختر الصف:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                // المحاذاة إلى اليمين
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
              child: Text('تحميل بيانات الحضور'),
            ),
            SizedBox(height: 20),
            // عرض بيانات الحضور هنا
            if (attendanceData.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بيانات الحضور:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: attendanceData.length,
                        itemBuilder: (context, index) {
                          final studentData = attendanceData[index];
                          return ListTile(
                            title: Text('الطالب: ${studentData["studentName"]}'),
                            subtitle: Text('الحالة: ${studentData["status"]}'),
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
    ],
  ),
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
        attendanceData.clear(); // مسح بيانات الحضور الحالية
      });
    }
  }

  Future<List<String>> fetchStudents(String selectedClass) async {
    try {
      final DocumentSnapshot classSnapshot =
          await _firestore.collection('Classes').doc(selectedClass).get();

      if (classSnapshot.exists) {
        final students = classSnapshot['students'] as List<dynamic>;
        return students.cast<String>(); // تحويلها إلى List<String>
      } else {
        // التعامل مع حالة عدم وجود وثيقة الصف.
        return [];
      }
    } catch (e) {
      print('خطأ أثناء جلب الطلاب: $e');
      return [];
    }
  }

  void _loadAttendanceData(DateTime date, String selectedClass) async {
    // استعلام Firestore لجلب بيانات الحضور
    final formattedDate = '${date.year}-${date.month}-${date.day}';
    final query = _firestore.collection('Attendance').doc(formattedDate);

    try {
      query.get().then((DocumentSnapshot documentSnapshot) async {
        if (documentSnapshot.exists) {
          final attendanceDataMap = documentSnapshot.data() as Map<String, dynamic>;

          if (attendanceDataMap != null &&
              attendanceDataMap.containsKey(selectedClass)) {
            final attendanceDataList =
                attendanceDataMap[selectedClass]['attendanceData'] as List<dynamic>;

            // جلب الطلاب من مجموعة "الصفوف"
            final students = await fetchStudents(selectedClass);

            // إنشاء خريطة لتتبع حالة حضور الطلاب
            Map<String, String> studentAttendance = {};

            // تهيئة جميع الطلاب كغائبين
            for (var student in students) {
              studentAttendance[student] = 'غائب';
            }

            // وضع علامات للطلاب كحاضرين
            for (var item in attendanceDataList) {
              final studentName = item['studentName'] as String;
              final status = item['status'] as String;
              studentAttendance[studentName] = status;
            }

            // تحويل الخريطة إلى قائمة للعرض
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
            // التعامل مع حالة عدم وجود بيانات الصف المحدد في التاريخ المحدد.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('لا توجد بيانات حضور متاحة للصف المحدد في هذا التاريخ.'),
              ),
            );
          }
        } else {
          // التعامل مع حالة عدم وجود وثيقة للتاريخ المحدد.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('لا توجد بيانات حضور متاحة لهذا التاريخ. الوثيقة غير موجودة.'),
            ),
          );
        }
      }).catchError((error) {
        print('خطأ أثناء جلب بيانات الحضور: $error');
      });
    } catch (e) {
      print('خطأ أثناء جلب الطلاب: $e');
    }
  }
}
