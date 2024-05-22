import 'package:fitrack/models/challenge_model.dart';
import 'package:fitrack/utils/customs/custom_challenge_card.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/material.dart';
import 'package:stator/stator.dart';

import '../configures/color_theme.dart';
import '../configures/text_style.dart';
import '../models/challenge_progress.dart';
import '../models/user_model.dart';
import '../view_models/challenges.dart';

class AllChallenges extends StatefulWidget {
  const AllChallenges({super.key});

  @override
  State<AllChallenges> createState() => _AllChallengesState();
}

class _AllChallengesState extends State<AllChallenges> {
  late Icon filterIcon = const Icon(Icons.filter_alt_outlined,
      size: 40, color: FitColors.primary30);
  String? _selectedFilter;
  ChallengesVM challengesData = ChallengesVM();
  final UserVM userData = getSingleton<UserVM>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 5, 20, 5),
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () async {
              String? selectedFilter = await showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(5, 150, 0, 0),
                  items: [
                    PopupMenuItem(
                      value: null,
                      child: Text('All Challenges',
                          style: TextStyles.labelLarge.copyWith(
                            color: FitColors.text20,
                          )), // No filter
                    ),
                    PopupMenuItem(
                      value: 'walking',
                      child: Text('Walking Challenges',
                          style: TextStyles.labelLarge.copyWith(
                            color: FitColors.text20,
                          )),
                    ),
                    PopupMenuItem(
                      value: 'running',
                      child: Text('Running Challenges',
                          style: TextStyles.labelLarge.copyWith(
                            color: FitColors.text20,
                          )),
                    ),
                    PopupMenuItem(
                      value: 'jogging',
                      child: Text('Jogging Challenges',
                          style: TextStyles.labelLarge.copyWith(
                            color: FitColors.text20,
                          )),
                    ),
                  ],
                  elevation: 20.0,
                  color: FitColors.primary95);
              setState(() {
                filterIcon = const Icon(Icons.filter_alt,
                    size: 40, color: FitColors.primary30);
                _selectedFilter = selectedFilter;
              });
            },
            icon: filterIcon,
          ),
        ),
        FutureBuilder<User?>(
          future: userData.getUserData(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text(" "),
              );
            } else if (userSnapshot.hasError) {
              return Center(
                child: Text('Error: ${userSnapshot.error}'),
              );
            } else if (userSnapshot.hasData) {
              User? user = userSnapshot.data;
              if (user == null) {
                return const Center(
                  child: Text('User not found'),
                );
              }
              return FutureBuilder<List<Challenge>>(
                future:
                    challengesData.getChallengeData(filter: _selectedFilter),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text(" "),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          bool isJoined = false;
                          Challenge challenge = snapshot.data![index];
                          isJoined = challenge.participantUsernames
                              .contains(user.userName);
                          return FutureBuilder<List<ChallengeProgress>>(
                            future: challengesData
                                .getChallengeProgress(challenge.challengeId),
                            builder: (context, progressSnapshot) {
                              if (progressSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Text(" "),
                                );
                              } else if (progressSnapshot.hasError) {
                                return Center(
                                  child:
                                      Text('Error: ${progressSnapshot.error}'),
                                );
                              } else if (progressSnapshot.hasData) {
                                double totalProgress = 0;
                                progressSnapshot.data?.forEach((progress) {
                                  totalProgress += progress.progress;
                                });

                                double progressPercentage =
                                    progressSnapshot.data!.isEmpty
                                        ? 0
                                        : totalProgress /
                                            progressSnapshot.data!.length;

                                return Column(
                                  children: [
                                    CustomChallengeCard(
                                      challengeId: challenge.challengeId,
                                      challengeName: challenge.challengeName,
                                      challengeOwner: challenge.challengeOwner,
                                      challengeDate: challenge.challengeDate,
                                      challengeProgress:
                                          "${progressPercentage.toStringAsFixed(0)}%",
                                      participations: challenge.participations,
                                      challengeParticipantsImg: const [
                                        "assets/images/Rectangle.png",
                                        "assets/images/Rectangle.png",
                                        "assets/images/girl.png",
                                        "assets/images/Rectangle.png",
                                        "assets/images/girl.png",
                                        "assets/images/Rectangle.png",
                                        "assets/images/Rectangle.png",
                                        "assets/images/Rectangle.png",
                                        "assets/images/Rectangle.png",
                                        "assets/images/Rectangle.png",
                                        "assets/images/Rectangle.png",
                                      ],
                                      activityType: challenge.activityType,
                                      distance: challenge.distance,
                                      participantUsernames:
                                          challenge.participantUsernames,
                                      challengeJoined: isJoined,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: Text('No progress data available'),
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('No data available'),
                    );
                  }
                },
              );
            } else {
              return const Center(
                child: Text('No user data available'),
              );
            }
          },
        ),
      ],
    );
  }
}
