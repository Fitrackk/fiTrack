import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart' as models;

class UserVM extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<models.User?> getUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          return models.User.fromFirestore(userDoc);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      return null;
    }
  }

  Future<void> addUser(models.User user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set(user.toMap());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding user data: $e');
      }
    }
  }

  Future<void> updateUser(models.User user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update(user.toMap());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user data: $e');
      }
    }
  }

  Future<void> deleteUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user data: $e');
      }
    }
  }

  Future<models.User?> getUserByUsername(String username) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return models.User?.fromFirestore(querySnapshot.docs.first);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user by username: $e');
      }
      return null;
    }
  }
}
