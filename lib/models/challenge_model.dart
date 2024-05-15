import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String activityType;
  final String challengeDate;
  final int challengeId;
  final String challengeName;
  final String challengeOwner;
  final double distance;
  final List<String> participantUsernames;
  final int participations;
  // final List<Timestamp> remindersTimes;

  Challenge({
    required this.activityType,
    required this.challengeDate,
    required this.challengeId,
    required this.challengeName,
    required this.challengeOwner,
    required this.distance,
    required this.participantUsernames,
    required this.participations,
    // required this.remindersTimes,
  });

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Challenge(
      activityType: data['activityType'] ?? '',
      challengeDate: data['challengeDate'],
      challengeId: data['challengeId'] ?? '',
      challengeName: data['challengeName'] ?? '',
      challengeOwner: data['challengeOwner'] ?? '',
      distance: (data['distance'] ?? 0).toDouble(),
      participantUsernames: List<String>.from(data['participantUsernames'] ?? []),
      participations: (data['participations'] ?? 0).toInt(),
      // remindersTimes: [(data['remindersTimes'])],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'activityType': activityType,
      'challengeDate': challengeDate,
      'challengeId': challengeId,
      'challengeName': challengeName,
      'challengeOwner': challengeOwner,
      'distance': distance,
      'participantUsernames': participantUsernames,
      'participations': participations,
    };
  }

}