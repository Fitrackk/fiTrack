import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/join_challenge_button.dart';
import 'package:fitrack/utils/customs/joined_challenge_card.dart';
import 'package:fitrack/utils/customs/progress_indicator.dart';
import 'package:fitrack/utils/customs/top_nav.dart';
import 'package:fitrack/view_models/activity_tracking.dart';
import 'package:fitrack/view_models/challenges.dart';
import 'package:intl/intl.dart';
import 'package:stator/stator.dart';
import '../models/activity_data_model.dart';
import '../models/challenge_model.dart';
import '../models/user_model.dart';
import '../view_models/user.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final userData = getSingleton<UserVM>();
  final challengeData = getSingleton<ChallengesVM>();
  final ActivityTrackerViewModel activityData = ActivityTrackerViewModel();
  late ActivityData? _localActivityData;
  int flag = 0;

  @override
  void initState() {
    super.initState();
    _fetchLocalActivityData();
    _localActivityData = null;
  }

  Future<void> _fetchLocalActivityData() async {
    final data = await activityData.fetchLocalActivityData();
    setState(() {
      _localActivityData = data;
    });
  }



  @override
  Widget build(BuildContext context) {

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String? todayDate = formatter.format(DateTime.now());
    DateTime now = DateTime.now();
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    Duration remainingTime = endOfDay.difference(now);
    String getCurrentTime() {
      DateTime now = DateTime.now().toLocal(); // Ensure the time is local
      String twoDigits(int n) => n.toString().padLeft(2, '0');

      // Add 3 hours to the current time
      DateTime futureTime = now.add(Duration(hours: 3));
      String hours = twoDigits(futureTime.hour);
      String minutes = twoDigits(futureTime.minute);
      String seconds = twoDigits(futureTime.second);

      return "$hours:$minutes:$seconds";
    }
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String hours = twoDigits(duration.inHours);
      String minutes = twoDigits(duration.inMinutes.remainder(60));
      String seconds = twoDigits(duration.inSeconds.remainder(60));
      return "$hours h $minutes m $seconds s";
    }
    String getRemainingTime() {
      String currentTime = getCurrentTime(); // Get current time
      DateTime now = DateTime.now().toLocal(); // Ensure the time is local
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      Duration remainingTime = endOfDay.difference(now);

      // Subtract 3 hours from remaining time
      remainingTime -= Duration(hours: 3);

      return formatDuration(remainingTime);
    }
    double currentWidth = MediaQuery.of(context).size.width;
    double currentHeight = MediaQuery.of(context).size.height;
    int defaultChallengeProgress = (_localActivityData != null
        ? (_localActivityData!.stepsCount / 10000) * 100
        : 0)
        .toInt();
    print("Current Time: ${getCurrentTime()}");
    print("Remaining Time: ${getRemainingTime()}");
    return Scaffold(
      appBar: TopNav(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              CustomProgressIndicator(
                  defaultChallengeProgress: defaultChallengeProgress,
                  defaultChallengeSteps: _localActivityData != null
                      ? _localActivityData!.stepsCount
                      : 0,
                  defaultChallengeGoal: 10000),
              SizedBox(
                height: 100,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                width: currentWidth / 1.1,
                height: currentHeight / 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: FitColors.tertiary90,
                  boxShadow: (const [
                    BoxShadow(
                      color: FitColors.placeholder,
                      spreadRadius: 0.1,
                      blurRadius: 2,
                      offset: Offset(5, 10),
                    ),
                  ]),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          size: 40,
                          color: FitColors.primary30,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _localActivityData != null
                                    ? "${_localActivityData!.distanceTraveled} \n"
                                    : "",
                                style: TextStyles.labelSmallBold.copyWith(
                                  color: FitColors.text20,
                                ),
                              ),
                              TextSpan(
                                text: "km",
                                style: TextStyles.labelSmallBold.copyWith(
                                  color: FitColors.text10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 40,
                          color: FitColors.primary30,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _localActivityData != null
                                    ? "${_localActivityData!.activeTime} \n"
                                    : "0 \n",
                                style: TextStyles.labelSmallBold.copyWith(
                                  color: FitColors.text20,
                                ),
                              ),
                              TextSpan(
                                text: "Time",
                                style: TextStyles.labelSmallBold.copyWith(
                                  color: FitColors.text10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 40,
                          color: FitColors.primary30,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _localActivityData != null
                                    ? "${_localActivityData!.caloriesBurned} \n"
                                    : "0 \n",
                                style: TextStyles.labelSmallBold.copyWith(
                                  color: FitColors.text20,
                                ),
                              ),
                              TextSpan(
                                text: "Kcal",
                                style: TextStyles.labelSmallBold.copyWith(
                                  color: FitColors.text10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              StreamBuilder<List<Challenge>>(
                stream: challengeData.getChallengeData().asStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Challenge> challenges =
                    snapshot.data as List<Challenge>;
                    if (challenges.isNotEmpty) {
                      for (var challenge in challenges) {
                        if (challenge.challengeDate == todayDate) {
                          return StreamBuilder<User?>(
                            stream: userData.getUserData().asStream(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                User? user = snapshot.data;
                                if (user != null) {
                                  if (challenge.participantUsernames != null) {
                                    for (int i = 0; i < challenge.participantUsernames.length; i++) {
                                      if (user.userName == challenge.participantUsernames[i]) {
                                        flag = 1;
                                      }
                                    }
                                    if (flag == 1) {
                                      return JoinedChallengeCard(
                                        defaultChallengeProgress:
                                        defaultChallengeProgress,
                                        remainingTime: getRemainingTime(),
                                        challengeName: challenge.challengeName,
                                      );
                                    } else {
                                      JoinChallengeButton();
                                    }
                                  }
                                  return JoinChallengeButton();
                                }
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              } else {
                                return Text("");
                              }
                              return Text("");
                            },
                          );
                        }
                      }
                      return JoinChallengeButton();
                    } else {
                      return const JoinChallengeButton();
                    }
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    return const Text("");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
