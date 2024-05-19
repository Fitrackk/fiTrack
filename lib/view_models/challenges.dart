import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/models/challenge_model.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';

class ChallengesVM {
  final UserVM _userVM = UserVM();
  late User? currentUser;
  String? username;
  final Random _random = Random();

  Future<int> generateUniqueChallengeId() async {
    late int challengeId;
    bool exists = true;

    while (exists) {
      challengeId =
          _random.nextInt(100000000); // Generate a random 8-digit number
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('challenges')
          .where('challengeId', isEqualTo: challengeId)
          .get();
      exists = result.docs.isNotEmpty;
    }

    return challengeId;
  }

  Future<List<Challenge>> getChallengeData({String? filter}) async {
    final User? currentUser = await _userVM.getUserData();
    if (currentUser != null) {
      username = currentUser.userName;
    }
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("challenges").get();

      List<Challenge> challenges = querySnapshot.docs.map((doc) {
        return Challenge.fromFirestore(doc);
      }).toList();

      if (filter != null && filter.isNotEmpty) {
        challenges = challenges
            .where((challenge) =>
                challenge.activityType.toLowerCase() == filter.toLowerCase())
            .toList();
      }
      return challenges;
    } catch (e) {
      print("Error fetching challenges: $e");
      return [];
    }
  }


  Future<void> addChallenge(
    BuildContext context,
    String? activityType,
    String? distance,
    String? participants,
    String? date,
    String? reminder,
  ) async {
    int challengeId = await generateUniqueChallengeId();
    try {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String? todayDate =
          date?.isNotEmpty == true ? date : formatter.format(DateTime.now());

      activityType =
          activityType?.isNotEmpty == true ? activityType : 'Walking';
      distance = distance?.isNotEmpty == true ? distance : '5';
      participants = participants?.isNotEmpty == true ? participants : '7';
      date = date?.isNotEmpty == true ? date : todayDate;
      reminder = reminder?.isNotEmpty == true ? reminder : 'true';

      await FirebaseFirestore.instance.collection('challenges').add({
        'activityType': activityType,
        'challengeDate': date,
        'challengeId': challengeId,
        'challengeName': "$distance km $activityType",
        'participantUsernames': [username],
        'challengeOwner': username,
        'distance': double.parse(distance!),
        'participations': int.parse(participants!),
        'reminder': reminder,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create challenge: $e')),
      );
    }
  }
}
