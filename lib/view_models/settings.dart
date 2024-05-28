import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart' as model;

class SettingsVM extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  model.User? _user;

  model.User? get user => _user;

  Future<void> fetchUserData() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return;
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        _user = model.User.fromFirestore(userDoc);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user profile : $e');
    }
  }

  int calculateUserLevel(double userScore) {
    return ((userScore / 100) + 1).toInt();
  }

  Future<void> updateChallengeReminder(bool value) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return;
      await _firestore.collection('users').doc(userId).update({
        'challengeReminder': value.toString(),
      });
      _user?.challengeReminder = value.toString();
      notifyListeners();
    } catch (e) {
      print('Error updating challenge reminder: $e');
    }
  }

  Future<void> updateWaterReminder(bool value) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return;
      await _firestore.collection('users').doc(userId).update({
        'waterReminder': value.toString(),
      });
      _user?.waterReminder = value.toString();
      notifyListeners();
    } catch (e) {
      print('Error updating water reminder: $e');
    }
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
