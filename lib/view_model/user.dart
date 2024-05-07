import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/firebase_api_client.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseApiClient _firebaseApiClient = FirebaseApiClient();

  Future<User?> getUserData(String username) async {
    try {
      Map<String, dynamic> userData =
          await _firebaseApiClient.get('/users/$username');
      if (userData != null) {
        return User.fromFirestore(userData as DocumentSnapshot<Object?>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> addUser(User user) async {
    try {
      await _firebaseApiClient.post('/users/${user.username}', user.toMap());
    } catch (e) {
      print('Error adding user data: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _firebaseApiClient.put('/users/${user.username}', user.toMap());
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firebaseApiClient.delete('/users/$userId');
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }
}
