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

  String errorMessage = '';

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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ستار كيدز',
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
                Expanded(
                  child: Image.asset(
                    'images/stark.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المستخدم',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final username = usernameController.text;
                      final password = passwordController.text;

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
                          }  else if (userrole == 'moderator') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModeratorScreen(),
                              ),
                            );
                          }
                        } else {
                          showErrorSnackBar('كلمة المرور غير صحيحة');
                        }
                      } else {
                        showErrorSnackBar('المستخدم غير موجود');
                      }
                    } catch (e) {
                      showErrorSnackBar('حدث خطأ أثناء تسجيل الدخول: $e');
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
