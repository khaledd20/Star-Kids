import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'Installments_Manage.dart';
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

  List<Map<String, String>> attendanceData = [];
  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 16.0);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تقرير الحضور'),
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
              title: Text('إدارة الدفعات'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => InstallmentsManageScreen(),
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
                    if (attendanceData.isNotEmpty)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بيانات الحضور:',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (attendanceData.isNotEmpty) {
                                  await _printAttendanceReport(attendanceData);
                                }
                              },
                              child: Text('طباعة التقرير'),
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
        attendanceData.clear();
      });
    }
  }

  Future<List<String>> fetchStudents(String selectedClass) async {
    try {
      final DocumentSnapshot classSnapshot =
          await _firestore.collection('Classes').doc(selectedClass).get();

      if (classSnapshot.exists) {
        final students = classSnapshot['students'] as List<dynamic>;
        return students.cast<String>();
      } else {
        return [];
      }
    } catch (e) {
      print('خطأ أثناء جلب الطلاب: $e');
      return [];
    }
  }

  void _loadAttendanceData(DateTime date, String selectedClass) async {
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

            final students = await fetchStudents(selectedClass);

            Map<String, String> studentAttendance = {};

            for (var student in students) {
              studentAttendance[student] = 'غائب';
            }

            for (var item in attendanceDataList) {
              final studentName = item['studentName'] as String;
              final status = item['status'] as String;
              studentAttendance[studentName] = status;
            }

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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('لا توجد بيانات حضور متاحة للصف المحدد في هذا التاريخ.'),
              ),
            );
          }
        } else {
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

  Future<void> _printAttendanceReport(List<Map<String, String>> attendanceData) async {
  final pdf = pw.Document();

  final arabic = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoKufiArabic-Regular.ttf'));
  
  final image = pw.MemoryImage(Uint8List.fromList((await rootBundle.load('images/stark.png')).buffer.asUint8List()));


  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (pw.Context context) {
        return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end, // Align content to the right

            children: [
         pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
             pw.Container(
                alignment: pw.Alignment.bottomLeft, // Align the image to the top-left
                child: pw.Image(image, width: 150, height: 150),
                  ),
              pw.SizedBox(height: 20),
            pw.Text(
                    'بيانات الحضور:',
              style: pw.TextStyle(fontSize: 20, font: arabic, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            for (var studentData in attendanceData)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'الطالب: ${studentData['studentName']}',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'الحالة: ${studentData['status']}',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),
                ],
              ),
            ],
          );
        },
      ),
    );

  await Printing.layoutPdf(onLayout: (_) async => pdf.save());
}
}
