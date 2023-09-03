import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class NormalScreen extends StatelessWidget {
  final User? user;

  NormalScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? "User"; // Use a default value if displayName is null

    return Scaffold(
      appBar: AppBar(
        title: Text('Normal Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to the Normal Screen!'),
            Text('User: $displayName'), // Display user information with null check
            SizedBox(height: 20),
            QRScannerWidget(), // Add the QR code scanner widget here
          ],
        ),
      ),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Set the width to your desired size
      height: 300, // Set the height to your desired size
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text("Scan a QR code"),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Handle the scanned QR code data here
      // For example, you can print it to the console
      print("Scanned Data: ${scanData.code}");
      // You can also use the scanned data as needed, such as navigating to a specific screen.
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
