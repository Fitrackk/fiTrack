import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
// import '../models/user_model.dart';


class NotificationsVm {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<QuerySnapshot<Object?>> getNotification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          String username = userDoc['username'];
          var query = await FirebaseFirestore.instance
              .collection('notifications')
              .where('username', isEqualTo: username)
              .get();

          return query as QuerySnapshot;
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