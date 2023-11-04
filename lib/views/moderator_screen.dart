import 'package:flutter/material.dart';
import 'Installments.dart';
import 'login_screen.dart';
import 'studentAdd.dart';
import 'studentAttendance.dart'; // استيراد الحضور الطلابي
import 'studentManagement.dart'; // استيراد شاشة إدارة الطلاب

class ModeratorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص إلى اليمين-إلى-اليسار (rtl)
      child: Scaffold(
        appBar: AppBar(
          title: Text('صفحة المشرف'),
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
                leading: Icon(Icons.navigate_next),
                title: Text('الحضور'),
                onTap: () {
                  // إغلاق القائمة والانتقال إلى شاشة الحضور الطلابي
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
                  // إغلاق القائمة والانتقال إلى شاشة إضافة الطلاب
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StudentAddingScreen(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.payment_sharp), // أيقونة المالية
                title: Text('الأقساط'), // نص المالية
                onTap: () {
                  // إغلاق القائمة والانتقال إلى شاشة إدارة الأقساط
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
      ),
    );
  }
}
