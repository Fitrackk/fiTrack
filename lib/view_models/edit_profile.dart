import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';
import '../utils/validation_utils/validation_utils.dart';

class EditProfile {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<User?> fetchUserData() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return null;

      return User.fromFirestore(userDoc);
    } catch (e) {
      print('Error fetching user data: $e`');
      return null;
    }
  }

  Future<void> updateUserData(User user) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update(user.toMap());
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  Future<String?> uploadProfileImage(String filePath) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      File file = File(filePath);
      TaskSnapshot snapshot =
          await _storage.ref('profile_images/$userId.jpg').putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  Future<bool> checkUsernameUniqueness(String username) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  Future<String?> validateFullName(String fullname) async {
    if (fullname.isEmpty) {
      return 'Full Name is required';
    }
    if (fullname.length < 2 || fullname.length > 40) {
      return 'Full name must be between 2 and 40 characters long';
    }
    return null;
  }

  Future<String?> validateHeight(String height) async {
    if (height.isEmpty) return 'Height is required';
    double? parsedHeight = double.tryParse(height);
    if (parsedHeight == null || parsedHeight < 100 || parsedHeight > 250) {
      return 'Please enter a valid height';
    }
    return null;
  }

  Future<String?> validateWeight(String weight) async {
    if (weight.isEmpty) return 'Weight is required';
    double? parsedWeight = double.tryParse(weight);
    if (parsedWeight == null || parsedWeight < 21 || parsedWeight > 200) {
      return 'Please enter a valid weight';
    }
    return null;
  }

  Future<String?> validateUserName(String username) async {
    if (username.isEmpty) return 'Username is required';
    if (username.length < 3)
      return 'Username must be at least 3 characters long';
    if (!ValidationUtils.isValidUserName(username))
      return 'Username must not contain special characters';
    User? currentUser = await fetchUserData();
    if (currentUser != null && currentUser.userName == username) {
      return null;
    }
    bool isUnique = await checkUsernameUniqueness(username);
    if (!isUnique) return 'Username is already taken';

    return null;
  }
}
