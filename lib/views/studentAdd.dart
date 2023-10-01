import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:universal_html/html.dart' as html; // Import for web

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة الطلاب'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                color: Color.fromARGB(255, 183, 189, 0),
              ),
                child: Text(
                  'قائمة المشرف',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.navigate_next),
                title: Text('الحضور'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StudentAttendanceScreen(user: null),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.manage_accounts),
                title: Text('إضافة طالب'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => StudentAddingScreen(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.payment_sharp),
                title: Text('الأقساط'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => InstallmentsScreen(),
                  ));
                },
              ),
              ListTile(
                title: Text('تسجيل الخروج'),
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
                  'مرحبًا بك في صفحة إدارة الطلاب!',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                Text(
                  'الطلاب:',
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
                              title: Text('الاسم: $studentName'),
                              children: [
                                ListTile(
                                  title: Text('تاريخ الميلاد: $studentBirthday'),
                                ),
                                ListTile(
                                  title: Text('الصف: $studentClass'),
                                ),
                                ListTile(
                                  title: Text('الرسوم: $studentFees'),
                                ),
                                ListTile(
                                  title: Text('الرسوم المتبقية: $studentFeesLeft'),
                                ),
                                ListTile(
                                  title: Text('الأقساط: $studentInstallments'),
                                ),
                                ListTile(
                                  title: Text('الأقساط المتبقية: $studentInstallmentsLeft'),
                                ),
                                ListTile(
                                  title: Text("اسم الأب: $father"),
                                ),
                                ListTile(
                                  title: Text("هاتف الأب: $fatherPhone"),
                                ),
                                ListTile(
                                  title: Text("اسم الأم: $mother"),
                                ),
                                ListTile(
                                  title: Text("هاتف الأم: $motherPhone"),
                                ),
                                ListTile(
                                  title: Text("العنوان: $address"),
                                ),
                                ListTile(
                                  title: Text('الهاتف القريب 1: $nearbyPhone1'),
                                ),
                                ListTile(
                                  title: Text('الهاتف القريب 2: $nearbyPhone2'),
                                ),
                                FutureBuilder<Uint8List?>(
                                  future: generateQRCode(studentId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.data != null) {
                                      if (html.window.navigator.userAgent.contains('Edge')) {
                                        // Edge browser workaround
                                        final url = Uri.dataFromBytes(
                                          snapshot.data!,
                                          mimeType: 'image/png',
                                        ).toString();
                                        return Image.network(
                                          url,
                                          width: 50, // Adjust the size as needed
                                          height: 50,
                                        );
                                      } else {
                                        return Image.memory(
                                          snapshot.data!,
                                          width: 50, // Adjust the size as needed
                                          height: 50,
                                        );
                                      }
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
                  'إضافة طالب:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
               ExpansionTile(
                title: Text('إضافة طالب جديد'),
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'الاسم'),
                  ),
                  TextFormField(
                    controller: birthdayController,
                    decoration: InputDecoration(labelText: 'تاريخ الميلاد'),
                    onTap: () => _selectDate(context), // عرض منتقى التاريخ عند النقر
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
                        decoration: InputDecoration(labelText: 'الصف'),
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
                    decoration: InputDecoration(labelText: 'الرسوم'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: feesLeftController,
                    decoration: InputDecoration(labelText: 'الرسوم المتبقية'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: installmentsController,
                    decoration: InputDecoration(labelText: 'الأقساط'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: installmentsLeftController,
                    decoration: InputDecoration(labelText: 'الأقساط المتبقية'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: fatherController,
                    decoration: InputDecoration(labelText: 'اسم الأب'),
                  ),
                  TextFormField(
                    controller: fatherPhoneController,
                    decoration: InputDecoration(labelText: 'هاتف الأب'),
                  ),
                  TextFormField(
                    controller: motherController,
                    decoration: InputDecoration(labelText: 'اسم الأم'),
                  ),
                  TextFormField(
                    controller: motherPhoneController,
                    decoration: InputDecoration(labelText: 'هاتف الأم'),
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'العنوان'),
                  ),
                  TextFormField(
                    controller: nearbyPhone1Controller,
                    decoration: InputDecoration(labelText: 'هاتف قريب 1'),
                  ),
                  TextFormField(
                    controller: nearbyPhone2Controller,
                    decoration: InputDecoration(labelText: 'هاتف قريب 2'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final newStudentDocRef = await FirebaseFirestore.instance.collection('Students').add({
                        'name': nameController.text,
                        'birthday': birthdayController.text,
                        'class': selectedClassId,
                        'fees': double.parse(feesController.text),
                        'feesLeft': double.parse(feesLeftController.text),
                        'installments': double.parse(installmentsController.text),
                        'installmentsLeft': double.parse(installmentsLeftController.text),
                        'father': fatherController.text,
                        'fatherPhone': fatherPhoneController.text,
                        'mother': motherController.text,
                        'motherPhone': double.parse(motherPhoneController.text),
                        'address': addressController.text,
                        'nearbyPhone1': double.parse(nearbyPhone1Controller.text),
                        'nearbyPhone2': double.parse(nearbyPhone2Controller.text),
                        'photoUrl': '', // سيتم تحديثها لاحقًا بعد رفع صورة الرمز الاستجابي
                      });

                      if (selectedClassId != null) {
                        FirebaseFirestore.instance.collection('Classes').doc(selectedClassId!).update({
                          'students': FieldValue.arrayUnion([nameController.text]),
                        });
                      }

                      final qrCodeImageUrl = await uploadQRCodeImage(newStudentDocRef.id);

                      if (qrCodeImageUrl != null) {
                        newStudentDocRef.update({'photoUrl': qrCodeImageUrl});

                        setState(() {
                          nameController.clear();
                          birthdayController.clear();
                          classController.clear();
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
                          selectedClassId = null;
                        });
                      } else {
                        print('خطأ في رفع صورة الرمز الاستجابي.');
                      }
                    },
                    child: Text('إضافة طالب جديد'),
                  ),
                ],
              ),
              ],
            ),
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
      print('خطأ في حذف صورة الرمز الاستجابي: $e');
    }
  }

  Future<String?> uploadQRCodeImage(String studentId) async {
    try {
      final qrImageData = await generateQRCode(studentId);

      final storageRef = FirebaseStorage.instanceFor(bucket: 'gs://star-kids-c24da.appspot.com').ref().child("QrCodes/$studentId.png");

      await storageRef.putData(qrImageData); // Use putData for web

      final String url = await storageRef.getDownloadURL();

      return url;
    } catch (e) {
      print('خطأ في إنشاء/رفع صورة الرمز الاستجابي: $e');
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
