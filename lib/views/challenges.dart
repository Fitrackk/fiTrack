import 'package:fitrack/configures/color_theme.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/views/all_challenges.dart';
import 'package:fitrack/views/user_challenge.dart';
import 'package:flutter/material.dart';

class Challenges extends StatefulWidget {

  const Challenges(
      {super.key});

  @override
  State<Challenges> createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: FitColors.background,
        appBar: AppBar(
          elevation: 0.0,
          bottom: TabBar(tabs: [
            Tab(
              text: 'All Challenges',
            ),
            Tab(
              text: 'Joined Challenges',
            ),
            Tab(
              text: 'My Challenges',
            ),
          ],
            indicatorColor: FitColors.text20,
            labelStyle: TextStyles.labelLargeBold,
            unselectedLabelStyle: TextStyles.labelMedium,
            labelColor: FitColors.text20,
            unselectedLabelColor: FitColors.text20,
          ),
        ),
        body: const TabBarView(
          children: [
            AllChallenges(),
            Text('Tab 2 content'),
            UserChallenge(),
          ],
        ),
      ),
    );
  }
}
