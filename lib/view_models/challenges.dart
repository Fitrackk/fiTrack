import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitrack/configures/text_style.dart';
import 'package:fitrack/models/challenge_model.dart';
import 'package:fitrack/view_models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../configures/color_theme.dart';
import '../models/challenge_progress.dart';
import '../models/user_model.dart';

class ChallengesVM {
  final UserVM _userVM = UserVM();
  User? currentUser;
  String? username;
  final Random _random = Random();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    final UserVM userVM = UserVM();
    return await userVM.getUserData();
  }

  Future<int> generateUniqueChallengeId() async {
    late int challengeId;
    bool exists = true;

    while (exists) {
      challengeId = _random.nextInt(100000000);
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
          await FirebaseFirestore.instance.collection('challenges').get();

      List<Challenge> challenges = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Challenge challenge = Challenge.fromFirestore(doc);
        List<String> participantUsernames = challenge.participantUsernames;

        List<String> participantImages = [];
        for (String username in participantUsernames) {
          // Fetch user data for each participant by username
          User? participantData = await _userVM.getUserByUsername(username);
          if (participantData != null) {
            participantImages.add(participantData.profileImageUrl ?? "");
          } else {
            // If user data not found, use placeholder or default image
            participantImages.add("");
          }
        }

        challenge.participantImages = participantImages;
        challenges.add(challenge);
      }

      if (filter != null && filter.isNotEmpty) {
        challenges = challenges
            .where((challenge) =>
                challenge.activityType.toLowerCase() == filter.toLowerCase())
            .toList();
      }
      return challenges;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching challenges: $e");
      }
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
      if (kDebugMode) {
        print("Error fetching challenges: $e");
      }
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
      if (kDebugMode) {
        print("Error fetching challenge progress: $e");
      }
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
        Navigator.pushReplacementNamed(context, '/signing');
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
          SnackBar(
            content: Text(
              'You already have a challenge on this date.',
              style: TextStyles.bodySmallBold.copyWith(color: FitColors.text95),
            ),
            backgroundColor: FitColors.tertiary50,
          ),
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
        'participantImages': [currentUser?.profileImageUrl ?? ""]
      });

      addChallengeProgress(username!, activityType!, double.parse(distance),
          date, 0, challengeId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Challenge created successfully!',
            style: TextStyles.bodySmallBold.copyWith(color: FitColors.text95),
          ),
          backgroundColor: FitColors.tertiary50,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create challenge: $e',
            style: TextStyles.bodySmallBold.copyWith(color: FitColors.error40),
          ),
          backgroundColor: FitColors.tertiary50,
        ),
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

      final docId = '${challengeId}_$username';

      await FirebaseFirestore.instance
          .collection('challengeProgress')
          .doc(docId)
          .set(challengeProgress.toFirestore());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add challenge progress: $e');
      }
    }
  }

  Future<void> joinChallengeById(BuildContext context, String id) async {
    try {
      currentUser = await _userVM.getUserData();
      if (currentUser == null) {
        Navigator.pushReplacementNamed(context, '/signing');
        return;
      }

      username = currentUser!.userName;
      String? userImage = currentUser!.profileImageUrl;

      int challengeId = int.parse(id);

      QuerySnapshot challengeSnapshot = await _firestore
          .collection('challenges')
          .where('challengeId', isEqualTo: challengeId)
          .get();

      if (challengeSnapshot.docs.isNotEmpty) {
        DocumentSnapshot challengeDoc = challengeSnapshot.docs.first;

        String challengeDate = challengeDoc['challengeDate'];

        if (DateTime.parse(challengeDate).isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sorry, you cannot join this challenge as its date has already passed.',
                style:
                    TextStyles.bodySmallBold.copyWith(color: FitColors.error40),
              ),
              backgroundColor: FitColors.tertiary50,
            ),
          );
          return;
        }
        int participations = challengeDoc['participations'];
        List<dynamic> participantUsernames =
            challengeDoc['participantUsernames'];
        if (participantUsernames.length >= participations) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sorry, this challenge is already full.',
                style:
                    TextStyles.bodySmallBold.copyWith(color: FitColors.error40),
              ),
              backgroundColor: FitColors.tertiary50,
            ),
          );
          return;
        }

        bool hasChallenge = await hasChallengeOnDate(username!, challengeDate);
        if (hasChallenge) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sorry, you already have a challenge on this date.',
                style:
                    TextStyles.bodySmallBold.copyWith(color: FitColors.error40),
              ),
              backgroundColor: FitColors.tertiary50,
            ),
          );
          return;
        }

        await _firestore.collection('challenges').doc(challengeDoc.id).update({
          'participantUsernames': FieldValue.arrayUnion([username]),
          'participantImages': FieldValue.arrayUnion([userImage]),
        });

        await addChallengeProgress(
          username!,
          challengeDoc['activityType'],
          challengeDoc['distance'],
          challengeDate,
          0,
          challengeId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully joined the challenge!',
              style: TextStyles.bodySmallBold.copyWith(color: FitColors.text95),
            ),
            backgroundColor: FitColors.tertiary50,
          ),
        );
      } else {
        throw Exception('Challenge not found');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error joining challenge: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to join challenge: $e',
            style: TextStyles.bodySmallBold.copyWith(color: FitColors.error40),
          ),
          backgroundColor: FitColors.tertiary50,
        ),
      );
    }
  }

  Future<void> joinChallenge(BuildContext context, String challengeName,
      String challengeDate, String username, Function(bool) updateState) async {
    try {
      currentUser = await _userVM.getUserData();
      if (currentUser == null) {
        Navigator.pushReplacementNamed(context, '/signing');
        return;
      }

      username = currentUser!.userName!;
      String? userImage = currentUser!.profileImageUrl;

      final QuerySnapshot querySnapshot = await _firestore
          .collection('challenges')
          .where('challengeName', isEqualTo: challengeName)
          .where('challengeDate', isEqualTo: challengeDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Challenge challenge = Challenge.fromFirestore(doc);

          // Check if challenge date has passed
          if (DateTime.parse(challenge.challengeDate)
              .isBefore(DateTime.now())) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sorry, you cannot join this challenge as its date has already passed.',
                  style: TextStyles.bodySmallBold
                      .copyWith(color: FitColors.error40),
                ),
                backgroundColor: FitColors.tertiary50,
              ),
            );
            return;
          }

          // Check if the challenge is already full
          if (challenge.participantUsernames.length >=
              challenge.participations) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sorry, this challenge is already full.',
                  style: TextStyles.bodySmallBold
                      .copyWith(color: FitColors.error40),
                ),
                backgroundColor: FitColors.tertiary50,
              ),
            );
            return;
          }

          // Check if the user already has a challenge on this date
          bool hasChallenge = await hasChallengeOnDate(username, challengeDate);
          if (hasChallenge) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sorry, you already have a challenge on this date.',
                  style: TextStyles.bodySmallBold
                      .copyWith(color: FitColors.error40),
                ),
                backgroundColor: FitColors.tertiary50,
              ),
            );
            return;
          }

          // Join the challenge if all validations pass
          if (!challenge.participantUsernames.contains(username)) {
            List<String> updatedUsernames =
                List.from(challenge.participantUsernames)..add(username);
            List<String> updatedImages = List.from(challenge.participantImages)
              ..add(userImage!);

            await doc.reference.update({
              'participantUsernames': updatedUsernames,
              'participantImages': updatedImages,
            });

            await addChallengeProgress(
              username,
              challenge.activityType,
              challenge.distance,
              challenge.challengeDate,
              0,
              challenge.challengeId,
            );

            updateState(true);
          }
        }
      } else {
        if (kDebugMode) {
          print("No matching challenge found");
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error joining challenge: $error");
      }
    }
  }

  Future<void> unjoinChallenge(BuildContext context, String challengeName,
      String challengeDate, String username, Function(bool) updateState) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('challenges')
          .where('challengeName', isEqualTo: challengeName)
          .where('challengeDate', isEqualTo: challengeDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Challenge challenge = Challenge.fromFirestore(doc);

          // Check if the user is a participant
          if (challenge.participantUsernames.contains(username)) {
            // Prevent the challenge owner from unjoining
            if (username == challenge.challengeOwner) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Sorry, you are the challenge owner and cannot leave your own challenge.',
                    style: TextStyles.bodySmallBold
                        .copyWith(color: FitColors.error40),
                  ),
                  backgroundColor: FitColors.tertiary50,
                ),
              );
              return;
            }

            int index = challenge.participantUsernames.indexOf(username);

            if (index != -1 && index < challenge.participantUsernames.length) {
              // Remove the username and the corresponding image if they exist at the same index
              List<String> updatedUsernames =
                  List.from(challenge.participantUsernames);
              updatedUsernames.removeAt(index);

              List<String> updatedImages =
                  List.from(challenge.participantImages);
              if (index < updatedImages.length) {
                updatedImages.removeAt(index);
              }
              // Delete the progress document associated with the user
              await FirebaseFirestore.instance
                  .collection('challengeProgress')
                  .doc('${challenge.challengeId}_$username')
                  .delete();

              await doc.reference.update({
                'participantUsernames': updatedUsernames,
                'participantImages': updatedImages,
              });

              updateState(false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Successfully unjoined the challenge!',
                    style: TextStyles.bodySmallBold
                        .copyWith(color: FitColors.text95),
                  ),
                  backgroundColor: FitColors.tertiary50,
                ),
              );
            } else {
              throw Exception('User not found in participants');
            }
          }
        }
      } else {
        if (kDebugMode) {
          print("No matching challenge found");
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error unjoining challenge: $error");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to unjoin challenge: $error',
            style: TextStyles.bodySmallBold.copyWith(color: FitColors.error40),
          ),
          backgroundColor: FitColors.tertiary50,
        ),
      );
    }
  }

  Future<void> deleteOldChallenges() async {
    final DateTime currentDate = DateTime.now();
    final DateTime thresholdDate = currentDate.subtract(Duration(days: 30));

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('challenges').get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        String challengeDateString = doc['challengeDate'];
        DateTime challengeDate =
            DateFormat('yyyy-MM-dd').parse(challengeDateString);

        if (challengeDate.isBefore(thresholdDate)) {
          await _firestore.collection('challenges').doc(doc.id).delete();
        }
      }

      if (kDebugMode) {
        print('Old challenges deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting old challenges: $e');
      }
    }
  }
}
