import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Installments_Manage.dart';
import 'archievedStudents.dart';
import 'attendanceReport.dart';
import 'financeReport.dart';
import 'login_screen.dart';
import 'statistics.dart';
import 'studentManagement.dart';

class userManagementScreen extends StatefulWidget {
  @override
  _userManagementScreenState createState() => _userManagementScreenState();
}

class _userManagementScreenState extends State<userManagementScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userroleController = TextEditingController();

  // تتبع معرف المستخدم الذي يتم تحريره حاليًا
  String? currentlyEditingUserId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص إلى اليمين-اليسار (rtl)
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة المستخدمين'),
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'مرحبًا بك في صفحة إدارة المستخدمين',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                Text(
                  'المستخدمون:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('Users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    final users = snapshot.data!.docs;
                    List<Widget> userWidgets = [];

                    for (var user in users) {
                      final userData = user.data() as Map<String, dynamic>;
                      final userId = user.id;
                      final username = userData['name'] ?? ''; // تحديث إلى 'name'
                      final password = userData['password'] ?? '';
                      final userrole = userData['role'] ?? '';

                      userWidgets.add(
                        ListTile(
                          title: Text('معرف المستخدم: $userId'), // عرض معرف المستخدم
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الاسم: $username'), // تحديث إلى 'الاسم'
                              Text('كلمة المرور: $password'),
                              Text('الدور: $userrole'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // قم بتعيين معرف المستخدم الذي يتم تحريره حاليًا
                                  setState(() {
                                    currentlyEditingUserId = userId;
                                  });

                                  // قم بملء النموذج التحريري ببيانات المستخدم
                                  nameController.text = username;
                                  passwordController.text = password;
                                  userroleController.text = userrole;
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete,  color: Colors.red),
                                onPressed: () {
                                  // حذف المستخدم من Firestore
                                  FirebaseFirestore.instance.collection('Users').doc(userId).delete();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView(
                      shrinkWrap: true, // السماح لقائمة العرض باتخاذ حجم الحد الأدنى
                      physics: NeverScrollableScrollPhysics(), // تعطيل التمرير في قائمة العرض
                      children: userWidgets,
                    );
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'تحرير المستخدم:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'الاسم'), // تحديث إلى 'الاسم'
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'كلمة المرور'),
                ),
                TextFormField(
                  controller: userroleController,
                  decoration: InputDecoration(labelText: 'الدور'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // تحديث بيانات المستخدم في Firestore
                    FirebaseFirestore.instance.collection('Users').doc(currentlyEditingUserId).update({
                      'name': nameController.text, // تحديث إلى 'name'
                      'password': passwordController.text,
                      'role': userroleController.text,
                    });

                    // مسح حقول الإدخال وإعادة تعيين حالة التحرير
                    setState(() {
                      currentlyEditingUserId = null;
                      nameController.clear();
                      passwordController.clear();
                      userroleController.clear();
                    });
                  },
                  child: Text('حفظ التغييرات'),
                ),
                SizedBox(height: 20),
                Text(
                  'إضافة مستخدم:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'الاسم'), // تحديث إلى 'الاسم'
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'كلمة المرور'),
                ),
                TextFormField(
                  controller: userroleController,
                  decoration: InputDecoration(labelText: 'الدور'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // إضافة مستخدم جديد إلى Firestore مع معرف تم إنشاؤه تلقائيًا
                    await FirebaseFirestore.instance.collection('Users').add({
                      'name': nameController.text,
                      'password': passwordController.text,
                      'role': userroleController.text,
                    });

                    // مسح حقول الإدخال
                    nameController.clear();
                    passwordController.clear();
                    userroleController.clear();
                  },
                  child: Text('إضافة مستخدم'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
