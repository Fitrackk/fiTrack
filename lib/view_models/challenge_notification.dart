import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';

import '../models/user_model.dart';
import 'notifications.dart';

class ChallengeReminderVM {
  final UserVM _userVM = UserVM();
  final NotificationsVM _notificationVM = NotificationsVM();

  Future<void> initializeChallengeReminder() async {
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
            bool challengeReminders = user.challengeReminder == "true";

            if (challengeReminders) {
              await _notificationVM.scheduleChallengeReminders();
            } else {
              await _notificationVM.cancelUserNotifications(username, type: 'challenge');
            }
          }
        } catch (e) {
          print("Error fetching preferences: $e");
        }
      } else {
        print("Error: Username is null or empty");
      }
    } else {
      print("Error: Current user data not found");
    }
  }
}