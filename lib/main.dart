import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/configures/routes.dart';
import 'package:fitrack/services/firebase_service.dart';
import 'package:fitrack/utils/customs/bottom_nav.dart';
import 'package:fitrack/view_models/challenges.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:fitrack/views/dashboard_page.dart';
import 'package:fitrack/views/sign_up_page.dart';
import 'package:fitrack/views/signing_page.dart';
import 'package:flutter/material.dart';
import 'package:stator/stator.dart';

import 'models/challenge_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    registerSingleton(UserVM());
    registerSingleton(ChallengesVM());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Signing(),
      routes: Routes.getRoutes(context),
    );
  }
}
