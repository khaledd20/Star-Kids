import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'archievedStudents.dart';
import 'financeReport.dart';
import 'login_screen.dart';
import 'studentManagement.dart';
import 'userManagement.dart';
class adminScreen extends StatefulWidget {
  @override
  _adminScreenState createState() => _adminScreenState();
}

class _adminScreenState extends State<adminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
        
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('User Managemnet Screen'),
              onTap: () {
                // Navigate to the ModeratorScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => userManagementScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('Student Management Screen'),
              onTap: () {
                // Navigate to the ModeratorScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StudentManagementScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('Finance report'),
              onTap: () {
                // Navigate to the ModeratorScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FinanceReportScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('Archived Students'),
              onTap: () {
                // Navigate to the ModeratorScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ArchivedStudentsScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('Log Out'),
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
        child: Text('Admin Screen Content'),
      ),
    );
  }
}
