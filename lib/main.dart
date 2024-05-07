import 'package:fitrack/configures/routes.dart';
import 'package:fitrack/services/firebase_service.dart';
import 'package:fitrack/views/sign_up_page.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SignUp(),
      routes: Routes.getRoutes(context),
    );
  }
}
