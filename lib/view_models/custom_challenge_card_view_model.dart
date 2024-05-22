import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/challenge_model.dart';
import '../../models/user_model.dart';
import '../../view_models/user.dart';

class CustomChallengeCardViewModel {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    final UserVM userVM = UserVM();
    return await userVM.getUserData();
  }

  Future<void> joinChallenge(String challengeName, String challengeDate, String username, Function(bool) updateState) async {
    try {
      final QuerySnapshot querySnapshot = await firestore
          .collection('challenges')
          .where('challengeName', isEqualTo: challengeName)
          .where('challengeDate', isEqualTo: challengeDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Challenge challenge = Challenge.fromFirestore(doc);
          if (!challenge.participantUsernames.contains(username)) {
            List<String> updatedUsernames = List.from(challenge.participantUsernames)..add(username);
            await doc.reference.update({'participantUsernames': updatedUsernames});
            updateState(true);
          }
        }
      } else {
        print("No matching challenge found");
      }
    } catch (error) {
      print("Error joining challenge: $error");
    }
  }

  Future<void> unjoinChallenge(String challengeName, String challengeDate, String username, Function(bool) updateState) async {
    try {
      final QuerySnapshot querySnapshot = await firestore
          .collection('challenges')
          .where('challengeName', isEqualTo: challengeName)
          .where('challengeDate', isEqualTo: challengeDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Challenge challenge = Challenge.fromFirestore(doc);
          if (challenge.participantUsernames.contains(username)) {
            List<String> updatedUsernames = List.from(challenge.participantUsernames)..remove(username);
            await doc.reference.update({'participantUsernames': updatedUsernames});
            updateState(false);
          }
        }
      } else {
        print("No matching challenge found");
      }
    } catch (error) {
      print("Error unjoining challenge: $error");
    }
  }
}
