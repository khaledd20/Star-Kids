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

  String errorMessage = ''; // Store error message

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Star Kids', // Bold title "Star Kids"
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
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(), // Add border
                ),
              ),
              SizedBox(height: 16), // Add spacing
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(), // Add border
                ),
                obscureText: true,
              ),
              SizedBox(height: 32), // Add more spacing
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Authenticate the user with username and password
                    final username = usernameController.text;
                    final password = passwordController.text;

                    // Query Firestore to find the user with the provided username
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
                        showErrorSnackBar('Invalid password');
                        // Handle incorrect password
                      }
                    } else {
                      showErrorSnackBar('User not found');
                      // Handle user not found
                    }
                  } catch (e) {
                    showErrorSnackBar('Error during login: $e');
                    // Handle authentication errors here
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
