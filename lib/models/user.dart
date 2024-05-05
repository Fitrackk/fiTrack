import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? fullName;
  String? email;
  String? username;
  int? age;
  String? gender;
  double? weight;
  double? height;
  double? score;
  String? dateOfBirth;

  User({
    required this.fullName,
    required this.email,
    required this.username,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.score,
    required this.dateOfBirth,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    return User(
      fullName: doc['fullName'] ?? '',
      email: doc['email'] ?? '',
      username: doc['username'] ?? '',
      age: calculateAge(doc['dateOfBirth']),
      gender: doc['gender'] ?? '',
      weight: doc['weight'] ?? 40.0,
      height: doc['height'] ?? 150.0,
      score: doc['score'] ?? 10.0,
      dateOfBirth: doc['dateOfBirth'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'username': username,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'score': score,
      'dateOfBirth': dateOfBirth,
    };
  }

  static int calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return 0;

    DateTime today = DateTime.now();
    DateTime birthDate = DateTime.parse(dob);
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
