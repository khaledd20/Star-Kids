import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Installments_Manage.dart';
import 'archievedStudents.dart';
import 'attendanceReport.dart';
import 'financeReport.dart';
import 'login_screen.dart';
import 'studentManagement.dart';
import 'userManagement.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int totalStudents = 0;
  Map<String, int> studentsInClasses = {};

  // Function to fetch the total number of students and students in each class
  void fetchStudentData() async {
    try {
      // Fetch total number of students
      QuerySnapshot totalSnapshot =
          await FirebaseFirestore.instance.collection('Students').get();
      int total = totalSnapshot.size;

      // Fetch number of students in specific classes
      QuerySnapshot classSnapshot =
          await FirebaseFirestore.instance.collection('Students')
              .where('class', whereIn: ['kg1', 'kg2', 'pre-kg']).get();

      Map<String, int> classCounts = {};

      classSnapshot.docs.forEach((doc) {
        String className = doc['class'];
        classCounts[className] = (classCounts[className] ?? 0) + 1;
      });

      setState(() {
        totalStudents = total;
        studentsInClasses = classCounts;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Statistics'),
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
              title: Text('احصائيات الطلاب'),
              onTap: () {
                // انتقل إلى شاشة إدارة الطلاب
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(),
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
              title: Text('تقرير مالي'),
              onTap: () {
                // انتقل إلى شاشة التقرير المالي
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'إجمالي عدد الطلاب: $totalStudents',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 20),
              Text(
                'عدد الطلاب في كل فصل:',
                style: TextStyle(fontSize: 24),
              ),
               /*ElevatedButton(
                onPressed: updateClassStudents,
                child: Text('Update Class Students'),
               )*/
              SizedBox(height: 10),
              Column(
                children: [
                  Text(
                    'KG1: ${studentsInClasses['kg1'] ?? 0} ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'KG2: ${studentsInClasses['kg2'] ?? 0} ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Pre-KG: ${studentsInClasses['pre-kg'] ?? 0} ',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /*void updateClassStudents() async {
  try {
    // Fetch all students
    QuerySnapshot studentsSnapshot =
        await FirebaseFirestore.instance.collection('Students').get();

    // Organize students by class
    Map<String, List<String>> studentsByClass = {};
    for (var doc in studentsSnapshot.docs) {
      String className = doc['class'];
      String studentName = doc['name'];
      studentsByClass.putIfAbsent(className, () => []).add(studentName);
    }

    // Update each class document in the Classes collection
    studentsByClass.forEach((className, studentNames) async {
      await FirebaseFirestore.instance.collection('Classes').doc(className).update({
        'students': studentNames,
      });
    });
  } catch (e) {
    print('Error updating class students: $e');
  }
}
*/
}
