import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'archievedStudents.dart';
import 'attendanceReport.dart';
import 'financeReport.dart';
import 'login_screen.dart';
import 'statistics.dart';
import 'studentManagement.dart';
import 'userManagement.dart';

class InstallmentsManageScreen extends StatefulWidget {
  @override
  _InstallmentsManageScreenState createState() => _InstallmentsManageScreenState();
}

class _InstallmentsManageScreenState extends State<InstallmentsManageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String studentNameFilter = ''; // Add this variable for filtering by student name

  void _showInstallmentForm({DocumentSnapshot? installmentData}) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => InstallmentFormScreen(installmentData: installmentData?.data() as Map<String, dynamic>?),
    );

    if (result != null) {
      if (installmentData != null) {
        _firestore.collection('Finance').doc(installmentData.id).update(result);
      } else {
        _firestore.collection('Finance').add(result);
      }
    }
  }

  void _deleteInstallment(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تأكيد'),
          content: Text('هل تريد حذف هذه الدفعة؟'),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('حذف'),
              onPressed: () {
                _firestore.collection('Finance').doc(id).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة الدفعات'),
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
            _buildStudentNameFilterRow(), // Add the student name filter widget
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

                  // Filter installments by student name
                  final filteredInstallments = installments.where((installment) {
                    final studentName =
                        (installment.data() as Map<String, dynamic>)['studentName'].toString().toLowerCase();
                    return studentName.contains(studentNameFilter.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredInstallments.length,
                    itemBuilder: (context, index) {
                      final installmentData = filteredInstallments[index].data() as Map<String, dynamic>;

                      final divider = Divider();

                      return Column(
                        children: [
                          ListTile(
                            title: Text(installmentData['studentName'] ?? ''),
                            subtitle: Text(installmentData['amount'].toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () =>
                                      _showInstallmentForm(installmentData: filteredInstallments[index]),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteInstallment(filteredInstallments[index].id),
                                ),
                              ],
                            ),
                          ),
                          if (index < filteredInstallments.length - 1) divider,
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showInstallmentForm(),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}


class InstallmentFormScreen extends StatelessWidget {
  final Map<String, dynamic>? installmentData;

  InstallmentFormScreen({this.installmentData});

  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _classController = TextEditingController(); // Add this
  final _dateController = TextEditingController();  // Add this
  final _amountController = TextEditingController();
  final _receiptNumberController = TextEditingController();  // Add this

  @override
  Widget build(BuildContext context) {
    if (installmentData != null) {
      _studentNameController.text = installmentData!['studentName'];
      _classController.text = installmentData!['class'] ?? '';  // Add this
      _dateController.text = installmentData!['date'] ?? '';    // Add this
      _amountController.text = installmentData!['amount'].toString();
      _receiptNumberController.text = installmentData!['receiptNumber'] ?? '';  // Add this
    }

    return AlertDialog(
      title: Text(installmentData != null ? 'تعديل الدفعة' : 'إضافة دفعة جديدة'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _studentNameController,
              decoration: InputDecoration(labelText: 'اسم الطالب'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم الطالب';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _classController,
              decoration: InputDecoration(labelText: 'الصف'),
              validator: (value) {
                // You can add your validation logic here
                return null;
              },
            ),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'التاريخ'),
              validator: (value) {
                // You can add your validation logic here
                return null;
              },
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'المبلغ'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال المبلغ';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _receiptNumberController,
              decoration: InputDecoration(labelText: 'رقم الإيصال'),
              validator: (value) {
                // You can add your validation logic here
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('إلغاء'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('حفظ'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final installment = {
                'studentName': _studentNameController.text,
                'class': _classController.text,
                'date': _dateController.text,
                'amount': double.tryParse(_amountController.text) ?? 0,
                'receiptNumber': _receiptNumberController.text,
              };
              Navigator.of(context).pop(installment);
            }
          },
        ),
      ],
    );
  }
}

void main() => runApp(MaterialApp(home: InstallmentsManageScreen()));
