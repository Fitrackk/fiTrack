import 'package:fitrack/configures/routes.dart';
import 'package:fitrack/services/firebase_service.dart';
import 'package:fitrack/view/sign_up.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUp(),
      routes: Routes.getRoutes(context),
    );
  }
}