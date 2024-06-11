import 'package:fitrack/view_models/challenges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../configures/color_theme.dart';
import '../../configures/text_style.dart';
import '../../models/user_model.dart';

class CustomChallengeCard extends StatefulWidget {
  final String activityType;
  final String challengeDate;
  final int challengeId;
  final String challengeName;
  final String challengeOwner;
  final double distance;
  final List<String> participantUsernames;
  final int participations;
  final bool challengeJoined;
  final String? challengeProgress;
  final List<String> challengeParticipantsImg;
  final VoidCallback onUnjoin;

  const CustomChallengeCard({
    super.key,
    required this.activityType,
    required this.challengeDate,
    required this.challengeId,
    required this.challengeName,
    required this.challengeOwner,
    required this.distance,
    required this.participantUsernames,
    required this.participations,
    required this.challengeJoined,
    required this.challengeProgress,
    required this.challengeParticipantsImg,
    required this.onUnjoin,
  });

  @override
  State<CustomChallengeCard> createState() => _CustomChallengeCardState();
}

class _CustomChallengeCardState extends State<CustomChallengeCard> {
  final ChallengesVM challengesVM = ChallengesVM();
  bool _isChallengeJoined = false;

  @override
  void initState() {
    super.initState();
    _isChallengeJoined = widget.challengeJoined;
  }

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    int joinedParticipants = widget.participantUsernames.length;
    int allowedParticipants = widget.participations;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: currentWidth,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: FitColors.tertiary90,
            boxShadow: const [
              BoxShadow(
                color: FitColors.placeholder,
                spreadRadius: 0.1,
                blurRadius: 2,
                offset: Offset(1, 5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${widget.challengeName}.\n",
                              style: TextStyles.labelLargeBold.copyWith(
                                color: FitColors.text20,
                                shadows: [
                                  const Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.grey,
                                    offset: Offset(2.0, 3.0),
                                  ),
                                ],
                              ),
                            ),
                            TextSpan(
                              text: "${widget.challengeOwner}\n",
                              style: TextStyles.bodyXSmall
                                  .copyWith(color: FitColors.placeholder),
                            ),
                            TextSpan(
                              text: widget.challengeDate,
                              style: TextStyles.labelSmall
                                  .copyWith(color: FitColors.text20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isChallengeJoined)
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 20, 25),
                        child: Text(
                          "${widget.challengeProgress}",
                          style: TextStyles.labelMedium
                              .copyWith(color: FitColors.text20),
                        ),
                      )
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Stack(
                        children: [
                          for (int i = 0;
                              i < widget.participantUsernames.length;
                              i++)
                            Positioned(
                              left: 20.0 + i * 15.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Image.network(
                                  widget.challengeParticipantsImg.length > i
                                      ? widget.challengeParticipantsImg[i]
                                      : 'assets/images/unknown.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 35, 0, 0),
                            child: Text(
                              "$joinedParticipants / $allowedParticipants joined",
                              style: TextStyles.bodyXSmall
                                  .copyWith(color: FitColors.placeholder),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: widget.challengeId.toString()));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    'ID copied to clipboard',
                                    style: TextStyles.bodySmallBold
                                        .copyWith(color: FitColors.text95),
                                  ),
                                  backgroundColor: FitColors.tertiary50,
                                ));
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    FitColors.primary30),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Copy ID",
                                    style: TextStyles.bodyXSmall.copyWith(
                                      color: FitColors.text95,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.copy,
                                    size: 15,
                                    color: FitColors.primary80,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          if (!_isChallengeJoined)
                            SizedBox(
                              width: 90,
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () async {
                                  User? currentUser =
                                      await challengesVM.getCurrentUser();
                                  if (currentUser != null &&
                                      currentUser.userName != null) {
                                    String? username = currentUser.userName;
                                    await challengesVM.joinChallenge(
                                        context,
                                        widget.challengeName,
                                        widget.challengeDate,
                                        username!, (isJoined) {
                                      setState(() {
                                        _isChallengeJoined = isJoined;
                                      });
                                    });
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      FitColors.primary30),
                                ),
                                child: Text(
                                  "Join",
                                  style: TextStyles.labelSmall.copyWith(
                                    color: FitColors.primary95,
                                  ),
                                ),
                              ),
                            ),
                          if (_isChallengeJoined)
                            SizedBox(
                              width: 90,
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        backgroundColor: FitColors.tertiary90,
                                        content: SizedBox(
                                          width: 200,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Are you sure?',
                                                style: TextStyles.titleMedium,
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                'Are you sure you want to unjoin the challenge "${widget.challengeName}"?',
                                                style: TextStyles.bodyMed,
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          FitColors.primary20,
                                                      elevation: 10,
                                                      shadowColor: Colors.black
                                                          .withOpacity(0.5),
                                                    ),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        'No',
                                                        style: TextStyles
                                                            .titleMedium
                                                            .copyWith(
                                                          color: FitColors
                                                              .primary95,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      User? currentUser =
                                                          await challengesVM
                                                              .getCurrentUser();
                                                      if (currentUser != null &&
                                                          currentUser
                                                                  .userName !=
                                                              null) {
                                                        String? username =
                                                            currentUser
                                                                .userName;
                                                        await challengesVM
                                                            .unjoinChallenge(
                                                          context,
                                                          widget.challengeName,
                                                          widget.challengeDate,
                                                          username!,
                                                          (isJoined) {
                                                            setState(() {
                                                              _isChallengeJoined =
                                                                  isJoined;
                                                            });
                                                            widget.onUnjoin();
                                                          },
                                                        );
                                                      }
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          FitColors.primary20,
                                                      elevation: 10,
                                                      shadowColor: Colors.black
                                                          .withOpacity(0.5),
                                                    ),
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        'Yes',
                                                        style: TextStyles
                                                            .titleMedium
                                                            .copyWith(
                                                          color: FitColors
                                                              .primary95,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      FitColors.primary30),
                                ),
                                child: Text(
                                  "Unjoin",
                                  style: TextStyles.labelSmall.copyWith(
                                    color: FitColors.primary95,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
