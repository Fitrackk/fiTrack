import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInVM extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  set errorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> signIn(
      BuildContext context, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Email and password cannot be empty';
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (userDoc.exists) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/user_data_form');
      }
    } on FirebaseAuthException {
      errorMessage = 'Incorrect email or password';
    }
  }
}
