import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    try {
      FirebaseOptions firebaseOptions = const FirebaseOptions(
          apiKey: "AIzaSyAv3KeYMGVRgqKbbiQ3jIPHbLWlUYJ8KoY",
          databaseURL:
              "https://console.firebase.google.com/u/0/project/fitrack-7ee93/firestore/databases/-default-/data/~2F",
          appId: "fitrack-7ee93",
          messagingSenderId: '651826951315',
          projectId: 'fitrack-7ee93');

      await Firebase.initializeApp(options: firebaseOptions);
      log("Firebase initialized successfully");
    } catch (e) {
      log("Error initializing Firebase: $e");
    }
  }
}
