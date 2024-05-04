import 'package:fitrack/view/sign_up.dart';
import 'package:fitrack/view/user_data.dart';
import 'package:fitrack/view_model/registration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    return {
      '/': (context) => ChangeNotifierProvider(
            create: (_) => Registration(),
            child: SignUp(),
          ),
      '/user_data_form': (context) => const UserData(),
    };
  }
}
