import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
          options: FirebaseOptionsProvider.firebaseOptions);
      log("Firebase initialized successfully");
    } catch (e) {
      log("Error initializing Firebase: $e");
    }
  }
}
