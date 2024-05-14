import 'package:flutter/material.dart';
import '../views/dashboard_page.dart';
import '../views/reset_password_page.dart';
import '../views/sign_up_page.dart';
import '../views/signing_page.dart';
import '../views/user_data_page.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      '/user_data_form': (context) => const UserData(),
      '/signup': (context) => const SignUp(),
      '/dashboard': (context) => const Dashboard(),
      '/reset_password': (context) => const ResetPassword(),
      '/signing': (context) => const Signing(),
    };
  }
}
