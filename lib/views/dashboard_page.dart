import 'package:flutter/material.dart';

import '../configures/color_theme.dart';
import '../configures/text_style.dart';
import '../models/user_model.dart';
import '../view_models/user.dart';

//sample page
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<User?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = UserVM().getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitColors.background,
      child: FutureBuilder<User?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final user = snapshot.data;
            return displayUserData(user);
          }
        },
      ),
    );
  }

  Widget displayUserData(User? user) {
    if (user != null) {
      final String? username = user.userName;
      final String? email = user.email;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, $username!',
            style: TextStyles.headlineMedium.copyWith(
              color: FitColors.text20,
            ),
          ),
          const SizedBox(height: 10),
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
