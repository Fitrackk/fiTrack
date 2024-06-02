import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:fitrack/models/challenge_model.dart';
import 'package:fitrack/view_models/challenge_notification.dart'; // Import ChallengeNotification

class ChallengeReminderVM {
  final ChallengeNotification challengeNotification;

  ChallengeReminderVM({
    required this.challengeNotification,
  });

  Future<void> initialize() async {
    await challengeNotification.flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    tz.initializeTimeZones();
  }

  Future<void> scheduleChallengeReminders() async {
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    var snapshots = await challengeNotification.firestore
        .collection('challenges')
        .where('challengeDate', isEqualTo: tomorrowDate.toIso8601String().split('T')[0])
        .get();

    for (var doc in snapshots.docs) {
      Challenge challenge = Challenge.fromFirestore(doc);
      for (var participant in challenge.participantUsernames) {
        await scheduleDailyNotification(
          id: challenge.challengeId,
          title: 'Challenge Reminder',
          body: 'You have a challenge "${challenge.challengeName}" tomorrow!',
          startDateTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0), // Start time for the first reminder
          type: 'challenge',
          username: participant,
        );
      }
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime startDateTime,
    required String type,
    required String username,
  }) async {
    // Schedule notifications at 12 PM, 6 PM, and 12 AM
    for (int i = 0; i < 3; i++) {
      final notificationTime = startDateTime.add(Duration(hours: i * 6));
      await challengeNotification.scheduleChallengeNotification(
        id: id + i,
        title: title,
        body: body,
        dateTime: notificationTime,
        type: type,
        username: username,
      );
    }
  }
}
