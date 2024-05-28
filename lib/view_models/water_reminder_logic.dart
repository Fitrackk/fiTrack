import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';

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

      try {
        DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        await FirebaseFirestore.instance
            .collection("preference")
            .doc(username)
            .get();

        if (docSnapshot.exists) {
          bool waterReminders = docSnapshot.data()?['waterReminders'] == "true";

          if (waterReminders) {
            await _notificationVM.scheduleDailyWaterReminder();
          } else {
            // Cancel existing notifications if water reminders are disabled
            await _notificationVM.cancelUserNotifications(username!);
          }
        } else {
          print("Error: Preference document does not exist");
        }
      } catch (e) {
        print("Error fetching preferences: $e");
      }
    } else {
      print("Error: Current user data not found");
    }
  }
}