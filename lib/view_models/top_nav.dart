import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class TopNavViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      final auth.User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }
}
