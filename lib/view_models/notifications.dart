import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationViewModel {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Ensure you have an icon

    const InitializationSettings initializationSettings = InitializationSettings(
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
      tz.TZDateTime.parse(tz.local, '${dateTimeComponents['date']}T${dateTimeComponents['time']}'),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
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
      'date': scheduledDate.toIso8601String().split('T')[0], // Extracts date in YYYY-MM-DD format
      'time': scheduledDate.toIso8601String().split('T')[1]  // Extracts time in HH:MM:SS format
    };
  }

  Future<void> scheduleDailyWaterReminder() async {
    const List<Map<String, dynamic>> notifications = [
      {
        "time": Time(8, 0, 0),
        "message": "Time to drink some water and stay hydrated!",
        "type": "water"
      },
      {
        "time": Time(10, 0, 0),
        "message": "Keep it up! Stay hydrated with another glass of water.",
        "type": "water"
      },
      {
        "time": Time(12, 0, 0),
        "message": "You're doing great! Have another glass of water.",
        "type": "water"
      },
      {
        "time": Time(14, 0, 0),
        "message": "Don't forget to hydrate! Drink some water.",
        "type": "water"
      },
      {
        "time": Time(16, 0, 0),
        "message": "Keep yourself hydrated with another glass of water.",
        "type": "water"
      },
      {
        "time": Time(18, 0, 0),
        "message": "Time for a water break! Stay hydrated.",
        "type": "water"
      },
      {
        "time": Time(20, 0, 0),
        "message": "You're doing awesome! Have a glass of water.",
        "type": "water"
      },
      {
        "time": Time(22, 0, 0),
        "message": "End your day with a glass of water. Stay hydrated!",
        "type": "water"
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
