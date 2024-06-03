import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart' as model;

class ChangePasswordVM {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getUserProfileImageUrl() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      return model.User.fromFirestore(userDoc).profileImageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile image URL: $e');
      }
    }
    return null;
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Reauthenticate the user first to verify the old password
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: oldPassword,
        );
        await currentUser.reauthenticateWithCredential(credential);

        await currentUser.updatePassword(newPassword);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error changing password: $e');
      }
      rethrow; // Rethrow the error to be caught by the UI
    }
  }

  Future<bool> validateOldPassword(String oldPassword) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Reauthenticate the user first to verify the old password
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: oldPassword,
        );
        await currentUser.reauthenticateWithCredential(credential);
        // If reauthentication is successful, return true
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error validating old password: $e');
      }
    }
    // If reauthentication fails, return false
    return false;
  }
}
