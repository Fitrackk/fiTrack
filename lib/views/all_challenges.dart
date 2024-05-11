import 'package:fitrack/utils/customs/custom_challenge_card.dart';
import 'package:flutter/material.dart';
import '../configures/color_theme.dart';

class AllChallenges extends StatefulWidget {
  const AllChallenges({super.key});

  @override
  State<AllChallenges> createState() => _AllChallengesState();
}

class _AllChallengesState extends State<AllChallenges> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          alignment: Alignment.topRight,
          child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_alt_outlined,
                  size: 40, color: FitColors.primary30)),
        ),
        CustomChallengeCard(
          challengeName: '10 Km walking',
          challengeOwner: 'By BROO',
          challengeDate: '1/20/2024',
          challengeProgress: "20%",
          challengeParticipants: 6,
          challengeJoined: true,
          challengeParticipantsImg: [
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
        ),
        const SizedBox(
          height: 20,
        ),
        CustomChallengeCard(
          challengeName: '4 Km Jogging',
          challengeOwner: 'By Mo',
          challengeDate: '10/12/2023',
          challengeProgress: "60%",
          challengeParticipants: 2,
          challengeJoined: false,
          challengeParticipantsImg: [
            "assets/images/logo.png",
            "assets/images/Rectangle.png",
            "assets/images/girl.png",
            "assets/images/Rectangle.png",
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        CustomChallengeCard(
          challengeName: '3 Km Running',
          challengeOwner: 'By Ar',
          challengeDate: '11/5/2024',
          challengeProgress: "35%",
          challengeParticipants:3,
          challengeJoined: true,
          challengeParticipantsImg: [
            "assets/images/logo.png",
            "assets/images/Rectangle.png",
            "assets/images/girl.png",
            "assets/images/Rectangle.png",
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        CustomChallengeCard(
          challengeName: '10 Km walking',
          challengeOwner: 'By BROO',
          challengeDate: '1/20/2024',
          challengeProgress: "55%",
          challengeParticipants: 7,
          challengeJoined: false,
          challengeParticipantsImg: [
            "assets/images/Rectangle.png",
            "assets/images/logo.png",
            "assets/images/Rectangle.png",
            "assets/images/girl.png",
            "assets/images/Rectangle.png",
            "assets/images/girl.png",
            "assets/images/Rectangle.png"

          ],
        ),
        const SizedBox(
          height: 20,
        ),
        CustomChallengeCard(
          challengeName: '10 Km walking',
          challengeOwner: 'By BROO',
          challengeDate: '1/20/2024',
          challengeProgress: "30%",
          challengeParticipants: 1,
          challengeJoined: true,
          challengeParticipantsImg: [
            "assets/images/Rectangle.png",
            "assets/images/Rectangle.png",
          ],
        ),
      ]),
    );
  }
}
