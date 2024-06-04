import 'dart:async';

import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/utils/customs/dash_challenge_card.dart';
import 'package:fitrack/utils/customs/join_challenge_button.dart';
import 'package:fitrack/utils/customs/progress_indicator.dart';
import 'package:fitrack/utils/customs/top_nav.dart';
import 'package:fitrack/view_models/activity_tracking.dart';
import 'package:fitrack/view_models/challenges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stator/stator.dart';

import '../models/activity_data_model.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress.dart';
import '../view_models/user.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final userData = getSingleton<UserVM>();
  final challengeData = getSingleton<ChallengesVM>();
  final ActivityTrackerVM activityData = ActivityTrackerVM();
  ActivityData? _localActivityData;
  late DateTime _endTime;
  late Duration _remainingDuration;
  final StreamController<ActivityData?> _activityDataController =
      StreamController<ActivityData?>.broadcast();

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startFetchingLocalActivityData();
  }

  void _startFetchingLocalActivityData() {
    Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      try {
        final data = await activityData.fetchLocalActivityData();
        if (!_activityDataController.isClosed) {
          _activityDataController.add(data);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching activity data: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _activityDataController.close();
    super.dispose();
  }

  String getCurrentTime() {
    DateTime now = DateTime.now().toLocal();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    DateTime futureTime = now.add(const Duration(hours: 3));
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
    DateTime now = DateTime.now().toLocal();
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    Duration remainingTime = endOfDay.difference(now);
    if (remainingTime > const Duration(hours: 24)) {
      remainingTime = const Duration(hours: 24);
    }
    return formatDuration(remainingTime);
  }

  void _calculateRemainingTime() {
    DateTime now = DateTime.now().toLocal();
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _endTime = endOfDay;
    _updateRemainingTime();
  }

  void _updateRemainingTime() {
    DateTime now = DateTime.now().toLocal();
    _remainingDuration = _endTime.difference(now);
    if (_remainingDuration.isNegative) {
      _remainingDuration = Duration.zero;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String? todayDate = formatter.format(DateTime.now());
    double currentWidth = MediaQuery.of(context).size.width;
    double currentHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: TopNav(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              StreamBuilder<ActivityData?>(
                stream: _activityDataController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _localActivityData = snapshot.data;
                  }
                  int defaultChallengeProgress = (_localActivityData != null
                          ? (_localActivityData!.stepsCount / 10000) * 100
                          : 0)
                      .toInt();
                  return CustomProgressIndicator(
                    defaultChallengeProgress: defaultChallengeProgress,
                    defaultChallengeSteps: _localActivityData != null
                        ? _localActivityData!.stepsCount
                        : 0,
                    defaultChallengeGoal: 10000,
                  );
                },
              ),
              const SizedBox(height: 100),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                width: currentWidth / 1.1,
                height: currentHeight / 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: FitColors.tertiary90,
                  boxShadow: const [
                    BoxShadow(
                      color: FitColors.placeholder,
                      spreadRadius: 0.1,
                      blurRadius: 2,
                      offset: Offset(5, 10),
                    ),
                  ],
                ),
                child: StreamBuilder<ActivityData?>(
                  stream: _activityDataController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _localActivityData = snapshot.data;
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDataRow(
                          icon: Icons.location_pin,
                          value: _localActivityData?.distanceTraveled
                                  .toStringAsFixed(2) ??
                              "0",
                          unit: "km",
                        ),
                        _buildDataRow(
                          icon: Icons.access_time_rounded,
                          value:
                              _localActivityData?.activeTime.toString() ?? "0",
                          unit: "min",
                        ),
                        _buildDataRow(
                          icon: Icons.local_fire_department_rounded,
                          value: _localActivityData?.caloriesBurned
                                  .toInt()
                                  .toString() ??
                              "0",
                          unit: "Kcal",
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 50),
              StreamBuilder<List<Challenge>>(
                stream: challengeData.getUserChallengeData().asStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Challenge> challenges =
                        snapshot.data as List<Challenge>;
                    if (challenges.isNotEmpty) {
                      for (var challenge in challenges) {
                        if (challenge.challengeDate == todayDate) {
                          return FutureBuilder<List<ChallengeProgress>>(
                            future: ChallengesVM()
                                .getChallengeProgress(challenge.challengeId),
                            builder: (context, progressSnapshot) {
                              if (progressSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildShimmerCard();
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

                                return JoinedChallengeCard(
                                  defaultChallengeProgress:
                                      progressPercentage.toInt(),
                                  remainingTime: getRemainingTime(),
                                  challengeName: challenge.challengeName,
                                  challengeId: challenge.challengeId,
                                );
                              } else if (progressSnapshot.hasError) {
                                return Text("Error: ${progressSnapshot.error}");
                              } else {
                                return const Text(" ");
                              }
                            },
                          );
                        }
                      }
                      return const JoinChallengeButton();
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

  Widget _buildDataRow({
    required IconData icon,
    required String value,
    required String unit,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 40,
          color: FitColors.primary30,
        ),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$value \n",
                style: TextStyles.labelSmallBold.copyWith(
                  color: FitColors.text20,
                ),
              ),
              TextSpan(
                text: unit,
                style: TextStyles.labelSmallBold.copyWith(
                  color: FitColors.text10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 7,
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
        ),
        child: ElevatedButton(
          onPressed: () {},
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
                    Container(
                      width: 100,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 150,
                      height: 20,
                      color: Colors.white,
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
                    Container(
                      width: 100,
                      height: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 50,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
