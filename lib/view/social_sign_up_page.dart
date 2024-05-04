import 'package:fitrack/view_model/registration.dart'; // Import the view model
import 'package:flutter/material.dart';

class SocialSignUpPage extends StatelessWidget {
  final Registration viewModel = Registration();

  SocialSignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await viewModel.signInWithGoogle(context);
              },
              child: const Text('Sign Up with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
