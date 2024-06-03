import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class NotificationsVM {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<List<QueryDocumentSnapshot>> getNotification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          String username = userDoc['username'];
          DateTime now = DateTime.now();
          DateTime increasedTime = now.add(Duration(hours: 1));
          DateFormat dateFormat = DateFormat("HH:mm:ss.SSS'Z'");
          String formattedCurrentTime = dateFormat.format(increasedTime);
          if (kDebugMode) {
            print("Formatted Current Time: $formattedCurrentTime");
          }

          var querySnapshot = await FirebaseFirestore.instance
              .collection('notifications')
              .where('username', isEqualTo: username)
              .where('scheduledTime', isLessThanOrEqualTo: formattedCurrentTime)
              .get();

          DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
          var filteredDocs = querySnapshot.docs.where((doc) {
            String scheduledTimeString = doc['scheduledTime'];
            // print("Scheduled Time String: $scheduledTimeString");
            DateFormat format = DateFormat("HH:mm:ss.SSS'Z'");
            DateTime scheduledTime = format.parse(scheduledTimeString);

            DateTime scheduledDate = DateTime.parse(doc['scheduledDate']);
            return scheduledDate.isAfter(sevenDaysAgo) && scheduledDate.isBefore(now) && scheduledTime.isBefore(increasedTime);
          }).toList();

          filteredDocs.sort((a, b) {
            DateTime aTime = DateFormat("HH:mm:ss.SSS'Z'").parse(a['scheduledTime']);
            DateTime bTime = DateFormat("HH:mm:ss.SSS'Z'").parse(b['scheduledTime']);
            return bTime.compareTo(aTime);
          });

          return filteredDocs;
        } else {
          throw Exception("User document does not exist.");
        }
      } else {
        throw Exception("No user is currently logged in.");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      rethrow;
    }
  }
}