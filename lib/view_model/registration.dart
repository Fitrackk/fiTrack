import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitrack/utils/validation_utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Registration extends ChangeNotifier {
  String _emailError = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  String get emailError => _emailError;

  String get passwordError => _passwordError;

  String get confirmPasswordError => _confirmPasswordError;

  bool validateEmail(String email) {
    if (!ValidationUtils.isValidEmail(email)) {
      _emailError = 'Invalid email format';
      notifyListeners();
      return false;
    }
    _emailError = '';
    notifyListeners();
    return true;
  }

  bool validatePassword(String password) {
    if (!ValidationUtils.isValidPassword(password)) {
      _passwordError = 'Password must be at least 8 characters long';
      notifyListeners();
      return false;
    }
    _passwordError = '';
    notifyListeners();
    return true;
  }

  bool validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword != password) {
      _confirmPasswordError = 'Passwords do not match';
      notifyListeners();
      return false;
    } else if (!ValidationUtils.isValidPassword(confirmPassword)) {
      _confirmPasswordError = 'Password must be at least 8 characters long';
      notifyListeners();
      return false;
    }
    _confirmPasswordError = '';
    notifyListeners();
    return true;
  }

  void validateAndCreateUser(BuildContext context, String email,
      String password, String confirmPassword, String fullName) {
    if (validateEmail(email) &&
        validatePassword(password) &&
        validateConfirmPassword(confirmPassword, password)) {
      _createUserInAuthentication(context, email, password);
    }
  }

  void _createUserInAuthentication(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        Navigator.pushNamed(context, '/user_data_form');
      }
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          Navigator.pushNamed(context, '/user_data_form');
        }
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }
}
