import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'Installments.dart';
import 'login_screen.dart';
import 'studentAdd.dart';
import 'studentAttendance.dart';

class InstallmentReceiptScreen extends StatelessWidget {
  final String selectedClass;
  final String studentName;
  final double amount;
  final String date;
  final String receiptNumber;
  final double studentFeesLeft;
  final int studentInstallments;
  final int studentInstallmentsLeft;

  InstallmentReceiptScreen({
    required this.selectedClass,
    required this.studentName,
    required this.amount,
    required this.date,
    required this.receiptNumber,
    required this.studentFeesLeft,
    required this.studentInstallments,
    required this.studentInstallmentsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إيصال القسط'),
          actions: [
            IconButton(
              icon: Icon(Icons.print),
              onPressed: () {
                _printInstallmentDetails();
              },
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
            child: Container(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('بيانات القسط:', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  Text('الصف: $selectedClass', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('اسم الطالب: $studentName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('المبلغ: $amount', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('التاريخ: $date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('رقم الإيصال: $receiptNumber', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('الرسوم المتبقية: $studentFeesLeft', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('الأقساط: $studentInstallments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('الأقساط المتبقية: $studentInstallmentsLeft', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

 Future<void> _printInstallmentDetails() async {
    final pdf = pw.Document();

    final arabic = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoKufiArabic-Regular.ttf'));

    final image = pw.MemoryImage(Uint8List.fromList((await rootBundle.load('images/stark.png')).buffer.asUint8List()));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end, // Align content to the right
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                alignment: pw.Alignment.bottomLeft, // Align the image to the top-left
                child: pw.Image(image, width: 150, height: 150),
                  ),
              pw.SizedBox(height: 20),
                  pw.Text(
                    'بيانات القسط:',
                    style: pw.TextStyle(fontSize: 30, font: arabic),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'الصف: $selectedClass',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                  pw.Text(
                    'اسم الطالب: $studentName',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                  pw.Text(
                    'المبلغ: $amount',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                  pw.Text(
                    'التاريخ: $date',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                  pw.Text(
                    'رقم الإيصال: $receiptNumber',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                  pw.Text(
                    'الرسوم المتبقية: $studentFeesLeft',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                  pw.Text(
                    'الأقساط: $studentInstallments',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                  pw.Text(
                    'الأقساط المتبقية: $studentInstallmentsLeft',
                    style: pw.TextStyle(fontSize: 20, font: arabic),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

}
