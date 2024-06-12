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
          DateTime adjustedNow = now.subtract(const Duration(hours: 3));

          var querySnapshot = await FirebaseFirestore.instance
              .collection('notifications')
              .where('username', isEqualTo: username)
              .get();

          List<QueryDocumentSnapshot> filteredDocs =
              querySnapshot.docs.where((doc) {
            DateTime scheduledDateTime = DateFormat("yyyy-MM-ddTHH:mm:ss")
                .parse(doc['scheduledDate'] + 'T' + doc['scheduledTime']);
            return scheduledDateTime.isBefore(adjustedNow);
          }).toList();

          filteredDocs.sort((a, b) {
            DateTime aDateTime = DateFormat("yyyy-MM-ddTHH:mm:ss")
                .parse(a['scheduledDate'] + 'T' + a['scheduledTime']);
            DateTime bDateTime = DateFormat("yyyy-MM-ddTHH:mm:ss")
                .parse(b['scheduledDate'] + 'T' + b['scheduledTime']);
            return bDateTime.compareTo(aDateTime);
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
