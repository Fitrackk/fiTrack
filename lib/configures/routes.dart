import 'package:fitrack/utils/customs/bottom_nav.dart';
import 'package:fitrack/views/challenges_page.dart';
import 'package:fitrack/views/notifications.dart';
import 'package:fitrack/views/profile_editing.dart';
import 'package:fitrack/views/reset_password_page.dart';
import 'package:fitrack/views/sign_up_page.dart';
import 'package:fitrack/views/signing_page.dart';
import 'package:fitrack/views/user_data_page.dart';
import 'package:flutter/material.dart';

import '../views/pass_change_page.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      '/user_data_form': (context) => const UserData(),
      '/signup': (context) => const SignUp(),
      '/dashboard': (context) => const BottomNav(),
      '/reset_password': (context) => const ResetPassword(),
      '/signing': (context) => const Signing(),
      '/challenge': (context) => const Challenges(),
      '/notification': (context) => const NotificationPage(),
      '/change_password': (context) => ChangePasswordPage(),
      '/edit_profile': (context) => EditProfilePage(),
    };
  }
}
