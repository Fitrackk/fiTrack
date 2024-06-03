import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_state.dart';

Future<UserState?> getUserState() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return UserState.signedOut;
  } else {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      return UserState.signedIn;
    } else {
      return UserState.signedOut;
    }
  }
}
