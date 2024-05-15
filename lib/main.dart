import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitrack/services/firebase_service.dart';
import 'package:fitrack/views/dashboard_page.dart';
import 'package:fitrack/views/get_started_page.dart';
// import 'package:fitrack/services/firebase_service.dart';
import 'package:fitrack/utils/customs/bottom_nav.dart';
import 'package:flutter/material.dart';

import 'configures/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _user == null ? const StartedPage() : const BottomNav(),
      routes: Routes.getRoutes(context),
    );
  }
}
