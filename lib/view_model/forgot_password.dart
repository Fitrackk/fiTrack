import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../utils/validation_utils/validation_utils.dart';

class ForgotPasswordViewModel  extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   String _emailError = '';

  Future<bool> doesEmailExist(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> userDocs = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return userDocs.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  bool validateEmail(String email) {
    if (email.isEmpty) {
      _emailError = 'Email is required';
      notifyListeners();
      return false;
    }
    if (!ValidationUtils.isValidEmail(email)) {
      _emailError = 'Invalid email format';
      notifyListeners();
      return false;
    }
    _emailError = '';
    notifyListeners();
    return true;
  }


  Future<void> resetPassword(String email) async {
    try {
      if (validateEmail(email)) {
        if (await doesEmailExist(email)) {
          await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
        } else {
          throw 'Email does not exist';
        }
      } else {
        throw 'Invalid email format';
      }
    } catch (e) {
      throw '$e';
    }
  }


}


