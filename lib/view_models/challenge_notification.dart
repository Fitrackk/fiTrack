import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ChallengeNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseFirestore firestore;

  ChallengeNotification({
    required this.flutterLocalNotificationsPlugin,
    required this.firestore,
  });

  Future<void> scheduleChallengeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required String type,
    required String username,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fitrack',
          'fitrack',
          channelDescription: 'fitrack : challenges community & reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

    await firestore.collection('notifications').add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toIso8601String(),
      'type': type,
      'username': username,
    });
  }
}
