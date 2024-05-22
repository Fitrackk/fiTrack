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
          backgroundColor: MaterialStateProperty.all(FitColors.primary30),
        ),
        child: Text(
          "Join Challenge Now!",
          style: TextStyles.titleMedium.copyWith(
            color: FitColors.primary95,
          ),
        ),
      ),
    );
  }
}
