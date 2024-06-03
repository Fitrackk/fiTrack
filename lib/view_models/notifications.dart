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
          channelDescription: 'fitrack : challenges community & reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await _addNotificationToFirestore(
      id: id,
      title: title,
      body: body,
      scheduledDate: dateTimeComponents['date'],
      scheduledTime: dateTimeComponents['time'],
      type: type,
      username: username,
    );
  }

  Future<void> _addNotificationToFirestore({
    required int id,
    required String title,
    required String body,
    required String scheduledDate,
    required String scheduledTime,
    required String type,
    required String username,
  }) async {
    await firestore.collection('notifications').add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'type': type,
      'username': username,
    });
  }

  Future<void> cancelUserNotifications(String username, {String? type}) async {
    var query = firestore
        .collection('notifications')
        .where('username', isEqualTo: username);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    var snapshots = await query.get();
    for (var doc in snapshots.docs) {
      await flutterLocalNotificationsPlugin.cancel(doc['id']);
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
      'date': scheduledDate.toIso8601String().split('T')[0],
      'time': scheduledDate.toIso8601String().split('T')[1]
    };
  }

  Future<bool> notificationsExistForUserAndDate(String username, String date, String type) async {
    var snapshots = await firestore
        .collection('notifications')
        .where('username', isEqualTo: username)
        .where('scheduledDate', isEqualTo: date)
        .where('type', isEqualTo: type)
        .get();

    return snapshots.docs.isNotEmpty;
  }

  Future<void> scheduleDailyWaterReminder() async {
    User? currentUser = await _userVM.getUserData();
    String username = currentUser?.userName ?? 'unknown';

    bool notificationsExist = await notificationsExistForUserAndDate(username, tz.TZDateTime.now(tz.local).toIso8601String().split('T')[0], 'water');
    if (notificationsExist) {
      print("Today's notifications already exist for user: $username");
      return;
    }
    if (currentUser?.waterReminder == "false") return;

    List<Map<String, dynamic>> notifications = [
      {
        "time": Time(5, 0, 0),
        "message": "Time to drink some water and stay hydrated!",
        "type": "water",
        "username": username
      },
      {
        "time": Time(7, 0, 0),
        "message": "Keep it up! Stay hydrated with a glass of water.",
        "type": "water",
        "username": username
      },
      {
        "time": Time(9, 0, 0),
        "message": "You're doing great! Have another glass of water.",
        "type": "water",
        "username": username
      },
      {
        "time": Time(11, 0, 0),
        "message": "Don't forget to hydrate! Drink some water.",
        "type": "water",
        "username": username
      },
      {
        "time": Time(13, 0, 0),
        "message": "Keep yourself hydrated with another glass of water.",
        "type": "water",
        "username": username
      },
      {
        "time": Time(15, 0, 0),
        "message": "Time for a water break! Stay hydrated.",
        "type": "water",
        "username": username
      },
      {
        "time": Time(17, 0, 0),
        "message": "You're doing awesome! Have a glass of water.",
        "type": "water",
        "username": username
      },
      {
        "time": Time(19, 0, 0),
        "message": "End your day with a glass of water. Stay hydrated!",
        "type": "water",
        "username": username
      },
    ];

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

  Future<void> scheduleChallengeReminders() async {
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowDateString = "${tomorrow.year}-${_twoDigits(tomorrow.month)}-${_twoDigits(tomorrow.day)}";

    var snapshots = await firestore
        .collection('challenges')
        .where('challengeDate', isEqualTo: tomorrowDateString)
        .where('reminder', isEqualTo: 'true')
        .get();

    for (var doc in snapshots.docs) {
      var challenge = doc.data();
      for (var participant in challenge['participantUsernames']) {
        bool notificationsExist = await notificationsExistForUserAndDate(participant, tomorrowDateString, 'challenge');
        if (notificationsExist) {
          print("Challenge notifications already exist for user: $participant on $tomorrowDateString");
          continue;
        }

        List<Map<String, dynamic>> notifications = [
          {
            "time": DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0),
            "message": "Get ready for your challenge at 12 PM!",
            "type": "challenge",
            "username": participant
          },
          {
            "time": DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18, 0),
            "message": "Don't forget your challenge at 6 PM!",
            "type": "challenge",
            "username": participant
          },
          {
            "time": DateTime(tomorrow.year, tomorrow.month, tomorrow.day + 1, 0, 0),
            "message": "Midnight reminder for your challenge!",
            "type": "challenge",
            "username": participant
          },
          {
            "time": DateTime(tomorrow.year, tomorrow.month, tomorrow.day + 1, 6, 0),
            "message": "Early morning reminder for your challenge!",
            "type": "challenge",
            "username": participant
          },
        ];

        for (var i = 0; i < notifications.length; i++) {
          final notification = notifications[i];
          await scheduleDailyNotification(
            id: challenge['challengeId'] * 100 + i,
            title: 'Challenge Reminder',
            body: notification['message'],
            time: Time(notification['time'].hour, notification['time'].minute),
            type: notification['type'],
            username: notification['username'],
          );

          await _addNotificationToFirestore(
            id: challenge['challengeId'] * 100 + i,
            title: 'Challenge Reminder',
            body: notification['message'],
            scheduledDate: notification['time'].toIso8601String().split('T')[0],
            scheduledTime: notification['time'].toIso8601String().split('T')[1],
            type: notification['type'],
            username: notification['username'],
          );
        }
      }
    }
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
