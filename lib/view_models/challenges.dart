import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/models/challenge_model.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/challenge_progress.dart';
import '../models/user_model.dart';

class ChallengesVM {
  final UserVM _userVM = UserVM();
  User? currentUser;
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
    currentUser = await _userVM.getUserData();
    if (currentUser != null) {
      username = currentUser!.userName;
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

  Future<List<Challenge>> getUserChallengeData({String? filter}) async {
    currentUser = await _userVM.getUserData();
    if (currentUser == null) {
      return [];
    }

    username = currentUser!.userName;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("challenges")
          .where('participantUsernames', arrayContains: username)
          .get();

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

  Future<List<ChallengeProgress>> getChallengeProgress(int challengeId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('challengeProgress')
          .where('challengeId', isEqualTo: challengeId)
          .get();

      return querySnapshot.docs.map((doc) {
        return ChallengeProgress.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print("Error fetching challenge progress: $e");
      return [];
    }
  }

  Future<bool> hasChallengeOnDate(String username, String date) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('challenges')
        .where('participantUsernames', arrayContains: username)
        .where('challengeDate', isEqualTo: date)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addChallenge(
    BuildContext context,
    String? activityType,
    String? distance,
    String? participants,
    String? date,
    String? reminder,
  ) async {
    try {
      currentUser = await _userVM.getUserData();
      if (currentUser == null) {
        Navigator.pushNamed(context, '/signing');
        return;
      }

      username = currentUser!.userName;

      int challengeId = await generateUniqueChallengeId();
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String? todayDate =
          date?.isNotEmpty == true ? date : formatter.format(DateTime.now());

      activityType =
          activityType?.isNotEmpty == true ? activityType : 'Walking';
      distance = distance?.isNotEmpty == true ? distance : '5';
      participants = participants?.isNotEmpty == true ? participants : '7';
      date = date?.isNotEmpty == true ? date : todayDate;
      reminder = reminder?.isNotEmpty == true ? reminder : 'true';

      bool hasChallenge = await hasChallengeOnDate(username!, date!);
      if (hasChallenge) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You already have a challenge on this date.')),
        );
        return;
      }

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

      addChallengeProgress(username!, activityType!, double.parse(distance),
          date, 0, challengeId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create challenge: $e')),
      );
    }
  }

  Future<void> addChallengeProgress(
    String username,
    String activityType,
    double distance,
    String challengeDate,
    double progress,
    int challengeId,
  ) async {
    try {
      final challengeProgress = ChallengeProgress(
        username: username,
        activityType: activityType,
        distance: distance,
        challengeDate: challengeDate,
        progress: progress,
        challengeId: challengeId,
      );

      await FirebaseFirestore.instance
          .collection('challengeProgress')
          .add(challengeProgress.toFirestore());
    } catch (e) {
      print('Failed to add challenge progress: $e');
    }
  }
}
