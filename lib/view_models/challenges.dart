import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/models/challenge_model.dart';
import 'package:fitrack/view_models/user.dart';
import '../models/user_model.dart';

class ChallengesVM {

  Future<List<Challenge>> getChallengeData({String? filter}) async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("challenges").get();

      List<Challenge> challenges = querySnapshot.docs.map((doc) {
        return Challenge.fromFirestore(doc);
      }).toList();



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
}