import 'package:flutter/material.dart';

class InstallmentReceiptScreen extends StatelessWidget {
  final String selectedClass;
  final String studentName;
  final double amount;
  final String date;
  final String receiptNumber;
  final double studentFeesLeft; // Add this line
  final int studentInstallments; // Add this line
  final int studentInstallmentsLeft; // Add this line

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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'بيانات القسط:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('الصف: $selectedClass'),
              Text('اسم الطالب: $studentName'),
              Text('المبلغ: $amount'),
              Text('التاريخ: $date'),
              Text('رقم الإيصال: $receiptNumber'),
              // Added lines
              Text('الرسوم المتبقية: $studentFeesLeft'),
              Text('الأقساط: $studentInstallments'),
              Text('الأقساط المتبقية: $studentInstallmentsLeft'),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
