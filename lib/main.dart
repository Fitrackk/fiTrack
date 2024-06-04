import 'dart:async';

import 'package:fitrack/services/firebase_service.dart';
import 'package:fitrack/utils/customs/bottom_nav.dart';
import 'package:fitrack/view_models/activity_tracking.dart';
import 'package:fitrack/view_models/challenges.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:fitrack/view_models/user_state.dart';
import 'package:fitrack/views/get_started_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stator/stator.dart';

import 'app_initializer.dart';
import 'configures/routes.dart';
import 'models/user_state.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  UserState? _userState;
  static const platform = MethodChannel('com.company.fit/alarm_permission');

  @override
  void initState() {
    super.initState();
    registerSingleton(UserVM());
    registerSingleton(ChallengesVM());
    registerSingleton(ActivityTrackerVM());

    _checkUserState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestExactAlarmPermission();
    });
  }

  Future<void> _checkUserState() async {
    UserState? state = await getUserState();
    setState(() {
      _userState = state;
    });
  }

  Future<void> _requestExactAlarmPermission() async {
    try {
      final bool result =
          await platform.invokeMethod('requestExactAlarmPermission');
      if (!result) {
        print('Exact alarm permission is required.');
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
        body: _userState == UserState.signedOut
            ? const StartedPage()
            : const BottomNav(),
      ),
      routes: Routes.getRoutes(context),
    );
  }
}
