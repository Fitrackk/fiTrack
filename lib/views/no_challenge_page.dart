import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:flutter/material.dart';

class NoChallenge extends StatelessWidget {
  const NoChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const ImageIcon(
              AssetImage('assets/images/challenge.png'),
              size: 120,
              color: FitColors.primary30,
            ),
            const SizedBox(height: 40),
            Text(
              "No Challenges Yet",
              style:
                  TextStyles.titleLargeBold.copyWith(color: FitColors.text20),
            ),
            const SizedBox(height: 40),
            Text(
              "you have no Challenges right now.",
              style: TextStyles.titleMedium.copyWith(color: FitColors.text40),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
