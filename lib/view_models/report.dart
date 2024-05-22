import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityDataViewModel {
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
      CollectionReference activityDataCollection =
      FirebaseFirestore.instance.collection('ActivityData');
      QuerySnapshot querySnapshot = await activityDataCollection.get();

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

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final dateStr = data['date'];
        final date = dateStr != null ? DateTime.tryParse(dateStr)?.toLocal() : null;
        if (date != null && !date.isBefore(sevenDaysAgo)) {
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
          for (var challenge in challenges.values) {
            if (challenge['challengeDate'] == dateStr &&
                (challenge['participantUsernames'] as List)
                    .contains(data['username'])) {
              challGoal = challenge['challengeName'];
              break;
            }
          }

          int stepsCount = data['stepsCount'] ?? 0;
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
            'caloriesBurned': data['caloriesBurned'] ?? 0,
            'date': dateStr != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr)) : '',
            'distanceTraveled': data['distanceTraveled'] ?? 0,
            'stepsCount': stepsCount,
            'username': data['username'] ?? 'Unknown',
            'day': dayString,
            'challGoal': challGoal,
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
