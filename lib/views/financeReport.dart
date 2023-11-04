import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Installments_Manage.dart';
import 'archievedStudents.dart';
import 'attendanceReport.dart';
import 'login_screen.dart';
import 'studentManagement.dart';
import 'userManagement.dart';

class FinanceReportScreen extends StatefulWidget {
  @override
  _FinanceReportScreenState createState() => _FinanceReportScreenState();
}

class _FinanceReportScreenState extends State<FinanceReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? fromDate;
  DateTime? toDate;
  String studentNameFilter = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تقرير المالية'),
          actions: [
            ElevatedButton(
              onPressed: _printFilteredDocuments,
              child: Text('طياعة الفواتير'),
            ),
          ],
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
              title: Text('تقرير المالية'),
              onTap: () {
                // انتقل إلى شاشة تقرير المالية
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
        body: Column(
          children: [
            _buildDateFilterRow(),
            _buildStudentNameFilterRow(),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      fromDate = null;
                      toDate = null;
                    });
                  },
                  child: Text('إعادة تعيين التواريخ'),
                ),
                SizedBox(width: 20),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Finance').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final installments = snapshot.data!.docs;

                  if (installments.isEmpty) {
                    return Center(child: Text('لا توجد دفعات متاحة.'));
                  }

                  final filteredInstallments = _filterInstallments(installments);

                  if (filteredInstallments.isEmpty) {
                    return Center(child: Text('لا توجد دفعات ضمن نطاق التاريخ المحدد.'));
                  }

                  return ListView.builder(
                    itemCount: filteredInstallments.length,
                    itemBuilder: (context, index) {
                      final installmentData = filteredInstallments[index].data() as Map<String, dynamic>;
                      final selectedClass = installmentData['class'] ?? '';
                      final studentName = installmentData['studentName'] ?? '';
                      final amount = installmentData['amount'] ?? 0.0;
                      final date = installmentData['date'] ?? '';
                      final receiptNumber = installmentData['receiptNumber'] ?? '';

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text('الصف: $selectedClass'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('اسم الطالب: $studentName'),
                              Text('المبلغ: $amount'),
                              Text('التاريخ: $date'),
                              Text('رقم الإيصال: $receiptNumber'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterRow() {
    return Row(
      children: [
        Text('من: '),
        TextButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: fromDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (selectedDate != null) {
              setState(() {
                fromDate = selectedDate;
              });
            }
          },
          child: Text(fromDate != null ? fromDate!.toString().split(' ')[0] : 'اختر التاريخ'),
        ),
        SizedBox(width: 20),
        Text('إلى: '),
        TextButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: toDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (selectedDate != null) {
              setState(() {
                toDate = selectedDate;
              });
            }
          },
          child: Text(toDate != null ? toDate!.toString().split(' ')[0] : 'اختر التاريخ'),
        ),
        SizedBox(width: 20),
      ],
    );
  }

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

  List<QueryDocumentSnapshot> _filterInstallments(List<QueryDocumentSnapshot> installments) {
    final fromDateCondition = fromDate ?? DateTime(2000);
    final toDateCondition = toDate ?? DateTime(2101);

    return installments.where((installment) {
      final installmentData = installment.data() as Map<String, dynamic>;

      if (!installmentData.containsKey('date') || !(installmentData['date'] is String)) {
        return false;
      }

      final dateStr = installmentData['date'] as String;
      final installmentDate = DateTime.parse(dateStr);

      final dateCondition =
          installmentDate.isAfter(fromDateCondition) && installmentDate.isBefore(toDateCondition);

      final studentNameCondition = studentNameFilter.isEmpty ||
          (installmentData['studentName'] as String).toLowerCase().contains(studentNameFilter.toLowerCase());

      return dateCondition && studentNameCondition;
    }).toList();
  }



Future<void> _printFilteredDocuments() async {
    final List<QueryDocumentSnapshot> documents = await _firestore.collection('Finance').get().then((value) => value.docs);

    final pdf = pw.Document();

    // Load the main Arabic font
    // final font = await _loadArabicFont();

    // Load an alternative font for unsupported characters (e.g., Arial Unicode MS)
    final fontFallback = pw.Font.ttf(await rootBundle.load('fonts/NotoSans-Bold.ttf'));

    final filteredDocuments = _filterDocuments(documents);

    if (filteredDocuments.isEmpty) {
      // No filtered documents to print
      return;
    }

    final arabic = pw.Font.ttf(await rootBundle.load('/fonts/NotoKufiArabic-Regular.ttf'));

    for (final document in filteredDocuments) {
      final documentData = document.data() as Map<String, dynamic>;
      final selectedClass = documentData['class'] ?? '';
      final studentName = documentData['studentName'] ?? '';
      final amount = documentData['amount'] ?? 0.0;
      final date = documentData['date'] ?? '';
      final receiptNumber = documentData['receiptNumber'] ?? '';
      final image = pw.MemoryImage(Uint8List.fromList((await rootBundle.load('images/stark.png')).buffer.asUint8List()));

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end, // Align content to the right
            children: [
             pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                   pw.Container(
                alignment: pw.Alignment.bottomLeft, // Align the image to the top-left
                child: pw.Image(image, width: 150, height: 150),
                  ),
              pw.SizedBox(height: 20),
                  // Arabic Text with reversed RTL text direction
                  pw.Text(
                    'الصف: $selectedClass',
                    style: pw.TextStyle(fontSize: 20, font: arabic, fontFallback: [fontFallback]),
                  ),
                  pw.SizedBox(height: 10),

                  // Arabic Text with reversed RTL text direction
                  pw.Text(
                    'اسم الطالب: $studentName',
                    style: pw.TextStyle(fontSize: 20, font: arabic, fontFallback: [fontFallback]),
                  ),
                  pw.SizedBox(height: 10),

                  // Arabic Text with reversed RTL text direction
                  pw.Text(
                    'المبلغ: $amount',
                    style: pw.TextStyle(fontSize: 20, font: arabic, fontFallback: [fontFallback]),
                  ),
                  pw.SizedBox(height: 10),

                  // Arabic Text with reversed RTL text direction
                  pw.Text(
                    'التاريخ: $date',
                    style: pw.TextStyle(fontSize: 20, font: arabic, fontFallback: [fontFallback]),
                  ),
                  pw.SizedBox(height: 10),

                  // Arabic Text with reversed RTL text direction
                  pw.Text(
                    'رقم الإيصال: $receiptNumber',
                    style: pw.TextStyle(fontSize: 20, font: arabic, fontFallback: [fontFallback]),
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),
             ),
             ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  List<QueryDocumentSnapshot> _filterDocuments(List<QueryDocumentSnapshot> documents) {
    final fromDateCondition = fromDate ?? DateTime(2000);
    final toDateCondition = toDate ?? DateTime(2101);

    return documents.where((document) {
      final documentData = document.data() as Map<String, dynamic>;

      if (!documentData.containsKey('date') || !(documentData['date'] is String)) {
        return false;
      }

      final dateStr = documentData['date'] as String;
      final documentDate = DateTime.parse(dateStr);

      final dateCondition =
          documentDate.isAfter(fromDateCondition) && documentDate.isBefore(toDateCondition);

      final studentNameCondition = studentNameFilter.isEmpty ||
          (documentData['studentName'] as String).toLowerCase().contains(studentNameFilter.toLowerCase());

      return dateCondition && studentNameCondition;
    }).toList();
  }
}



void main() {
  runApp(MaterialApp(
    home: FinanceReportScreen(),
  ));
}