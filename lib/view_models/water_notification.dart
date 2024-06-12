import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'notifications.dart';

class WaterReminderVM {
  final UserVM _userVM = UserVM();
  final NotificationsVM _notificationVM = NotificationsVM();

  Future<void> initializeWaterReminder() async {
    await _notificationVM.initialize();

    User? currentUser = await _userVM.getUserData();
    if (currentUser != null) {
      String? username = currentUser.userName;
      if (username != null && username.isNotEmpty) {
        try {
          QuerySnapshot docSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .get();
          for (var userDoc in docSnapshot.docs) {
            User user = User.fromFirestore(userDoc);
            bool waterReminders = user.waterReminder == "true";

            if (waterReminders) {
              await _notificationVM.scheduleDailyWaterReminder();
            } else {
              await _notificationVM.cancelUserNotifications(username,
                  type: 'water');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error fetching preferences: $e");
          }
        }
      } else {
        if (kDebugMode) {
          print("Error: Username is null or empty");
        }
      }
    } else {
      if (kDebugMode) {
        print("Current user data not found");
      }
    }
  }
}
