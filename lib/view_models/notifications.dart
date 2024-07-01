import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
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

    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling notification: $e');
      }
    }
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
    try {
      await firestore.collection('notifications').add({
        'id': id,
        'title': title,
        'body': body,
        'scheduledDate': scheduledDate,
        'scheduledTime': scheduledTime,
        'type': type,
        'username': username,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding notification to Firestore: $e');
      }
    }
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
      try {
        await flutterLocalNotificationsPlugin.cancel(doc['id']);
        await doc.reference.delete();
      } catch (e) {
        if (kDebugMode) {
          print('Error cancelling notification: $e');
        }
      }
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

  Future<bool> notificationsExistForUserAndDate(
      String username, String date, String type) async {
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
    DateTime now = DateTime.now();
    final today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    bool notificationsExist =
        await notificationsExistForUserAndDate(username, today, 'water');
    if (notificationsExist) {
      if (kDebugMode) {
        print("Today's notifications already exist for user: $username");
      }
      return;
    }
    if (currentUser?.waterReminder == "false") return;

    List<Map<String, dynamic>> notifications = [
      {
        "time": const Time(5, 0, 0),
        "message": "Time to drink some water and stay hydrated!",
        "type": "water",
        "username": username
      },
      {
        "time": const Time(7, 0, 0),
        "message": "Keep it up! Stay hydrated with a glass of water.",
        "type": "water",
        "username": username
      },
      {
        "time": const Time(9, 0, 0),
        "message": "You're doing great! Have another glass of water.",
        "type": "water",
        "username": username
      },
      {
        "time": const Time(11, 0, 0),
        "message": "Don't forget to hydrate! Drink some water.",
        "type": "water",
        "username": username
      },
      {
        "time": const Time(13, 0, 0),
        "message": "Keep yourself hydrated with another glass of water.",
        "type": "water",
        "username": username
      },
      {
        "time": const Time(15, 0, 0),
        "message": "Time for a water break! Stay hydrated.",
        "type": "water",
        "username": username
      },
      {
        "time": const Time(17, 0, 0),
        "message": "You're doing awesome! Have a glass of water.",
        "type": "water",
        "username": username
      },
      {
        "time": const Time(19, 0, 0),
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
    User? currentUser = await _userVM.getUserData();
    String username = currentUser?.userName ?? 'unknown';
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowDateString =
        "${tomorrow.year}-${_twoDigits(tomorrow.month)}-${_twoDigits(tomorrow.day)}";

    var snapshots = await firestore
        .collection('challenges')
        .where('challengeDate', isEqualTo: tomorrowDateString)
        .where('reminder', isEqualTo: 'true')
        .get();

    for (var doc in snapshots.docs) {
      var challenge = doc.data();
      for (var participant in challenge['participantUsernames']) {
        if (participant == username) {
          String challengeName = challenge['challengeName'];
          String activityType = challenge['activityType'];
          DateTime challengeDate = DateTime.parse(challenge['challengeDate']);

          bool notificationsExist = await notificationsExistForUserAndDate(
              username, tomorrowDateString, 'challenge');
          if (notificationsExist) {
            if (kDebugMode) {
              print(
                  "Challenge notifications already exist for user: $participant on $tomorrowDateString");
            }
            continue;
          }
          if (currentUser?.challengeReminder == "false") return;

          List<Map<String, dynamic>> notifications = [
            {
              "time": DateTime(challengeDate.year, challengeDate.month,
                  challengeDate.day, 0 - 3, 0, 0),
              "message":
                  "Midnight reminder: Your $challengeName challenge is tomorrow!",
              "type": "challenge",
              "username": username
            },
            {
              "time": DateTime(challengeDate.year, challengeDate.month,
                  challengeDate.day, 6 - 3, 0, 0),
              "message":
                  "Good morning! Get ready for your $challengeName challenge today. Make sure you're prepared for a session of $activityType.",
              "type": "challenge",
              "username": username
            },
            {
              "time": DateTime(challengeDate.year, challengeDate.month,
                  challengeDate.day, 12 - 3, 0, 0),
              "message":
                  "Don't forget! Your $challengeName challenge is this afternoon. Keep up the motivation!",
              "type": "challenge",
              "username": username
            },
            {
              "time": DateTime(challengeDate.year, challengeDate.month,
                  challengeDate.day, 18 - 3, 0, 0),
              "message":
                  "Evening reminder: Your $challengeName challenge is coming up soon. Get ready!",
              "type": "challenge",
              "username": username
            },
          ];

          for (var i = 0; i < notifications.length; i++) {
            final notification = notifications[i];
            final notificationId =
                "${challenge['challengeId']}_${notification['type']}_$i"
                    .hashCode;
            await scheduleDailyNotification(
              id: notificationId,
              title: 'Challenge Reminder',
              body: notification['message'],
              time:
                  Time(notification['time'].hour, notification['time'].minute),
              type: notification['type'],
              username: notification['username'],
            );
          }
        }
      }
    }
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  Future<void> deleteOldNotifications() async {
    try {
      final now = DateTime.now();
      final cutoffDate = now.subtract(const Duration(days: 7));
      final dateFormat = DateFormat('yyyy-MM-dd');

      QuerySnapshot notificationSnapshot =
          await firestore.collection('notifications').get();

      for (var doc in notificationSnapshot.docs) {
        String dateString = doc['scheduledDate'];
        DateTime date;

        try {
          date = dateFormat.parse(dateString);
        } catch (e) {
          if (kDebugMode) {
            print(
                'Error parsing date for document ID: ${doc.id}, date string: $dateString');
          }
          continue;
        }

        if (date.isBefore(cutoffDate)) {
          await firestore.collection('notifications').doc(doc.id).delete();
          if (kDebugMode) {
            print('Deleted notification data for document ID: ${doc.id}');
          }
        }
      }

      if (kDebugMode) {
        print('Old notification data deletion completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting old notification data: $e');
      }
    }
  }
}
