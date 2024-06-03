import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../configures/color_theme.dart';
import '../configures/text_style.dart';

class NoNotification extends StatelessWidget {
  const NoNotification({super.key});

  @override
  Widget build(BuildContext context) {

    return
      Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImageIcon(
              AssetImage('assets/images/google_alerts_icon.png'),
              size: 120,
              color: FitColors.primary30,
            ),
            SizedBox(height: 50),
            Text("No Notification Yet", style: TextStyles.titleLargeBold.copyWith(color: FitColors.text20),),
            SizedBox(height: 60),
            Text(
              "you have no notification right now. \n come back later",
              style: TextStyles.titleMedium.copyWith(color: FitColors.text60),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 300),

          ],
        ),
    );
  }
}
