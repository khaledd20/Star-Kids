import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendanceReport.dart';
import 'financeReport.dart';
import 'login_screen.dart';
import 'studentManagement.dart';
import 'userManagement.dart';

class ArchivedStudentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return Directionality(
      textDirection: TextDirection.rtl, // Set textDirection to right-to-left (rtl)
      child: Scaffold(
      appBar: AppBar(
        title: Text('الطلاب المؤرشفين'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Archived').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final archivedStudents = snapshot.data!.docs;

          if (archivedStudents.isEmpty) {
            return Center(child: Text('لا يوجد طلاب مؤرشفين.'));
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
                    title: Text('الاسم: $studentName'),
                    children: [
                      ListTile(
                        title: Text('تاريخ الميلاد: $studentBirthday'),
                      ),
                      ListTile(
                        title: Text('الصف: $studentClass'),
                      ),
                      ListTile(
                        title: Text('الرسوم: $studentFees'),
                      ),
                      ListTile(
                        title: Text('الرسوم المتبقية: $studentFeesLeft'),
                      ),
                      ListTile(
                        title: Text('الأقساط: $studentInstallments'),
                      ),
                      ListTile(
                        title: Text('الأقساط المتبقية: $studentInstallmentsLeft'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await unarchiveStudent(studentId, studentData);
                            },
                            child: Text('إلغاء الأرشفة'), // زر لإلغاء الأرشفة
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
      ),
    );
  }

  Future<void> unarchiveStudent(String studentId, Map<String, dynamic> studentData) async {
    try {
      // إنشاء مرجع إلى مجموعة "الطلاب"
      final studentsCollection = FirebaseFirestore.instance.collection('Students');

      // أضف بيانات الطالب إلى مجموعة "الطلاب"
      await studentsCollection.doc(studentId).set(studentData);

      // احذف الطالب من مجموعة "Archived"
      await FirebaseFirestore.instance.collection('Archived').doc(studentId).delete();
    } catch (e) {
      print('حدث خطأ أثناء إلغاء الأرشفة: $e');
    }
  }
}
