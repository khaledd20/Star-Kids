import 'package:flutter/material.dart';
import 'package:my_flutter_project/views/Installments.dart';
import 'login_screen.dart';
import 'studentAdd.dart';
import 'studentAttendance.dart'; // Import the studentAttendance
import 'studentManagement.dart'; // Import the StudentManagementScreen

class ModeratorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moderator Page'),
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
                'Moderator Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.navigate_next),
              title: Text('Attendance'),
              onTap: () {
                // Close the drawer and navigate to the studentAttendance
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StudentAttendanceScreen(user: null),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts), // Icon for Student Management
              title: Text('Student Add'), // Text for Student Management
              onTap: () {
                // Close the drawer and navigate to the StudentAddingScreen
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => StudentAddingScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.payment_sharp), // Icon for Student Management
              title: Text('Finance'), // Text for Student Management
              onTap: () {
                // Close the drawer and navigate to the StudentManagementScreen
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => InstallmentsScreen(),
                ));
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
    );
  }
}
