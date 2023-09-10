import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StudentManagementScreen extends StatefulWidget {
  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final FirebaseStorage storage =
      FirebaseStorage.instanceFor(bucket: 'gs://star-kids-c24da.appspot.com/QrCodes');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController feesController = TextEditingController();
  final TextEditingController feesLeftController = TextEditingController();
  final TextEditingController installmentsController = TextEditingController();
  final TextEditingController installmentsLeftController = TextEditingController();

  String? currentlyEditingStudentId;
  String? selectedClassId;
  String? oldClassId;
  DateTime? selectedDate;

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
                stream: FirebaseFirestore.instance.collection('Students').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final students = snapshot.data!.docs;

                  return Column(
                    children: students.map((student) {
                      final studentData = student.data() as Map<String, dynamic>;
                      final studentId = student.id;
                      final studentName = studentData['name'] ?? '';
                      final studentBirthday = studentData['birthday'] ?? '';
                      final studentClass = studentData['class'] ?? '';
                      final studentFees = studentData['fees'] ?? '';
                      final studentFeesLeft = studentData['feesLeft'] ?? '';
                      final studentInstallments = studentData['installments'] ?? '';
                      final studentInstallmentsLeft = studentData['installmentsLeft'] ?? '';

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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FutureBuilder<String?>(
                                    future: uploadQRCodeImage(studentId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
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
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        currentlyEditingStudentId = studentId;
                                        oldClassId = studentClass;
                                      });

                                      nameController.text = studentName;
                                      birthdayController.text = studentBirthday;
                                      classController.text = studentClass;
                                      feesController.text = studentFees;
                                      feesLeftController.text = studentFeesLeft;
                                      installmentsController.text = studentInstallments;
                                      installmentsLeftController.text = studentInstallmentsLeft;
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      if (oldClassId != null) {
                                        await FirebaseFirestore.instance.collection('Classes').doc(oldClassId!).update({
                                          'students': FieldValue.arrayRemove([studentName]),
                                        });
                                      }

                                      await deleteStudentAndQR(studentId, studentName);
                                    },
                                  ),
                                ],
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
                'Edit Student:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ExpansionTile(
                title: Text('Edit Student Details'),
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
                  ElevatedButton(
                    onPressed: () async {
                      if (currentlyEditingStudentId != null) {
                        final qrCodeImageUrl = await uploadQRCodeImage(currentlyEditingStudentId!);

                        if (qrCodeImageUrl != null) {
                          await FirebaseFirestore.instance.collection('Students').doc(currentlyEditingStudentId!).update({
                            'name': nameController.text,
                            'birthday': birthdayController.text,
                            'class': selectedClassId,
                            'fees': double.parse(feesController.text),
                            'feesLeft': double.parse(feesLeftController.text),
                            'installments': int.parse(installmentsController.text),
                            'installmentsLeft': int.parse(installmentsLeftController.text),
                            'photoUrl': qrCodeImageUrl,
                          });

                          if (oldClassId != selectedClassId && oldClassId != null) {
                            FirebaseFirestore.instance.collection('Classes').doc(oldClassId!).update({
                              'students': FieldValue.arrayRemove([nameController.text]),
                            });
                          }

                          if (selectedClassId != null) {
                            FirebaseFirestore.instance.collection('Classes').doc(selectedClassId!).update({
                              'students': FieldValue.arrayUnion([nameController.text]),
                            });
                          }

                          setState(() {
                            currentlyEditingStudentId = null;
                            nameController.clear();
                            birthdayController.clear();
                            classController.clear();
                            feesController.clear();
                            feesLeftController.clear();
                            installmentsController.clear();
                            installmentsLeftController.clear();
                            selectedClassId = null;
                            oldClassId = null;
                          });
                        } else {
                          print('Error uploading QR code image.');
                        }
                      }
                    },
                    child: Text('Save Changes'),
                  ),
                ],
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
                      });

                      if (newStudentDocRef != null) {
                        final qrCodeImageUrl = await uploadQRCodeImage(newStudentDocRef.id);

                        if (qrCodeImageUrl != null) {
                          await newStudentDocRef.update({'photoUrl': qrCodeImageUrl});
                        } else {
                          print('Error uploading QR code image for the new student.');
                        }

                        if (selectedClassId != null) {
                          FirebaseFirestore.instance.collection('Classes').doc(selectedClassId!).update({
                            'students': FieldValue.arrayUnion([nameController.text]),
                          });
                        }

                        nameController.clear();
                        birthdayController.clear();
                        classController.clear();
                        feesController.clear();
                        feesLeftController.clear();
                        installmentsController.clear();
                        installmentsLeftController.clear();
                        selectedClassId = null;
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

  Future<void> deleteStudentAndQR(String studentId, String studentName) async {
    try {
      // Get the class ID associated with the student
      final studentSnapshot = await FirebaseFirestore.instance.collection('Students').doc(studentId).get();
      final studentData = studentSnapshot.data() as Map<String, dynamic>;
      final studentClassId = studentData['class'];

      // Delete the student document
      await FirebaseFirestore.instance.collection('Students').doc(studentId).delete();

      // Delete the QR code image
      await deleteQRCodeImage(studentId);

      // If the student was associated with a class, remove the student's name from the class document
      if (studentClassId != null) {
        await FirebaseFirestore.instance.collection('Classes').doc(studentClassId).update({
          'students': FieldValue.arrayRemove([studentName]),
        });
      }
    } catch (e) {
      print('Error deleting student and QR code: $e');
    }
  }
}
