import 'package:flutter/material.dart';

import '../../configures/color_theme.dart';
import '../../configures/text_style.dart';

class JoinChallengeButton extends StatefulWidget {
  const JoinChallengeButton({super.key});

  @override
  State<JoinChallengeButton> createState() => _JoinChallengeButtonState();
}

class _JoinChallengeButtonState extends State<JoinChallengeButton> {
  @override
  Widget build(BuildContext context) {
    double currentHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100),
      width: double.infinity,
      height: currentHeight / 14,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/challenge');
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(FitColors.primary30),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          minimumSize: WidgetStateProperty.all(
            Size(double.infinity, currentHeight / 14),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Join Challenge Now!",
            style: TextStyles.titleMedium.copyWith(
              color: FitColors.primary95,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
