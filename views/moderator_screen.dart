import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'studentAttendance.dart'; // Import the studentAttendance

class ModeratorScreen extends StatefulWidget {
  @override
  _ModeratorScreenState createState() => _ModeratorScreenState();
}

class _ModeratorScreenState extends State<ModeratorScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  // Track the currently edited student document ID
  String? currentlyEditingStudentId;

  // Track the selected class document ID
  String? selectedClassId;

  // Track the old class document ID for each student
  String? oldClassId;

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
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.navigate_next),
              title: Text('Go to Normal Screen'),
              onTap: () {
                // Close the drawer and navigate to the studentAttendance
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => studentAttendance(user: null),
                ));
              },
            ),
            // Add more menu items as needed
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
                'Welcome to the Moderator Page!',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                'Students:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Students').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final students = snapshot.data!.docs;
                  List<Widget> studentWidgets = [];

                  for (var student in students) {
                    final studentData = student.data() as Map<String, dynamic>;
                    final studentId = student.id;
                    final studentName = studentData['name'] ?? '';
                    final studentBirthday = studentData['birthday'] ?? '';
                    final studentClass = studentData['class'] ?? '';

                    studentWidgets.add(
                      ListTile(
                        title: Text('Name: $studentName'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Birthday: $studentBirthday'),
                            Text('Class: $studentClass'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Set the currently editing student ID
                                setState(() {
                                  currentlyEditingStudentId = studentId;
                                  oldClassId = studentClass; // Track the old class
                                });

                                // Pre-fill the edit form with student data
                                nameController.text = studentName;
                                birthdayController.text = studentBirthday;
                                classController.text = studentClass;
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Delete student from Firestore
                                FirebaseFirestore.instance.collection('Students').doc(studentId).delete();
                                // Remove the student's name from the old class
                                if (oldClassId != null) {
                                  FirebaseFirestore.instance.collection('Classes').doc(oldClassId).update({
                                    'students': FieldValue.arrayRemove([studentName]),
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: studentWidgets,
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Edit Student:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: birthdayController,
                decoration: InputDecoration(labelText: 'Birthday'),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Classes').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final classes = snapshot.data!.docs;
                  List<DropdownMenuItem<String>> classDropdownItems = [];

                  for (var classDoc in classes) {
                    final classData = classDoc.data() as Map<String, dynamic>;
                    final className = classData['name'] ?? '';
                    final classId = classDoc.id;

                    classDropdownItems.add(
                      DropdownMenuItem<String>(
                        value: classId,
                        child: Text(className),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Class'),
                    value: selectedClassId,
                    items: classDropdownItems,
                    onChanged: (value) {
                      setState(() {
                        selectedClassId = value;
                      });
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  // Update student data in Firestore
                  FirebaseFirestore.instance.collection('Students').doc(currentlyEditingStudentId).update({
                    'name': nameController.text,
                    'birthday': birthdayController.text,
                    'class': selectedClassId, // Set the selected class ID
                  });

                  // Remove the student's name from the old class if the class is changed
                  if (oldClassId != selectedClassId && oldClassId != null) {
                    FirebaseFirestore.instance.collection('Classes').doc(oldClassId).update({
                      'students': FieldValue.arrayRemove([nameController.text]),
                    });
                  }

                  // Update the student's name in the selected class
                  if (selectedClassId != null) {
                    FirebaseFirestore.instance.collection('Classes').doc(selectedClassId).update({
                      'students': FieldValue.arrayUnion([nameController.text]),
                    });
                  }

                  // Clear the input fields and reset the editing state
                  setState(() {
                    currentlyEditingStudentId = null;
                    nameController.clear();
                    birthdayController.clear();
                    classController.clear();
                    selectedClassId = null;
                    oldClassId = null; // Reset old class ID
                  });
                },
                child: Text('Save Changes'),
              ),
              SizedBox(height: 20),
              Text(
                'Add Student:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: birthdayController,
                decoration: InputDecoration(labelText: 'Birthday'),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Classes').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final classes = snapshot.data!.docs;
                  List<DropdownMenuItem<String>> classDropdownItems = [];

                  for (var classDoc in classes) {
                    final classData = classDoc.data() as Map<String, dynamic>;
                    final className = classData['name'] ?? '';
                    final classId = classDoc.id;

                    classDropdownItems.add(
                      DropdownMenuItem<String>(
                        value: classId,
                        child: Text(className),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Class'),
                    value: selectedClassId,
                    items: classDropdownItems,
                    onChanged: (value) {
                      setState(() {
                        selectedClassId = value;
                      });
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  // Add new student to Firestore with an automatically generated ID
                  await FirebaseFirestore.instance.collection('Students').add({
                    'name': nameController.text,
                    'birthday': birthdayController.text,
                    'class': selectedClassId, // Set the selected class ID
                  });

                  // Update the student's name in the selected class
                  if (selectedClassId != null) {
                    FirebaseFirestore.instance.collection('Classes').doc(selectedClassId).update({
                      'students': FieldValue.arrayUnion([nameController.text]),
                    });
                  }

                  // Clear the input fields
                  nameController.clear();
                  birthdayController.clear();
                  classController.clear();
                  selectedClassId = null;
                },
                child: Text('Add Student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
