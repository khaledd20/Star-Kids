import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NormalScreen extends StatelessWidget {
  final User? user;

  NormalScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Normal Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to the Normal Screen!'),
            user != null
                ? Text('User: ${user!.displayName}')
                : Text('User information not available'), // Display user information or a message if user is null
          ],
        ),
      ),
    );
  }
}
