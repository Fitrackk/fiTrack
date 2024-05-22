import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../configures/color_theme.dart';
import '../../configures/text_style.dart';
import '../../models/user_model.dart';
import '../../view_models/custom_challenge_card_view_model.dart';

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
  });

  @override
  State<CustomChallengeCard> createState() => _CustomChallengeCardState();
}

class _CustomChallengeCardState extends State<CustomChallengeCard> {
  final CustomChallengeCardViewModel viewModel = CustomChallengeCardViewModel();
  bool _isChallengeJoined = false;

  @override
  void initState() {
    super.initState();
    _isChallengeJoined = widget.challengeJoined;
  }

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    double marginValue = 15;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: currentWidth,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: FitColors.tertiary90,
            boxShadow: (const [
              BoxShadow(
                color: FitColors.placeholder,
                spreadRadius: 0.1,
                blurRadius: 2,
                offset: Offset(1, 5),
              ),
            ]),
          ),
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
                            style: TextStyles.bodyXSmall.copyWith(
                                color: FitColors.placeholder),
                          ),
                          TextSpan(
                            text: widget.challengeDate,
                            style: TextStyles.labelSmall.copyWith(
                                color: FitColors.text20),
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
                        style: TextStyles.labelMedium.copyWith(
                            color: FitColors.text20),
                      ),
                    )
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: currentWidth / 3,
                    child: Stack(
                      children: [
                        for (int i = 1; i <= (widget.participations); i++, marginValue = marginValue + 15)
                          Container(
                            margin: EdgeInsets.fromLTRB(marginValue, 0, 0, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                widget.challengeParticipantsImg[i - 1],
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        Container(
                            margin: const EdgeInsets.fromLTRB(20, 35, 0, 0),
                            child: Text(
                              "${widget.participations} / 10 participants joined",
                              style: TextStyles.bodyXSmall.copyWith(
                                  color: FitColors.placeholder),
                            ))
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 35,
                          child: ElevatedButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: widget.challengeId.toString()));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('ID copied to clipboard')));
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    FitColors.primary30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              )),
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
                                User? currentUser = await viewModel.getCurrentUser();
                                if (currentUser != null && currentUser.userName != null) {
                                  String? username = currentUser.userName;
                                  await viewModel.joinChallenge(widget.challengeName, widget.challengeDate, username!, (isJoined) {
                                    setState(() {
                                      _isChallengeJoined = isJoined;
                                    });
                                  });
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
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
                                      title: const Text('Are you sure?'),
                                      content: Text('Are you sure you want to unjoin the challenge "${widget.challengeName}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Dismiss the dialog
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            User? currentUser = await viewModel.getCurrentUser();
                                            if (currentUser != null && currentUser.userName != null) {
                                              String? username = currentUser.userName;
                                              await viewModel.unjoinChallenge(widget.challengeName, widget.challengeDate, username!, (isJoined) {
                                                setState(() {
                                                  _isChallengeJoined = isJoined;
                                                });
                                              });
                                            }
                                            Navigator.of(context).pop(); // Dismiss the dialog
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
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
        )
      ],
    );
  }
}