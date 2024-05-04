import 'package:fitrack/services/firebase_service.dart';
import 'package:fitrack/view/sign_in.dart';
import 'package:fitrack/view/user_data.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
        home: SignIn(),
    );
  }
}