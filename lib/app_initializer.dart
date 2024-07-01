import 'dart:async';

import 'package:fitrack/view_models/activity_tracking.dart';
import 'package:fitrack/view_models/challenge_notification.dart';
import 'package:fitrack/view_models/challenges.dart';
import 'package:fitrack/view_models/notifications.dart';
import 'package:fitrack/view_models/water_notification.dart';

Future<void> initializeApp() async {
  final tracker = ActivityTrackerVM();
  tracker.startTracking();
  await tracker.checkLocalStorageData();
  tracker.checkStepsCount();
  final challenges = ChallengesVM();
  challenges.deleteOldChallenges();
  await tracker.deleteOldActivityData();
  WaterReminderVM notificationViewModel = WaterReminderVM();
  await notificationViewModel.initializeWaterReminder();
  ChallengeReminderVM challengesNotificationViewModel = ChallengeReminderVM();
  challengesNotificationViewModel.initializeChallengeReminder();
  final notifications = NotificationsVM();
  await notifications.deleteOldNotifications();
  Timer.periodic(const Duration(hours: 2), (Timer t) async {
    await tracker.checkLocalStorageData();
  });
}
