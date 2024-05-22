import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/challenge_progress.dart';
import '../models/user_model.dart';

class ActivityDataViewModel {
  final UserVM _userVM = UserVM();
  late User? currentUser;

  TimeOfDay stringToTimeOfDay(String timeString) {
    int time = int.tryParse(timeString) ?? 0;
    int hours;
    int minutes;
    if (time < 60) {
      hours = 0;
      minutes = time;
    } else {
      hours = time ~/ 60;
      minutes = time - (hours * 60);
    }
    return TimeOfDay(hour: hours, minute: minutes);
  }

  Future<Map<String, dynamic>> fetchActivityData() async {
    try {
      final User? currentUser = await _userVM.getUserData();
      String? username = currentUser?.userName;
      CollectionReference activityDataCollection =
          FirebaseFirestore.instance.collection('ActivityData');
      QuerySnapshot querySnapshot = await activityDataCollection
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No documents found in the ActivityData collection.');
        return {'activityData': [], 'maxStepsCount': 0};
      }

      CollectionReference challengesCollection =
          FirebaseFirestore.instance.collection('challenges');
      QuerySnapshot challengesSnapshot = await challengesCollection.get();

      Map<String, dynamic> challenges = {
        for (var doc in challengesSnapshot.docs)
          doc.id: doc.data() as Map<String, dynamic>
      };

      DateTime now = DateTime.now();
      DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

      List<Map<String, dynamic>> activityData = [];
      int maxStepsCount = 0;
      Set<String> addedDates = Set<String>(); // Keep track of unique dates

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final dateStr = data['date'];
        final date =
            dateStr != null ? DateTime.tryParse(dateStr)?.toLocal() : null;
        if (date != null && !date.isBefore(sevenDaysAgo)) {
          // Check if date has already been added
          if (addedDates.contains(dateStr)) {
            continue; // Skip duplicate date
          }
          addedDates.add(dateStr); // Add date to set of added dates

          final day = date.weekday;
          String dayString;
          switch (day) {
            case 1:
              dayString = 'Mon';
              break;
            case 2:
              dayString = 'Tue';
              break;
            case 3:
              dayString = 'Wed';
              break;
            case 4:
              dayString = 'Thu';
              break;
            case 5:
              dayString = 'Fri';
              break;
            case 6:
              dayString = 'Sat';
              break;
            case 7:
              dayString = 'Sun';
              break;
            default:
              dayString = 'Unknown';
          }
          String challGoal = 'No Challenge';
          late int challengeId = 12345678;
          for (var challenge in challenges.values) {
            if (challenge['challengeDate'] == dateStr.substring(0, 10) &&
                (challenge['participantUsernames'] as List)
                    .contains(data['username'])) {
              challGoal = challenge['challengeName'];
              challengeId = challenge['challengeId'];
              break;
            }
          }

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('challengeProgress')
              .where('challengeId', isEqualTo: challengeId)
              .get();

          var progress = querySnapshot.docs.map((doc) {
            return ChallengeProgress.fromFirestore(doc);
          }).toList();
          double? progressValue;
          if (progress.isNotEmpty) {
            ChallengeProgress challengeProgress =
                progress.firstWhere((p) => p.challengeId == challengeId);
            progressValue = challengeProgress.progress;
          } else {
            print('No challenge progress found for challengeId: $challengeId');
          }

          num progressVal = progressValue is double
              ? progressValue
              : double.tryParse(progressValue?.toString() ?? '0') ?? 0;
          int stepsCount = data['stepsCount'] is int
              ? data['stepsCount']
              : int.tryParse(data['stepsCount']?.toString() ?? '0') ?? 0;
          double caloriesBurned = data['caloriesBurned'] is double
              ? data['distanceTraveled']
              : double.tryParse(data['distanceTraveled']?.toString() ?? '0') ??
                  0.0;
          double distanceTraveled = data['distanceTraveled'] is double
              ? data['distanceTraveled']
              : double.tryParse(data['distanceTraveled']?.toString() ?? '0') ??
                  0.0;
          if (stepsCount > maxStepsCount) {
            maxStepsCount = stepsCount;
          }

          activityData.add({
            'id': doc.id,
            'activeTime': data['activeTime']?.toString() ?? '0',
            'activityTypeDistance': {
              'jogging': data['activityTypeDistance']?['jogging'] ?? 0,
              'running': data['activityTypeDistance']?['running'] ?? 0,
              'walking': data['activityTypeDistance']?['walking'] ?? 0,
            },
            'caloriesBurned': caloriesBurned,
            'date': dateStr != null
                ? DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr))
                : '',
            'distanceTraveled': distanceTraveled,
            'stepsCount': stepsCount,
            'username': data['username'] ?? 'Unknown',
            'day': dayString,
            'challGoal': challGoal,
            'progress': progressVal,
          });
        }
      }

      return {'activityData': activityData, 'maxStepsCount': maxStepsCount};
    } catch (e) {
      print('Error fetching activity data: $e');
      return {'activityData': [], 'maxStepsCount': 0};
    }
  }
}
