import 'package:flutter/material.dart';
import 'package:stator/stator.dart';

import '../configures/color_theme.dart';
import '../configures/text_style.dart';
import '../models/challenge_model.dart';
import '../models/user_model.dart';
import '../utils/customs/custom_challenge_card.dart';
import '../view_models/challenges.dart';
import '../view_models/user.dart';

class AllChallenges extends StatefulWidget {
  const AllChallenges({super.key});

  @override
  State<AllChallenges> createState() => _AllChallengesState();
}

class _AllChallengesState extends State<AllChallenges> {
  late Icon filterIcon = const Icon(Icons.filter_alt_outlined,
      size: 40, color: FitColors.primary30);
  String? _selectedFilter;
  final userData = getSingleton<UserVM>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                      child: Text(
                        'All Challenges',
                        style: TextStyles.labelLarge.copyWith(
                          color: FitColors.text20,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'walking',
                      child: Text(
                        'Walking Challenges',
                        style: TextStyles.labelLarge.copyWith(
                          color: FitColors.text20,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'running',
                      child: Text(
                        'Running Challenges',
                        style: TextStyles.labelLarge.copyWith(
                          color: FitColors.text20,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'jogging',
                      child: Text(
                        'Jogging Challenges',
                        style: TextStyles.labelLarge.copyWith(
                          color: FitColors.text20,
                        ),
                      ),
                    ),
                  ],
                  elevation: 20.0,
                );
                setState(() {
                  filterIcon = const Icon(Icons.filter_alt,
                      size: 40, color: FitColors.primary30);
                  _selectedFilter = selectedFilter;
                });
              },
              icon: filterIcon,
            ),
          ),
          FutureBuilder<List<Challenge>>(
            future: ChallengesVM().getChallengeData(filter: _selectedFilter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    bool isJoined = false;
                    Challenge challenge = snapshot.data![index];
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          StreamBuilder(
                            stream: userData.getUserData().asStream(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                User? user = snapshot.data;
                                if (user != null) {
                                  for (int i = 0;
                                  i < challenge.participantUsernames.length;
                                  i++) {
                                    if (user.userName == challenge.participantUsernames[i]) {
                                      isJoined = true;
                                    }
                                  }
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        CustomChallengeCard(
                                          challengeId: challenge.challengeId,
                                          challengeName: challenge.challengeName,
                                          challengeOwner: challenge.challengeOwner,
                                          challengeDate: challenge.challengeDate,
                                          challengeProgress: "20%",
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
                                          participantUsernames: challenge.participantUsernames,
                                          challengeJoined: isJoined,
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const Text("User is null");
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
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No data available'),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
