import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html; // Import for web
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


import 'Installments_Manage.dart';
import 'archievedStudents.dart';
import 'attendanceReport.dart';
import 'financeReport.dart';
import 'login_screen.dart';
import 'statistics.dart';
import 'userManagement.dart';
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
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController fatherPhoneController = TextEditingController();
  final TextEditingController motherController = TextEditingController();
  final TextEditingController motherPhoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController nearbyPhone1Controller = TextEditingController();
  final TextEditingController nearbyPhone2Controller = TextEditingController();


  final TextEditingController editnameController = TextEditingController();
  final TextEditingController editbirthdayController = TextEditingController();
  final TextEditingController editclassController = TextEditingController();
  final TextEditingController editfeesController = TextEditingController();
  final TextEditingController editfeesLeftController = TextEditingController();
  final TextEditingController editinstallmentsController = TextEditingController();
  final TextEditingController editinstallmentsLeftController = TextEditingController();
  final TextEditingController editfatherController = TextEditingController();
  final TextEditingController editfatherPhoneController = TextEditingController();
  final TextEditingController editmotherController = TextEditingController();
  final TextEditingController editmotherPhoneController = TextEditingController();
  final TextEditingController editaddressController = TextEditingController();
  final TextEditingController editnearbyPhone1Controller = TextEditingController();
  final TextEditingController editnearbyPhone2Controller = TextEditingController();

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


    String studentNameFilter = ''; // Add this variable for filtering by student name

   // Widget for filtering by student name
  Widget _buildStudentNameFilterRow() {
    return Row(
      children: [
        Text('اسم الطالب: '),
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                studentNameFilter = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'أدخل اسم الطالب',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // تعيين اتجاه النص إلى اليمين لليسار (RTL)
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
                  color: Color.fromARGB(255, 0, 30, 57)
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
              title: Text('شاشة إدارة المستخدمين'),
              onTap: () {
                // انتقل إلى شاشة إدارة المستخدمين
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => userManagementScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('شاشة إدارة الطلاب'),
              onTap: () {
                // انتقل إلى شاشة إدارة الطلاب
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StudentManagementScreen(),
                    ),
                  );
              },
            ),
             ListTile(
              title: Text('احصائيات الطلاب'),
              onTap: () {
                // انتقل إلى شاشة إدارة الطلاب
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('إدارة الدفعات'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => InstallmentsManageScreen(),
                    ),
                  );
                },
              ),
            ListTile(
              title: Text('تقرير مالي'),
              onTap: () {
                // انتقل إلى شاشة التقرير المالي
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FinanceReportScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('تقرير الحضور'),
              onTap: () {
                // انتقل إلى شاشة تقرير الحضور
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AttendanceReportScreen(),
                    ),
                  );
              },
            ),
            ListTile(
              title: Text('الطلاب المؤرشفين'),
              onTap: () {
                // انتقل إلى شاشة الطلاب المؤرشفين
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ArchivedStudentsScreen(),
                    ),
                  );
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
               _buildStudentNameFilterRow(), // Add the student name filter widget
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
                      final father = studentData['father'] ?? '';
                      final fatherPhone = studentData['fatherPhone'] ?? '';
                      final mother = studentData['mother'] ?? '';
                      final motherPhone = studentData['motherPhone'] ?? '';
                      final address = studentData['address'] ?? '';
                      final nearbyPhone1 = studentData['nearbyPhone1'] ?? '';
                      final nearbyPhone2 = studentData['nearbyPhone2'] ?? '';
                      if (!studentName.toLowerCase().contains(studentNameFilter.toLowerCase())) {
                          return Container(); // Return an empty container to hide the student
                        }

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
                                title: Text('اسم الأب: $father'),
                              ),
                              ListTile(
                                title: Text('هاتف الأب: $fatherPhone'),
                              ),
                              ListTile(
                                title: Text('اسم الأم: $mother'),
                              ),
                              ListTile(
                                title: Text('هاتف الأم: $motherPhone'),
                              ),
                              ListTile(
                                title: Text('العنوان: $address'),
                              ),
                              ListTile(
                                title: Text('هاتف قريب 1: $nearbyPhone1'),
                              ),
                              ListTile(
                                title: Text('هاتف قريب 2: $nearbyPhone2'),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  
                                  IconButton(
                                    icon: Icon(Icons.edit,  color: Colors.blue),
                                   onPressed: () {
                                    setState(() {
                                      currentlyEditingStudentId = studentId;
                                      oldClassId = studentClass;
                                    });

                                    editnameController.text = studentName;
                                    editbirthdayController.text = studentBirthday;
                                    editclassController.text = studentClass;
                                    editfeesController.text = studentFees.toString(); // Convert to string if necessary
                                    editfeesLeftController.text = studentFeesLeft.toString(); // Convert to string if necessary
                                    editinstallmentsController.text = studentInstallments.toString();
                                    editinstallmentsLeftController.text = studentInstallmentsLeft.toString();
                                    editfatherController.text = father;
                                    editfatherPhoneController.text = fatherPhone;
                                    editmotherController.text = mother;
                                    editmotherPhoneController.text = motherPhone.toString();
                                    editaddressController.text = address;
                                    editnearbyPhone1Controller.text = nearbyPhone1.toString();
                                    editnearbyPhone2Controller.text = nearbyPhone2.toString();
                                  },

                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete , color: Colors.red),
                                    onPressed: () async {
                                      if (oldClassId != null) {
                                        await FirebaseFirestore.instance.collection('Classes').doc(oldClassId!).update({
                                          'students': FieldValue.arrayRemove([studentName]),
                                        });
                                      }

                                      await deleteStudentAndQR(studentId, studentName);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.archive,  color: Colors.green), // أضف أيقونة الأرشفة هنا
                                    onPressed: () async {
                                      await archiveStudent(studentId, studentData); // قم بأرشفة الطالب
                                    },
                                  ),
                                   ElevatedButton(
                                      onPressed: () {
                                        _printQRCodeForStudent(studentId);
                                      },
                                      child: Text('طباعة الكود '),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _printStudentDetails(studentData);
                                      },
                                      child: Text('طباعة التفاصيل'),
                                    ),
                                    // Filter students by name
                        
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
                'تعديل بيانات الطالب:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ExpansionTile(
                title: Text('تعديل تفاصيل الطالب'),
                children: [
                  TextFormField(
                    controller: editnameController,
                    decoration: InputDecoration(labelText: 'الاسم'),
                  ),
                  TextFormField(
                    controller: editbirthdayController,
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
                    controller: editfeesController,
                    decoration: InputDecoration(labelText: 'الرسوم'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: editfeesLeftController,
                    decoration: InputDecoration(labelText: 'الرسوم المتبقية'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: editinstallmentsController,
                    decoration: InputDecoration(labelText: 'الأقساط'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: editinstallmentsLeftController,
                    decoration: InputDecoration(labelText: 'الأقساط المتبقية'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: editfatherController,
                    decoration: InputDecoration(labelText: 'اسم الأب'),
                  ),
                  TextFormField(
                    controller: editfatherPhoneController,
                    decoration: InputDecoration(labelText: 'هاتف الأب'),
                  ),
                  TextFormField(
                    controller: editmotherController,
                    decoration: InputDecoration(labelText: 'اسم الأم'),
                  ),
                  TextFormField(
                    controller: editmotherPhoneController,
                    decoration: InputDecoration(labelText: 'هاتف الأم'),
                  ),
                  TextFormField(
                    controller: editaddressController,
                    decoration: InputDecoration(labelText: 'العنوان'),
                  ),
                  TextFormField(
                    controller: editnearbyPhone1Controller,
                    decoration: InputDecoration(labelText: 'هاتف قريب 1'),
                  ),
                  TextFormField(
                    controller: editnearbyPhone2Controller,
                    decoration: InputDecoration(labelText: 'هاتف قريب 2'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (currentlyEditingStudentId != null) {
                        final qrCodeImageUrl = await uploadQRCodeImage(currentlyEditingStudentId!);

                        if (qrCodeImageUrl != null) {
                          await FirebaseFirestore.instance.collection('Students').doc(currentlyEditingStudentId!).update({
                            'name': editnameController.text,
                            'birthday': editbirthdayController.text,
                            'class': selectedClassId,
                            'fees': double.parse(editfeesController.text),
                            'feesLeft': double.parse(editfeesLeftController.text),
                            'installments': int.parse(editinstallmentsController.text),
                            'installmentsLeft': int.parse(editinstallmentsLeftController.text),
                            'father': editfatherController.text,
                            'fatherPhone': editfatherPhoneController.text,
                            'mother': editmotherController.text,
                            'motherPhone': editmotherPhoneController.text,
                            'address': editaddressController.text,
                            'nearbyPhone1': editnearbyPhone1Controller.text,
                            'nearbyPhone2': editnearbyPhone2Controller.text,
                            'photoUrl': qrCodeImageUrl,
                          });

                          if (oldClassId != selectedClassId && oldClassId != null) {
                            FirebaseFirestore.instance.collection('Classes').doc(oldClassId!).update({
                              'students': FieldValue.arrayRemove([editnameController.text]),
                            });
                          }

                          if (selectedClassId != null) {
                            FirebaseFirestore.instance.collection('Classes').doc(selectedClassId!).update({
                              'students': FieldValue.arrayUnion([editnameController.text]),
                            });
                          }

                          setState(() {
                            currentlyEditingStudentId = null;
                            editnameController.clear();
                            editbirthdayController.clear();
                            editclassController.clear();
                            editfeesController.clear();
                            editfeesLeftController.clear();
                            editinstallmentsController.clear();
                            editinstallmentsLeftController.clear();
                            editfatherController.clear();
                            editfatherPhoneController.clear();
                            editmotherController.clear();
                            editmotherPhoneController.clear();
                            editaddressController.clear();
                            editnearbyPhone1Controller.clear();
                            editnearbyPhone2Controller.clear();
                            selectedClassId = null;
                            oldClassId = null;
                          });
                        } else {
                          print('خطأ في رفع صورة الرمز الاستجابي.');
                        }
                      }
                    },
                    child: Text('حفظ التغييرات'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'إضافة طالب جديد:',
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
}

Future<void> _printQRCodeForStudent(String studentId) async {
  final pdf = pw.Document();

  // Create a widget to display the QR code image
  final qrCodeImage = pw.MemoryImage(
    (await generateQRCode(studentId)).buffer.asUint8List(),
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(qrCodeImage, width: 200, height: 200),
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (_) async => pdf.save());
}


  Future<void> _printStudentDetails(Map<String, dynamic> studentData) async {
  final pdf = pw.Document();

  // Load the main Arabic font
  final arabic = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoKufiArabic-Regular.ttf'));

    final image = pw.MemoryImage(Uint8List.fromList((await rootBundle.load('images/stark.png')).buffer.asUint8List()));

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (pw.Context context) {
        return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start, // Align content to the right

            children: [
         pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
             pw.Container(
                alignment: pw.Alignment.bottomLeft, // Align the image to the top-left
                child: pw.Image(image, width: 150, height: 150),
                  ),
              pw.SizedBox(height: 20),
            pw.Text(
              'الصف: ${studentData['class']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'اسم الطالب: ${studentData['name']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'تاريخ الميلاد: ${studentData['birthday']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'الرسوم: ${studentData['fees']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'الرسوم المتبقية: ${studentData['feesLeft']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'الأقساط: ${studentData['installments']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'الأقساط المتبقية: ${studentData['installmentsLeft']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'اسم الأب: ${studentData['father']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'هاتف الأب: ${studentData['fatherPhone']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'اسم الأم: ${studentData['mother']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'هاتف الأم: ${studentData['motherPhone']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'العنوان: ${studentData['address']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'الهاتف القريب 1: ${studentData['nearbyPhone1']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
            pw.Text(
              'الهاتف القريب 2: ${studentData['nearbyPhone2']}',
              style: pw.TextStyle(fontSize: 20, font: arabic),
            ),
          ],
         ),
            ]
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (_) async => pdf.save());
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

    await storageRef.putData(qrImageData);

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

Future<void> deleteStudentAndQR(String studentId, String studentName) async {
  try {
    // الحصول على معرف الصف المرتبط بالطالب
    final studentSnapshot = await FirebaseFirestore.instance.collection('Students').doc(studentId).get();
    final studentData = studentSnapshot.data() as Map<String, dynamic>;
    final studentClassId = studentData['class'];

    // حذف مستند الطالب
    await FirebaseFirestore.instance.collection('Students').doc(studentId).delete();

    // حذف صورة الرمز الاستجابي
    await deleteQRCodeImage(studentId);

    // إذا كان الطالب مرتبطًا بصف معين، قم بإزالة اسم الطالب من مستند الصف
    if (studentClassId != null) {
      await FirebaseFirestore.instance.collection('Classes').doc(studentClassId).update({
        'students': FieldValue.arrayRemove([studentName]),
      });
    }
  } catch (e) {
    print('خطأ في حذف الطالب وصورة الرمز الاستجابي: $e');
  }
}

Future<void> archiveStudent(String studentId, Map<String, dynamic> studentData) async {
  try {
    // إنشاء مرجع للمجموعة المؤرشفة
    final archivedCollection = FirebaseFirestore.instance.collection('Archived');
    final studentClassId = studentData['class'];

    // إضافة بيانات الطالب إلى مجموعة "المؤرشفة"
    await archivedCollection.doc(studentId).set(studentData);

    // حذف الطالب من مجموعة "الطلاب"
    await FirebaseFirestore.instance.collection('Students').doc(studentId).delete();
     // Remove student's name from the class in the Classes collection
    if (studentClassId != null) {
      await FirebaseFirestore.instance.collection('Classes').doc(studentClassId).update({
        'students': FieldValue.arrayRemove([studentData['name']]),
      });
    }
    // حذف صورة الرمز الاستجابي
    await deleteQRCodeImage(studentId);
  } catch (e) {
    print('خطأ في أرشفة الطالب: $e');
  }
}
