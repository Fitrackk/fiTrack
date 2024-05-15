import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/models/challenge_model.dart';
import 'package:fitrack/view_models/user.dart';
import '../models/user_model.dart';

class ChallengesVM {
  late String? username;
  late bool _isJoined = false; // Initialize _isJoined to false

  bool get isJoined => _isJoined;

  Future<List<Challenge>> getChallengeData({String? filter}) async {
    try {
      final UserVM _userVM = UserVM();
      final User? currentUser = await _userVM.getUserData();

      if (currentUser != null) {
        username = currentUser.userName;
      }

      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("challenges").get();

      List<Challenge> challenges = querySnapshot.docs.map((doc) {
        return Challenge.fromFirestore(doc);
      }).toList();

      if (username != null && username!.isNotEmpty) {
        _isJoined = challenges.any((challenge) =>
            isUsernameExist(username!, challenge.participantUsernames));
      }

      if (filter != null && filter.isNotEmpty) {
        challenges = challenges
            .where((challenge) =>
        challenge.activityType?.toLowerCase() == filter.toLowerCase())
            .toList();
      }
      return challenges;
    } catch (e) {
      print("Error fetching challenges: $e");
      return [];
    }
  }

  bool isUsernameExist(String username, List<String> participantUsernames) {
    return participantUsernames.contains(username);
  }
}