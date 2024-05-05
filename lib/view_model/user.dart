import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/firebase_api_client.dart';

class UserVM extends ChangeNotifier {
  final FirebaseApiClient _firebaseApiClient = FirebaseApiClient();

  Future<User?> getUserData(String username) async {
    try {
      Map<String, dynamic> userData =
          await _firebaseApiClient.get('/users/$username');
      if (userData.isNotEmpty) {
        return User.fromFirestore(userData as DocumentSnapshot<Object?>);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      return null;
    }
  }

  Future<void> addUser(User user) async {
    try {
      await _firebaseApiClient.post('/users/${user.username}', user.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding user data: $e');
      }
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _firebaseApiClient.put('/users/${user.username}', user.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user data: $e');
      }
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firebaseApiClient.delete('/users/$userId');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user data: $e');
      }
    }
  }
}
