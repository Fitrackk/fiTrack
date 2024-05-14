import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_state.dart';

Future<UserState?> getUserState() async {
  if (FirebaseAuth.instance.currentUser == null) {
    return UserState.signedOut;
  } else {
    final exists = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (exists.data() == null) {
      return UserState.signedIn;
    }
  }
  return null;
}
