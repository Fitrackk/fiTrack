import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitrack/services/firebase_service.dart';
import 'package:fitrack/utils/customs/bottom_nav.dart';
import 'package:fitrack/view_models/activity_tracking.dart';
import 'package:fitrack/view_models/challenges.dart';
import 'package:fitrack/view_models/notifications.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:fitrack/views/get_started_page.dart';
import 'package:flutter/material.dart';
import 'package:stator/stator.dart';

import 'configures/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  final tracker = ActivityTrackerViewModel();
  tracker.startTracking();
  await tracker.checkLocalStorageData();
  //tracker.stopTracking();

  NotificationViewModel notificationViewModel = NotificationViewModel();
  await notificationViewModel.initialize();
  await notificationViewModel.scheduleDailyWaterReminder();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    registerSingleton(UserVM());
    registerSingleton(ChallengesVM());
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
