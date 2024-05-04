import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordViewModel {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      rethrow;
    }
  }
}
