import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_screen.dart';
import 'moderator_screen.dart';
import 'studentAttendance.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = ''; // تخزين رسالة الخطأ

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Set textDirection to right-to-left (rtl)
      child: Scaffold(
      appBar: AppBar(
        title: Text(
          'ستار كيدز', // عنوان مميز "ستار كيدز"
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                  'images/stark.png', // Replace with the path to your image asset
                  width: 150, // Adjust the width as needed
                  height: 150, // Adjust the height as needed
                ),
                SizedBox(height: 16), // Add some spacing
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم',
                  border: OutlineInputBorder(), // إضافة حدود
                ),
              ),
              SizedBox(height: 16), // إضافة مسافة
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(), // إضافة حدود
                ),
                obscureText: true,
              ),
              SizedBox(height: 32), // إضافة مزيد من المسافة
              ElevatedButton(
                onPressed: () async {
                  try {
                    // قم بالتحقق من الهوية باستخدام اسم المستخدم وكلمة المرور
                    final username = usernameController.text;
                    final password = passwordController.text;

                    // استعلام Firestore للعثور على المستخدم باستخدام اسم المستخدم المقدم
                    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                        .collection('Users')
                        .where('name', isEqualTo: username)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
                      final storedPassword = userData['password'] as String;

                      if (password == storedPassword) {
                        final userrole = userData['role'] as String;

                        if (userrole == 'admin') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => adminScreen()),
                          );
                        } else if (userrole == 'teacher') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentAttendanceScreen(user: null),
                            ),
                          );
                        } else if (userrole == 'moderator') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ModeratorScreen(),
                            ),
                          );
                        }
                      } else {
                        showErrorSnackBar('كلمة المرور غير صحيحة');
                        // التعامل مع كلمة المرور غير الصحيحة
                      }
                    } else {
                      showErrorSnackBar('المستخدم غير موجود');
                      // التعامل مع عدم وجود المستخدم
                    }
                  } catch (e) {
                    showErrorSnackBar('حدث خطأ أثناء تسجيل الدخول: $e');
                    // التعامل مع أخطاء المصادقة هنا
                  }
                },
                child: Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
