import 'package:fitrack/utils/customs/activity_drop_down.dart';
import 'package:fitrack/utils/customs/date_picker.dart';
import 'package:fitrack/utils/customs/participants_drop_down.dart';
import 'package:fitrack/utils/customs/reminder_toggle.dart';
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

class UserChallenges extends StatefulWidget {
  const UserChallenges({super.key});

  @override
  State<UserChallenges> createState() => _UserChallengesState();
}

class _UserChallengesState extends State<UserChallenges> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();
  final userData = getSingleton<UserVM>();
  final challengeData = getSingleton<ChallengesVM>();
  bool isJoined = true;
  final ChallengesVM challengeVM = ChallengesVM();

  void _showChallengeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: FitColors.tertiary90,
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'New Challenge Setup',
                  style:
                      TextStyles.titleMedBold.copyWith(color: FitColors.text10),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('Activity type:',
                        style: TextStyles.bodyMediumBold
                            .copyWith(color: FitColors.text10)),
                    const SizedBox(width: 50),
                    ActivityDropDown(typeController: _typeController),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Distance:',
                        style: TextStyles.bodyMediumBold
                            .copyWith(color: FitColors.text10)),
                    const SizedBox(width: 80),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'KM',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Each km earns participants 10 points',
                    style: TextStyles.bodySmallBold
                        .copyWith(color: FitColors.placeholder)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Participants #:',
                        style: TextStyles.bodyMediumBold
                            .copyWith(color: FitColors.text10)),
                    const SizedBox(width: 50),
                    ParticipantsDropDown(
                        participantsController: _participantsController),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Date:',
                        style: TextStyles.bodyMediumBold
                            .copyWith(color: FitColors.text10)),
                    const SizedBox(width: 100),
                    DatePicker(dateController: _dateController),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Enable Reminders:',
                        style: TextStyles.bodyMediumBold
                            .copyWith(color: FitColors.text10)),
                    const SizedBox(width: 80),
                    ReminderToggle(reminderController: _reminderController),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    var distance = double.tryParse(_distanceController.text);
                    if (distance == null || distance < 1 || distance > 20) {
                      if (kDebugMode) {
                        print("Distance must be between 1 and 20 km");
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Distance must be between 1 and 20 km',
                            style: TextStyles.bodySmallBold
                                .copyWith(color: FitColors.error40),
                          ),
                          backgroundColor: FitColors.tertiary50,
                        ),
                      );
                    } else {
                      try {
                        await challengeData.addChallenge(
                          context,
                          _typeController.text,
                          _distanceController.text,
                          _participantsController.text,
                          _dateController.text,
                          _reminderController.text,
                        );
                        setState(() {});
                        Navigator.pop(context);
                      } catch (e) {
                        if (kDebugMode) {
                          print("Failed to create challenge: $e");
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to create challenge: $e',
                                  style: TextStyles.bodySmallBold
                                      .copyWith(color: FitColors.error40)),
                              backgroundColor: FitColors.tertiary50),
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
                      'Create !',
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
    _typeController.dispose();
    _dateController.dispose();
    _distanceController.dispose();
    _participantsController.dispose();
    _reminderController.dispose();
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
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      Challenge challenge = snapshot.data![index];
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            StreamBuilder(
                              stream: userData.getUserData().asStream(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasData) {
                                  User? user = userSnapshot.data;
                                  if (user != null) {
                                    if (challenge.challengeOwner ==
                                        user.userName) {
                                      return FutureBuilder<
                                          List<ChallengeProgress>>(
                                        future: ChallengesVM()
                                            .getChallengeProgress(
                                                challenge.challengeId),
                                        builder: (context, progressSnapshot) {
                                          if (progressSnapshot
                                                  .connectionState ==
                                              ConnectionState.waiting) {
                                            return const ShimmerLoadingCard();
                                          } else if (progressSnapshot
                                              .hasError) {
                                            return Center(
                                              child: Text(
                                                  'Error: ${progressSnapshot.error}'),
                                            );
                                          } else if (progressSnapshot.hasData) {
                                            double totalProgress = 0;
                                            progressSnapshot.data
                                                ?.forEach((progress) {
                                              totalProgress +=
                                                  progress.progress;
                                            });

                                            double progressPercentage =
                                                progressSnapshot.data!.isEmpty
                                                    ? 0
                                                    : totalProgress /
                                                        progressSnapshot
                                                            .data!.length;

                                            return SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 20),
                                                  CustomChallengeCard(
                                                    challengeId:
                                                        challenge.challengeId,
                                                    challengeName:
                                                        challenge.challengeName,
                                                    challengeOwner: challenge
                                                        .challengeOwner,
                                                    challengeDate:
                                                        challenge.challengeDate,
                                                    participations: challenge
                                                        .participations,
                                                    challengeParticipantsImg:
                                                        challenge
                                                            .participantImages,
                                                    activityType:
                                                        challenge.activityType,
                                                    distance:
                                                        challenge.distance,
                                                    participantUsernames:
                                                        challenge
                                                            .participantUsernames,
                                                    challengeJoined: true,
                                                    challengeProgress:
                                                        "${progressPercentage.toStringAsFixed(0)}%",
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return const Center(
                                              child: Text(
                                                  'No progress data available'),
                                            );
                                          }
                                        },
                                      );
                                    }
                                    return const SizedBox();
                                  } else {
                                    return const Text("User is null");
                                  }
                                } else if (userSnapshot.hasError) {
                                  return Text("Error: ${userSnapshot.error}");
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
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
          ),
          const SizedBox(
            height: 20,
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
              onPressed: _showChallengeDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: FitColors.primary30,
                elevation: 10,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Create A New Challenge !',
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
