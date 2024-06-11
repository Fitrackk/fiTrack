import 'package:flutter/material.dart';

import '../../configures/color_theme.dart';
import '../../configures/text_style.dart';
import '../../view_models/celebrating.dart';

class JoinedChallengeCard extends StatefulWidget {
  final int defaultChallengeProgress;
  final String challengeName;
  final remainingTime;
  final int challengeId;
  const JoinedChallengeCard(
      {super.key,
      required this.defaultChallengeProgress,
      required this.challengeName,
      this.remainingTime,
      required this.challengeId});

  @override
  State<JoinedChallengeCard> createState() => _JoinedChallengeCardState();
}

class _JoinedChallengeCardState extends State<JoinedChallengeCard> {
  final CelebratingDialogVM _celebratingDialogVM = CelebratingDialogVM();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkChallengeProgress();
    });
  }

  void _checkChallengeProgress() async {
    await _celebratingDialogVM.checkAndShowCelebratingDialog(
      widget.challengeId,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // onPressed logic here
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            elevation: WidgetStateProperty.all(0),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
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
                      "${widget.remainingTime} \n",
                      style: TextStyles.labelLargeBold.copyWith(
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
