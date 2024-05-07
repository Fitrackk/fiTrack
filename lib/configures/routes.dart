import 'package:fitrack/view/dashboard.dart';
import 'package:fitrack/view/user_data.dart';
import 'package:flutter/material.dart';
import 'package:fitrack/view/sign_in.dart';
import 'package:fitrack/view/user_data.dart';
import 'package:flutter/material.dart';

import '../view/forgot_password.dart';
import '../view/sign_up.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      '/user_data_form': (context) => const UserData(),
      '/signup': (context) => const SignUp(),
      '/dashboard': (context) => const Dashboard(),
      '/rest_password' : (context) => ForgotPasswordView()
      '/signin': (context) => SignIn(),
    };
  }
}