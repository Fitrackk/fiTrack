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
  }) async {
    final scheduledDate = _nextInstanceOfTime(time);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
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

    // Store notification in Firestore
    await firestore.collection('notifications').add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate.toString(),
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

  tz.TZDateTime _nextInstanceOfTime(Time time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleDailyWaterReminder() async {
    const List<Map<String, dynamic>> notifications = [
      {
        "time": Time(8, 0, 0),
        "message": "Time to drink some water and stay hydrated!"
      },
      {
        "time": Time(10, 0, 0),
        "message": "Nothing will work unless you do."
      },
      {
        "time": Time(12, 0, 0),
        "message": "Time to drink some water and stay hydrated!"
      },
      {
        "time": Time(14, 0, 0),
        "message": "Keep pushing forward, you got this!"
      },
      {
        "time": Time(16, 0, 0),
        "message": "Time to drink some water and stay hydrated!"
      },
      {
        "time": Time(18, 0, 0),
        "message": "Believe in yourself and all that you are."
      },
      {
        "time": Time(20, 0, 0),
        "message": "Time to drink some water and stay hydrated!"
      },
      {
        "time": Time(22, 0, 0),
        "message": "End your day with a positive thought."
      }
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
      );
    }
  }
}