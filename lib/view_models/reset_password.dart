import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../utils/validation_utils/validation_utils.dart';

class ResetPasswordVM extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _emailError = '';
  String _successMessage = '';

  String get emailError => _emailError;

  String get successMessage => _successMessage;

  void clearErrors() {
    _emailError = '';
    _successMessage = '';
    notifyListeners();
  }

  Future<void> resetPasswordWithEmail(String email) async {
    try {
      if (email.isEmpty) {
        _emailError = 'Email is required';
        notifyListeners();
        return;
      } else if (!ValidationUtils.isValidEmail(email)) {
        _emailError = 'Invalid email format';
        notifyListeners();
        return;
      }

      QuerySnapshot<Map<String, dynamic>> userDocs = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userDocs.docs.isEmpty) {
        _emailError = 'Email does not exist';
        notifyListeners();
        return;
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      _successMessage = 'Password reset email has been sent';
      notifyListeners();
    } catch (e) {
      _emailError = 'Error: $e';
      notifyListeners();
    }
  }
}
