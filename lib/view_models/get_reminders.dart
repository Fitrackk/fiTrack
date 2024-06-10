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
          DateTime increasedTime = now.add(const Duration(hours: 1));
          DateFormat dateFormat = DateFormat("HH:mm:ss.SSS");
          String formattedCurrentTime = dateFormat.format(increasedTime);

          var querySnapshot = await FirebaseFirestore.instance
              .collection('notifications')
              .where('username', isEqualTo: username)
              .where('scheduledTime', isLessThanOrEqualTo: formattedCurrentTime)
              .get();

          DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
          var filteredDocs = querySnapshot.docs.where((doc) {
            String scheduledTimeString = doc['scheduledTime'];
            DateFormat format = DateFormat("HH:mm:ss.SSS");
            DateTime scheduledTime = format.parse(scheduledTimeString);

            DateTime scheduledDate = DateTime.parse(doc['scheduledDate']);
            return scheduledDate.isAfter(sevenDaysAgo) &&
                scheduledDate.isBefore(now) &&
                scheduledTime.isBefore(increasedTime);
          }).toList();

          filteredDocs.sort((a, b) {
            DateTime aDate = DateTime.parse(a['scheduledDate']);
            DateTime bDate = DateTime.parse(b['scheduledDate']);
            return bDate.compareTo(aDate);
          });

          return filteredDocs;
        } else {
          throw Exception("User document does not exist.");
        }
      } else {
        throw Exception("No user is currently logged in.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching notifications: $e");
      }
      rethrow;
    }
  }
}
