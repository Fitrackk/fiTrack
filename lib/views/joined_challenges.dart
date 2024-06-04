import 'package:fitrack/views/no_challenge_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stator/stator.dart';

import '../configures/color_theme.dart';
import '../configures/text_style.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress.dart';
import '../models/user_model.dart';
import '../utils/customs/custom_challenge_card.dart';
import '../utils/customs/shimmer_loading.dart';
import '../view_models/challenges.dart';
import '../view_models/user.dart';

class JoinedChallenges extends StatefulWidget {
  const JoinedChallenges({super.key});

  @override
  State<JoinedChallenges> createState() => _JoinedChallengesState();
}

class _JoinedChallengesState extends State<JoinedChallenges> {
  final TextEditingController _idController = TextEditingController();

  final userData = getSingleton<UserVM>();
  final ChallengesVM challengeVM = ChallengesVM();

  void _addChallengeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: FitColors.tertiary90,
          content: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: _idController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter Challenge ID',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    var id = _idController.text;
                    if (id.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter a valid challenge ID',
                            style: TextStyles.bodySmallBold
                                .copyWith(color: FitColors.text95),
                          ),
                          backgroundColor: FitColors.tertiary50,
                        ),
                      );
                    } else {
                      try {
                        await challengeVM.joinChallengeById(context, id);
                        setState(() {});
                        Navigator.pop(context);
                      } catch (e) {
                        if (kDebugMode) {
                          print("Failed to join challenge: $e");
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to join challenge: $e',
                              style: TextStyles.bodySmallBold
                                  .copyWith(color: FitColors.error40),
                            ),
                            backgroundColor: FitColors.tertiary50,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.primary20,
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.5),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Join !',
                      style: TextStyles.titleMedium
                          .copyWith(color: FitColors.primary95),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    double currentHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          FutureBuilder<List<Challenge>>(
            future: ChallengesVM().getChallengeData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ShimmerLoadingCard();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                var challenges = snapshot.data!;
                return StreamBuilder(
                  stream: userData.getUserData().asStream(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasData) {
                      User? user = userSnapshot.data;
                      if (user != null) {
                        var joinedChallenges = challenges.where((challenge) =>
                            challenge.participantUsernames
                                .contains(user.userName)).toList();
                        if (joinedChallenges.isEmpty) {
                          return const NoChallenge();
                        }
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: joinedChallenges.length,
                            itemBuilder: (context, index) {
                              Challenge challenge = joinedChallenges[index];
                              return FutureBuilder<List<ChallengeProgress>>(
                                future: ChallengesVM()
                                    .getChallengeProgress(challenge.challengeId),
                                builder: (context, progressSnapshot) {
                                  if (progressSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const ShimmerLoadingCard();
                                  } else if (progressSnapshot.hasError) {
                                    return Center(
                                      child: Text(
                                          'Error: ${progressSnapshot.error}'),
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

                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 15),
                                          CustomChallengeCard(
                                            challengeId: challenge.challengeId,
                                            challengeName:
                                            challenge.challengeName,
                                            challengeOwner:
                                            challenge.challengeOwner,
                                            challengeDate:
                                            challenge.challengeDate,
                                            participations:
                                            challenge.participations,
                                            challengeParticipantsImg:
                                            challenge.participantImages,
                                            activityType:
                                            challenge.activityType,
                                            distance: challenge.distance,
                                            participantUsernames: challenge
                                                .participantUsernames,
                                            challengeJoined: true,
                                            challengeProgress:
                                            "${progressPercentage.toStringAsFixed(0)}%",
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
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
                        return const Text("User is null");
                      }
                    } else if (userSnapshot.hasError) {
                      return Text("Error: ${userSnapshot.error}");
                    } else {
                      return const SizedBox();
                    }
                  },
                );
              } else {
                return const Center(
                  child: Text('No data available'),
                );
              }
            },
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: FitColors.placeholder,
              boxShadow: const [
                BoxShadow(
                  color: FitColors.placeholder,
                  spreadRadius: 0,
                  blurRadius: 1,
                  offset: Offset(2, 6),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 100),
            width: currentWidth / 2,
            height: currentHeight / 14,
            child: ElevatedButton(
              onPressed: _addChallengeDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: FitColors.primary30,
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Join By Challenge ID Now!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
