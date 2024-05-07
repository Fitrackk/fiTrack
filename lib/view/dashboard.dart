import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:flutter/material.dart';

import '../configures/text_style.dart';

//sample
class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitColors.background,
      child: FutureBuilder<Map<String, dynamic>?>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final userData = snapshot.data;
            return displayUserData(userData ?? {});
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return userDoc.data();
    }
    return null;
  }

  Widget displayUserData(Map<String, dynamic> userData) {
    if (userData.isNotEmpty) {
      final String username = userData['username'];
      final String email = userData['email'];

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, $username!',
            style: TextStyles.headlineMedium.copyWith(
              color: FitColors.text20,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Email: $email',
            style: TextStyles.labelLarge.copyWith(
              color: FitColors.text20,
            ),
          ),
        ],
      );
    } else {
      return const Text('User data not found.');
    }
  }
}
