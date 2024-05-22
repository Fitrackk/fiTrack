import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../configures/color_theme.dart';
import '../../configures/text_style.dart';

class JoinedChallengeCard extends StatefulWidget {
  final int defaultChallengeProgress;
  final int defaultChallengeGoal;
  final String challengeName;
  const JoinedChallengeCard(
      {super.key,
      required this.defaultChallengeProgress,
      required this.defaultChallengeGoal,
      required this.challengeName});

  @override
  State<JoinedChallengeCard> createState() => _JoinedChallengeCardState();
}

class _JoinedChallengeCardState extends State<JoinedChallengeCard> {
  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    double currentHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      height: currentHeight / 7,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: FitColors.placeholder,
            spreadRadius: 0.1,
            blurRadius: 2,
            offset: Offset(3, 5),
          ),
        ],
        borderRadius: BorderRadius.circular(30),
        image: const DecorationImage(
          image: AssetImage('assets/images/manRunImg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: ElevatedButton(
          onPressed: () {
            // Add your button onPressed logic here
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 10,
                left: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Today Challenge !\n",
                      style: TextStyles.labelLargeBold.copyWith(
                        color: FitColors.text20,
                      ),
                    ),
                    Text(
                      widget.challengeName,
                      style: TextStyles.labelMedium.copyWith(
                        color: FitColors.text20,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                right: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "14h 30m 23s \n",
                      style: TextStyles.labelMediumBold.copyWith(
                        color: FitColors.text20,
                      ),
                    ),
                    Text(
                      '${widget.defaultChallengeProgress}%',
                      style: TextStyles.bodySmall.copyWith(
                        color: FitColors.text20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
