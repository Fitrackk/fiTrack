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
  final String reminder;
  List<String> participantImages;

  Challenge({
    required this.activityType,
    required this.challengeDate,
    required this.challengeId,
    required this.challengeName,
    required this.challengeOwner,
    required this.distance,
    required this.participantUsernames,
    required this.participations,
    required this.reminder,
    required this.participantImages,
  });

  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Challenge(
      activityType: data['activityType'] ?? '',
      challengeDate: data['challengeDate'] ?? '',
      challengeId: data['challengeId'] ?? 0,
      challengeName: data['challengeName'] ?? '',
      challengeOwner: data['challengeOwner'] ?? '',
      distance: (data['distance'] is int)
          ? (data['distance'] as int).toDouble()
          : (data['distance'] as double? ?? 0.0),
      participantUsernames:
          List<String>.from(data['participantUsernames'] ?? []),
      participations: (data['participations'] ?? 0).toInt(),
      reminder: data['reminder'] ?? '',
      participantImages: List<String>.from(data['participantImages'] ?? []),
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
      'reminder': reminder,
      'participantImages': participantImages
    };
  }
}
