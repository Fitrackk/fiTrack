import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeProgress {
  String username;
  String activityType;
  double distance;
  String challengeDate;
  double progress;
  int challengeId;

  ChallengeProgress({
    required this.username,
    required this.activityType,
    required this.distance,
    required this.challengeDate,
    required this.progress,
    required this.challengeId,
  });

  factory ChallengeProgress.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ChallengeProgress(
      username: data['username'] ?? '',
      activityType: data['activityType'] ?? '',
      distance: data['distance']?.toDouble() ?? 0.0,
      challengeDate: data['challengeDate'],
      progress: data['progress']?.toDouble() ?? 0.0,
      challengeId: data['challengeId'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'activityType': activityType,
      'distance': distance,
      'challengeDate': challengeDate,
      'progress': progress,
      'challengeId': challengeId,
    };
  }
}
