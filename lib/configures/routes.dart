// import 'package:fitrack/views/dashboard_page.dart';
// import 'package:fitrack/views/reset_password_page.dart';
// import 'package:fitrack/views/sign_up_page.dart';
// import 'package:fitrack/views/signing_page.dart';
// import 'package:fitrack/views/user_data_page.dart';
// import 'package:flutter/material.dart';
//
// import '../views/get_started_page.dart';
//
// class Routes {
//   static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
//     return {
//       '/user_data_form': (context) => const UserData(),
//       '/signup': (context) => const SignUp(),
//       '/dashboard': (context) => const Dashboard(),
//       '/reset_password': (context) => const ResetPassword(),
//       '/signing': (context) => const Signing(),
//       '/get_started': (context) => const StartedPage(),
//     };
//   }
// }


import 'package:flutter/material.dart';import '../views/dashboard_page.dart';
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
