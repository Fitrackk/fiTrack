import 'package:fitrack/view/sign_up.dart';
import 'package:fitrack/view/user_data.dart';
import 'package:flutter/material.dart';

import '../view/forgot_password.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      '/user_data_form': (context) => UserData(),
      // '/signin': (context) =>  SignIn();
      '/signup': (context) => SignUp(),
      '/rest_password' : (context) => ForgotPasswordView()
    };
  }
}
