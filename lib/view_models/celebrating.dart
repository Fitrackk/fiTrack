import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/activity_data_model.dart';
import '../models/challenge_progress.dart';
import '../models/user_model.dart';
import '../views/celebrating_dialog.dart';

class CelebratingDialogVM {
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

  Future<int> getTodaySteps(String username) async {
    try {
      DateTime now = DateTime.now();
      String todayDate = "${now.year}-${now.month}-${now.day}";
      String documentId = "$username-$todayDate";
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('ActivityData')
          .doc(documentId)
          .get();
      if (docSnapshot.exists) {
        ActivityData activityData = ActivityData.fromFirestore(docSnapshot);
        return activityData.stepsCount;
      } else {
        print("Document not found for today's date: $todayDate");
        return 0;
      }
    } catch (e) {
      print("Error fetching steps count: $e");
      return 0;
    }
  }

  Future<bool> checkIfDialogShownToday(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().split('T').first;
    return prefs.getBool('${key}_$today') ?? false;
  }

  Future<void> setDialogShownForToday(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().split('T').first;
    await prefs.setBool('${key}_$today', true);
  }

  Future<void> checkAndShowCelebratingDialog(
      int challengeId, BuildContext context) async {
    final UserVM userVM = UserVM();
    final User? currentUser = await userVM.getUserData();
    String? username = currentUser?.userName;

    bool challengeDialogShown = await checkIfDialogShownToday(
        'challenge_dialog_${DateTime.now().toIso8601String().split('T').first}');
    if (!challengeDialogShown) {
      List<ChallengeProgress> progress =
          await getChallengeProgress(challengeId);
      if (progress.isNotEmpty && progress.first.progress == 100) {
        showCelebratingDialog(
          context,
          'Congratulations!',
          'You have successfully completed\n your today challenge!!',
        );
        await setDialogShownForToday(
            'challenge_dialog_${DateTime.now().toIso8601String().split('T').first}');
        return;
      }
    }

    bool stepsDialogShown = await checkIfDialogShownToday(
        'steps_dialog_${DateTime.now().toIso8601String().split('T').first}');
    if (!stepsDialogShown) {
      int steps = await getTodaySteps(username!);
      if (steps >= 10000) {
        showCelebratingDialog(
          context,
          'Congratulations!',
          'You have successfully reached\n 10,000 steps today!',
        );
        await setDialogShownForToday(
            'steps_dialog_${DateTime.now().toIso8601String().split('T').first}');
      }
    }
  }
}
