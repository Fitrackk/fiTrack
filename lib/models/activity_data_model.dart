import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityData {
  String username;
  DateTime date;
  double distanceTraveled;
  int stepsCount;
  int activeTime;
  double caloriesBurned;
  Map<String, double> activityTypeDistance;

  ActivityData({
    required this.username,
    required this.date,
    required this.distanceTraveled,
    required this.stepsCount,
    required this.activeTime,
    required this.caloriesBurned,
    required this.activityTypeDistance,
  });

  factory ActivityData.fromFirestore(DocumentSnapshot data) {
    return ActivityData(
      username: data['username'],
      date: DateTime.parse(data['date']),
      distanceTraveled: (data['distanceTraveled'] as num).toDouble(),
      stepsCount: data['stepsCount'] as int,
      activeTime: data['activeTime'] as int,
      caloriesBurned: (data['caloriesBurned'] as num).toDouble(),
      activityTypeDistance:
          Map<String, double>.from(data['activityTypeDistance']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'date': date.toString(),
      'distanceTraveled': distanceTraveled,
      'stepsCount': stepsCount,
      'activeTime': activeTime,
      'caloriesBurned': caloriesBurned,
      'activityTypeDistance': activityTypeDistance,
    };
  }
}
