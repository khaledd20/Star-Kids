import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'Installments.dart';
import 'login_screen.dart';
import 'studentAttendance.dart';

class StudentAddingScreen extends StatefulWidget {
  @override
  _StudentAddingScreenState createState() => _StudentAddingScreenState();
}

class _StudentAddingScreenState extends State<StudentAddingScreen> {

  final FirebaseStorage storage =
      FirebaseStorage.instanceFor(bucket: 'gs://star-kids-c24da.appspot.com/QrCodes');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController feesController = TextEditingController();
  final TextEditingController feesLeftController = TextEditingController();
  final TextEditingController installmentsController = TextEditingController();
  final TextEditingController installmentsLeftController = TextEditingController();
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController fatherPhoneController = TextEditingController();
  final TextEditingController motherController = TextEditingController();
  final TextEditingController motherPhoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController nearbyPhone1Controller = TextEditingController();
  final TextEditingController nearbyPhone2Controller = TextEditingController();

  DateTime? selectedDate;
  String? selectedClassId;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        birthdayController.text = "${selectedDate!.toLocal()}".split(' ')[0];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome to the Student Management Page!',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                'Students:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Students')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final students = snapshot.data!.docs;

                  return Column(
                    children: students.map((student) {
                      final studentData =
                          student.data() as Map<String, dynamic>;
                      final studentId = student.id;
                      final studentName = studentData['name'] ?? '';
                      final studentBirthday = studentData['birthday'] ?? '';
                      final studentClass = studentData['class'] ?? '';
                      final studentFees = studentData['fees'] ?? '';
                      final studentFeesLeft =
                          studentData['feesLeft'] ?? '';
                      final studentInstallments =
                          studentData['installments'] ?? '';
                      final studentInstallmentsLeft =
                          studentData['installmentsLeft'] ?? '';
                      final father = studentData['father'] ?? '';
                      final fatherPhone = studentData['fatherPhone'] ?? '';
                      final mother = studentData['mother'] ?? '';
                      final motherPhone = studentData['motherPhone'] ?? '';
                      final address = studentData['address'] ?? '';
                      final nearbyPhone1 = studentData['nearbyPhone1'] ?? '';
                      final nearbyPhone2 = studentData['nearbyPhone2'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          child: ExpansionTile(
                            title: Text('Name: $studentName'),
                            children: [
                              ListTile(
                                title: Text('Birthday: $studentBirthday'),
                              ),
                              ListTile(
                                title: Text('Class: $studentClass'),
                              ),
                              ListTile(
                                title: Text('Fees: $studentFees'),
                              ),
                              ListTile(
                                title: Text('Fees Left: $studentFeesLeft'),
                              ),
                              ListTile(
                                title: Text('Installments: $studentInstallments'),
                              ),
                              ListTile(
                                title: Text('Installments Left: $studentInstallmentsLeft'),
                              ),
                              ListTile(
                                title: Text("Father's Name: $father"),
                              ),
                              ListTile(
                                title: Text("Father's Phone: $fatherPhone"),
                              ),
                              ListTile(
                                title: Text("Mother's Name: $mother"),
                              ),
                              ListTile(
                                title: Text("Mother's Phone: $motherPhone"),
                              ),
                              ListTile(
                                title: Text("Address: $address"),
                              ),
                              ListTile(
                                title: Text('Nearby Phone 1: $nearbyPhone1'),
                              ),
                              ListTile(
                                title: Text('Nearby Phone 2: $nearbyPhone2'),
                              ),
                              FutureBuilder<String?>(
                                future: uploadQRCodeImage(studentId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.data != null) {
                                    return Image.network(
                                      snapshot.data!,
                                      width: 50, // Adjust the size as needed
                                      height: 50,
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Add Student:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ExpansionTile(
                title: Text('Add New Student'),
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextFormField(
                    controller: birthdayController,
                    decoration: InputDecoration(labelText: 'Birthday'),
                    onTap: () => _selectDate(context), // Show date picker when tapped
                  ),
                  TextFormField(
                    controller: feesController,
                    decoration: InputDecoration(labelText: 'Fees'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: feesLeftController,
                    decoration: InputDecoration(labelText: 'Fees Left'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: installmentsController,
                    decoration: InputDecoration(labelText: 'Installments'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: installmentsLeftController,
                    decoration: InputDecoration(labelText: 'Installments Left'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: fatherController,
                    decoration: InputDecoration(labelText: "Father's Name"),
                  ),
                  TextFormField(
                    controller: fatherPhoneController,
                    decoration: InputDecoration(labelText: "Father's Phone"),
                  ),
                  TextFormField(
                    controller: motherController,
                    decoration: InputDecoration(labelText: "Mother's Name"),
                  ),
                  TextFormField(
                    controller: motherPhoneController,
                    decoration: InputDecoration(labelText: "Mother's Phone"),
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: nearbyPhone1Controller,
                    decoration: InputDecoration(labelText: 'Nearby Phone 1'),
                  ),
                  TextFormField(
                    controller: nearbyPhone2Controller,
                    decoration: InputDecoration(labelText: 'Nearby Phone 2'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final newStudentDocRef = await FirebaseFirestore.instance.collection('Students').add({
                        'name': nameController.text,
                        'birthday': birthdayController.text,
                        'class': selectedClassId,
                        'fees': double.parse(feesController.text),
                        'feesLeft': double.parse(feesLeftController.text),
                        'installments': int.parse(installmentsController.text),
                        'installmentsLeft': int.parse(installmentsLeftController.text),
                        'father': fatherController.text,
                        'fatherPhone': fatherPhoneController.text,
                        'mother': motherController.text,
                        'motherPhone': motherPhoneController.text,
                        'address': addressController.text,
                        'nearbyPhone1': nearbyPhone1Controller.text,
                        'nearbyPhone2': nearbyPhone2Controller.text,
                      });

                      if (newStudentDocRef != null) {
                        final qrCodeImageUrl = await uploadQRCodeImage(newStudentDocRef.id);

                        if (qrCodeImageUrl != null) {
                          await newStudentDocRef.update({'photoUrl': qrCodeImageUrl});
                        } else {
                          print('Error uploading QR code image for the new student.');
                        }

                        nameController.clear();
                        birthdayController.clear();
                        feesController.clear();
                        feesLeftController.clear();
                        installmentsController.clear();
                        installmentsLeftController.clear();
                        fatherController.clear();
                        fatherPhoneController.clear();
                        motherController.clear();
                        motherPhoneController.clear();
                        addressController.clear();
                        nearbyPhone1Controller.clear();
                        nearbyPhone2Controller.clear();
                      } else {
                        print('Error adding new student to Firestore.');
                      }
                    },
                    child: Text('Add Student'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteQRCodeImage(String studentId) async {
    try {
      final storageRef = FirebaseStorage.instanceFor(bucket: 'gs://star-kids-c24da.appspot.com').ref().child("QrCodes/$studentId.png");
      await storageRef.delete();
    } catch (e) {
      print('Error deleting QR code image: $e');
    }
  }

  Future<String?> uploadQRCodeImage(String studentId) async {
    try {
      final qrImageData = await generateQRCode(studentId);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$studentId.png');
      await file.writeAsBytes(qrImageData);

      final storageRef = FirebaseStorage.instanceFor(bucket: 'gs://star-kids-c24da.appspot.com').ref().child("QrCodes/$studentId.png");

      await storageRef.putFile(file);

      final String url = await storageRef.getDownloadURL();

      return url;
    } catch (e) {
      print('Error generating/uploading QR code image: $e');
      return null;
    }
  }

  Future<Uint8List> generateQRCode(String studentId) async {
    final qrCode = QrPainter(
      data: studentId,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
      color: Color(0xff000000),
      emptyColor: Color(0xffffffff),
    );

    final size = 300.0;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(size, size)));

    qrCode.paint(canvas, Rect.fromPoints(Offset(0, 0), Offset(size, size)).size);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final imgData = await img.toByteData(format: ImageByteFormat.png);

    return imgData!.buffer.asUint8List();
  }
}
