import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_screen.dart';
import 'normal_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
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
                      final userType = userData['type'] as String;

                      if (userType == 'admin') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AdminScreen()),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NormalScreen(user: null),
                          ),
                        );
                      }
                    } else {
                      print('Invalid password');
                      // Handle incorrect password
                    }
                  } else {
                    print('User not found');
                    // Handle user not found
                  }
                } catch (e) {
                  print('Error during login: $e');
                  // Handle authentication errors here
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
