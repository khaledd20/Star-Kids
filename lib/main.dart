import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'views/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDwuf4ASxGVHQDpJYG8Nba2NhMXlLXHvk0",
      appId: "1:35723641214:android:30a76da5798922bf5b332f",
      messagingSenderId: "35723641214",
      projectId: "star-kids-c24da",
    ),
  );

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      title: 'star kids',
      theme: ThemeData(
        useMaterial3: true,
        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 183, 189, 0),
          brightness: Brightness.dark,
        ),
        // Define the default `TextTheme`.
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: screenWidth >= 600 ? 72 : 48, // Adjust font size for larger screens
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.oswald(
            fontSize: screenWidth >= 600 ? 30 : 20, // Adjust font size for larger screens
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      builder: EasyLoading.init(), // تهيئة EasyLoading
      home: LoginScreen(),
    );
  }
}
