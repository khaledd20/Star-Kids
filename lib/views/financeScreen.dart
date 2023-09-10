import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceScreen extends StatefulWidget {
  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Screen'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final students = snapshot.data!.docs;
          return Column(
            children: [
              Expanded(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Class')),
                    DataColumn(label: Text('Paid')),
                    DataColumn(label: Text('Left')),
                  ],
                  rows: students.map((studentDoc) {
                    final studentData = studentDoc.data() as Map<String, dynamic>;
                    final studentName = studentData['name'] ?? 'Unknown';
                    final studentClass = studentData['class'] ?? 'Unknown';
                    int paidAmount = studentData['paid'] ?? 0;
                    int leftAmount = studentData['left'] ?? 0;

                    return DataRow(
                      cells: [
                        DataCell(Text(studentName)),
                        DataCell(Text(studentClass)),
                        DataCell(
                          TextFormField(
                            initialValue: paidAmount.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                paidAmount = int.tryParse(value) ?? 0;
                              });
                              // Update Firestore with the new paidAmount value
                              _firestore.collection('Students').doc(studentDoc.id).update({'paid': paidAmount});
                            },
                          ),
                        ),
                        DataCell(
                          TextFormField(
                            initialValue: leftAmount.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                leftAmount = int.tryParse(value) ?? 0;
                              });
                              // Update Firestore with the new leftAmount value
                              _firestore.collection('Students').doc(studentDoc.id).update({'left': leftAmount});
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              // Total paid and total left
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Paid: ${calculateTotalPaid(students)}'),
                    Text('Total Left: ${calculateTotalLeft(students)}'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double calculateTotalPaid(List<DocumentSnapshot> students) {
    double totalPaid = 0;
    for (final studentDoc in students) {
      final studentData = studentDoc.data() as Map<String, dynamic>;
      final paidAmount = studentData['paid'] ?? 0;
      totalPaid += paidAmount;
    }
    return totalPaid;
  }

  double calculateTotalLeft(List<DocumentSnapshot> students) {
    double totalLeft = 0;
    for (final studentDoc in students) {
      final studentData = studentDoc.data() as Map<String, dynamic>;
      final leftAmount = studentData['left'] ?? 0;
      totalLeft += leftAmount;
    }
    return totalLeft;
  }
}

void main() {
  runApp(MaterialApp(
    home: FinanceScreen(),
  ));
}
