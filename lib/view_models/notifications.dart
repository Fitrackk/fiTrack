import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/user_model.dart';

class NotificationsVM {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserVM _userVM = UserVM();
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required Time time,
    required String type,
    required String username,
  }) async {
    final dateTimeComponents = _nextInstanceOfTime(time);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.parse(tz.local,
          '${dateTimeComponents['date']}T${dateTimeComponents['time']}'),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fitrack',
          'fitrack',
          channelDescription: 'water & challenges reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await firestore.collection('notifications').add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': dateTimeComponents['date'],
      'scheduledTime': dateTimeComponents['time'],
      'type': type,
      'username': username,
    });
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();

    // Optionally, clear the notifications collection in Firestore
    var snapshots = await firestore.collection('notifications').get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Map<String, dynamic> _nextInstanceOfTime(Time time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return {
      'date': scheduledDate
          .toIso8601String()
          .split('T')[0], // Extracts date in YYYY-MM-DD format
      'time': scheduledDate
          .toIso8601String()
          .split('T')[1] // Extracts time in HH:MM:SS format
    };
  }

  Future<void> scheduleDailyWaterReminder() async {
    User? currentUser = await _userVM.getUserData();

    List<Map<String, dynamic>> notifications = [
      {
        "time": Time(5, 0, 0),
        "message": "Time to drink some water and stay hydrated!",
        "type": "water",
        "username": currentUser?.userName ?? 'unknown'
      },
      {
        "time": Time(7, 0, 0),
        "message": "Keep it up! Stay hydrated with a glass of water.",
        "type": "water",
        "username": currentUser?.userName ?? 'unknown'
      },
      {
        "time": Time(9, 0, 0),
        "message": "You're doing great! Have another glass of water.",
        "type": "water",
        "username": currentUser?.userName ?? 'unknown'
      },
      {
        "time": Time(11, 0, 0),
        "message": "Don't forget to hydrate! Drink some water.",
        "type": "water",
        "username": currentUser?.userName ?? 'unknown'
      },
      {
        "time": Time(13, 0, 0),
        "message": "Keep yourself hydrated with another glass of water.",
        "type": "water",
        "username": currentUser?.userName ?? 'unknown'
      },
      {
        "time": Time(15, 0, 0),
        "message": "Time for a water break! Stay hydrated.",
        "type": "water",
        "username": currentUser?.userName ?? 'unknown'
      },
      {
        "time": Time(17, 0, 0),
        "message": "You're doing awesome! Have a glass of water.",
        "type": "water",
        "username": currentUser?.userName ?? 'unknown'
      },
      {
        "time": Time(19, 0, 0),
        "message": "End your day with a glass of water. Stay hydrated!",
        "type": "water",
        "username": currentUser?.userName ?? 'unknown'
      },
    ];

    // Cancel any existing notifications
    await cancelAllNotifications();

    for (var i = 0; i < notifications.length; i++) {
      final notification = notifications[i];
      await scheduleDailyNotification(
        id: i,
        title: 'Reminder',
        body: notification['message'],
        time: notification['time'],
        type: notification['type'],
        username: notification['username'],
      );
    }
  }
}
