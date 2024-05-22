import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../configures/color_theme.dart';
import '../configures/text_style.dart';

class NoNotification extends StatelessWidget {
  const NoNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: FitColors.primary30),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Notifications',
              style: TextStyles.displaySmallBold.copyWith(color: FitColors.text20),
            ),
            SizedBox(height: 110),
            ImageIcon(
              AssetImage('assets/images/GoogleAlertsIcon.png'),
              size: 120,
              color: FitColors.primary30,
            ),
            SizedBox(height: 60),
            Text("No Notification Yet", style: TextStyles.titleLargeBold.copyWith(color: FitColors.text20),),
            SizedBox(height: 40),
            Text(
              "you have no notification right now. \n come back later",
              style: TextStyles.titleMedium.copyWith(color: FitColors.text60),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
