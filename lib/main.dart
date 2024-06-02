import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:fitrack/services/firebase_service.dart';
import 'package:fitrack/utils/customs/bottom_nav.dart';
import 'package:fitrack/view_models/activity_tracking.dart';
import 'package:fitrack/view_models/challenges.dart';
import 'package:fitrack/view_models/water_reminder_logic.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:fitrack/views/get_started_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fitrack/view_models/challenge_reminder.dart'; // Import the ChallengeReminderVM
import 'package:fitrack/view_models/challenge_notification.dart'; // Import ChallengeNotification
import 'package:cloud_firestore/cloud_firestore.dart'; // Import FirebaseFirestore
import 'package:stator/stator.dart';

import 'configures/routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();

  final tracker = ActivityTrackerVM();
  tracker.startTracking();
  await tracker.checkLocalStorageData();
  tracker.checkStepsCount();

  final challenges = ChallengesVM();
  challenges.deleteOldChallenges();

  WaterReminderVM notificationViewModel = WaterReminderVM();
  await notificationViewModel.initializeWaterReminder();

  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize ChallengeNotification and ChallengeReminderVM
  final ChallengeNotification challengeNotification = ChallengeNotification(
    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    firestore: FirebaseFirestore.instance,
  );

  final ChallengeReminderVM challengeReminderVM = ChallengeReminderVM(
    challengeNotification: challengeNotification,
  );

  await challengeReminderVM.initialize();
  await challengeReminderVM.scheduleChallengeReminders();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  User? _user;
  static const platform = MethodChannel('com.company.fit/alarm_permission');

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestExactAlarmPermission();
    });
  }

  Future<void> _requestExactAlarmPermission() async {
    try {
      final bool result =
      await platform.invokeMethod('requestExactAlarmPermission');
      if (!result) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Exact alarm permission is required.')),
        );
      }
    } on PlatformException catch (e) {
      print("Failed to request exact alarm permission: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _user == null ? const StartedPage() : const BottomNav(),
      ),
      routes: Routes.getRoutes(context),
    );
  }
}
