import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'archievedStudents.dart';
import 'financeReport.dart';
import 'login_screen.dart';
import 'studentManagement.dart';

class userManagementScreen extends StatefulWidget {
  @override
  _userManagementScreenState createState() => _userManagementScreenState();
}

class _userManagementScreenState extends State<userManagementScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userroleController = TextEditingController();

  // Track the currently edited user document ID
  String? currentlyEditingUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Managemnet'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome to User Managemnet page',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                'Users:',
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
                    final username = userData['name'] ?? ''; // Updated to 'name'
                    final password = userData['password'] ?? '';
                    final userrole = userData['role'] ?? '';

                    userWidgets.add(
                      ListTile(
                        title: Text('User ID: $userId'), // Display User ID
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: $username'), // Updated to 'Name'
                            Text('Password: $password'),
                            Text('role: $userrole'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Set the currently editing user ID
                                setState(() {
                                  currentlyEditingUserId = userId;
                                });

                                // Pre-fill the edit form with user data
                                nameController.text = username;
                                passwordController.text = password;
                                userroleController.text = userrole;
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Delete user from Firestore
                                FirebaseFirestore.instance.collection('Users').doc(userId).delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView(
                    shrinkWrap: true, // Allow the ListView to take minimum space
                    physics: NeverScrollableScrollPhysics(), // Disable scrolling of ListView
                    children: userWidgets,
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Edit User:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'), // Updated to 'Name'
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              TextFormField(
                controller: userroleController,
                decoration: InputDecoration(labelText: 'User role'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Update user data in Firestore
                  FirebaseFirestore.instance.collection('Users').doc(currentlyEditingUserId).update({
                    'name': nameController.text, // Updated to 'name'
                    'password': passwordController.text,
                    'role': userroleController.text,
                  });

                  // Clear the input fields and reset the editing state
                  setState(() {
                    currentlyEditingUserId = null;
                    nameController.clear();
                    passwordController.clear();
                    userroleController.clear();
                  });
                },
                child: Text('Save Changes'),
              ),
              SizedBox(height: 20),
              Text(
                'Add User:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'), // Updated to 'Name'
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              TextFormField(
                controller: userroleController,
                decoration: InputDecoration(labelText: 'User role'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Add new user to Firestore with an automatically generated ID
                  await FirebaseFirestore.instance.collection('Users').add({
                    'name': nameController.text,
                    'password': passwordController.text,
                    'role': userroleController.text,
                  });

                  // Clear the input fields
                  nameController.clear();
                  passwordController.clear();
                  userroleController.clear();
                },
                child: Text('Add User'),
              ),

            ],
          ),
        ),
      ),
    );
  }
  
}



