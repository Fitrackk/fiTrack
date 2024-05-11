import 'package:flutter/material.dart';
import '../../configures/color_theme.dart';
import '../../configures/text_style.dart';

class CustomChallengeCard extends StatefulWidget {
  final String challengeName;
  final String challengeOwner;
  final String challengeDate;
  final bool? challengeJoined;
  final String? challengeProgress;
  final int challengeParticipants;
  final List<String> challengeParticipantsImg;

  CustomChallengeCard(
      {super.key,
      required this.challengeName,
      required this.challengeOwner,
      required this.challengeDate,
      this.challengeProgress,
      required this.challengeParticipants,
      required this.challengeJoined,
      required this.challengeParticipantsImg});

  @override
  State<CustomChallengeCard> createState() => _CustomChallengeCardState();
}

class _CustomChallengeCardState extends State<CustomChallengeCard> {
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
                  if(widget.challengeJoined == true)
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
                  Container(
                    width: currentWidth/3,
                    child: Stack(
                      children: [
                        for (int i = 1;
                            i <= (widget.challengeParticipants);
                            i++, marginValue = marginValue + 15)
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
                              "${widget.challengeParticipants} / 10 participants joined",
                              style: TextStyles.bodyXSmall
                                  .copyWith(color: FitColors.placeholder),
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
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
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
                              )),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        if(widget.challengeJoined == false)
                            SizedBox(
                            width: 90,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    FitColors.primary30),
                              ),
                            child:
                            Text(
                                "Join",
                                style: TextStyles.labelSmall.copyWith(
                                  color: FitColors.primary95,
                                ),
                              ),
                            ),
                          ),
                        if(widget.challengeJoined == true)
                          SizedBox(
                            width: 90,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    FitColors.primary30),
                              ),
                              child:
                              Text(
                                "Joined",
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
