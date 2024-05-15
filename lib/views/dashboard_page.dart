import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/models/challenge_model.dart';
import 'package:fitrack/utils/customs/joined_challenge_card.dart';
import 'package:fitrack/utils/customs/progress_indicator.dart';
import 'package:fitrack/utils/customs/top_nav.dart';
import 'package:fitrack/view_models/challenges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stator/stator.dart';
import 'dart:core';

import '../configures/color_theme.dart';
import '../models/user_model.dart';
import '../view_models/user.dart';

class Dashboard extends StatefulWidget {
  final double defaultChallengeTraveledDistance;
  final int defaultChallengeTraveledTimeHour;
  final int defaultChallengeTraveledTimeMin;
  final int defaultChallengeBurnedCal;
  const Dashboard({
    super.key,
    required this.defaultChallengeTraveledDistance,
    required this.defaultChallengeBurnedCal,
    required this.defaultChallengeTraveledTimeHour,
    required this.defaultChallengeTraveledTimeMin,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final userData = getSingleton<UserVM>();
  final challengeData = getSingleton<ChallengesVM>();
  int flag = 0;

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;
    double currentHeight = MediaQuery.of(context).size.height;
    String getDate() {
      DateTime now = DateTime.now();
      String todayDate = "${now.day}-${now.month}-${now.year}";
      return todayDate;
    }

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
                defaultChallengeProgress: 20,
                defaultChallengeSteps: 2500,
                defaultChallengeGoal: 10000,
              ),
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
                  boxShadow: ([
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
                                text:
                                    "${widget.defaultChallengeTraveledDistance} \n",
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
                                text:
                                    "${widget.defaultChallengeTraveledTimeHour}h ${widget.defaultChallengeTraveledTimeMin}m \n",
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
                                text: "${widget.defaultChallengeBurnedCal} \n",
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
                        if (challenge.challengeDate == getDate()) {
                          return StreamBuilder<User?>(
                            stream: userData.getUserData().asStream(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                User? user = snapshot.data;
                                if (user != null) {
                                  if (challenge.participantUsernames != null) {
                                    for (int i = 0;
                                        i <
                                            challenge
                                                .participantUsernames.length;
                                        i++) {
                                      if (user.userName ==
                                          challenge.participantUsernames[i]) {
                                        print(
                                            challenge.participantUsernames[i]);
                                        flag = 1;
                                        if (flag == 1) {
                                          return JoinedChallengeCard(defaultChallengeProgress: 34, defaultChallengeGoal: 10000, challengeName: challenge.challengeName,);
                                        }
                                        else{
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 100),
                                            width: double.infinity,
                                            height: currentHeight / 14,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                    context, '/challenge');
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                MaterialStateProperty.all(
                                                    FitColors.primary30),
                                              ),
                                              child: Text(
                                                "Join Challenge Now!",
                                                style:
                                                TextStyles.titleMedium.copyWith(
                                                  color: FitColors.primary95,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  }
                                  return Text("User is not null");
                                } else {
                                  return Text("User is null");
                                }
                              } else if (snapshot.hasError) {
                                return Text("Error: ${snapshot.error}");
                              } else {
                                return Text("Loading...");
                              }
                            },
                          );
                        }
                      }
                      return Text("No challenge found for today");
                    } else {
                      return Text("List is empty");
                    }
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else {
                    return Text("Loading...");
                  }
                },
              ),
            ],
          ),
        )));
  }
}
