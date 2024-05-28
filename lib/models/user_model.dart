import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? fullName;
  String? email;
  String? userName;
  int? age;
  String? gender;
  double? weight;
  double? height;
  double? score;
  String? dateOfBirth;
  String? profileImageUrl;

  User({
    required this.fullName,
    required this.email,
    required this.userName,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.score,
    required this.dateOfBirth,
    this.profileImageUrl,
  });

  factory User.fromFirestore(DocumentSnapshot data) {
    return User(
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      userName: data['username'] ?? '',
      age: data['age'],
      gender: data['gender'] ?? '',
      weight: (data['weight'] ?? 40).toDouble(),
      height: (data['height'] ?? 150).toDouble(),
      score: (data['score'] ?? 10).toDouble(),
      dateOfBirth: data['dateOfBirth'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? 'assets/images/unknown.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'username': userName,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'score': score,
      'dateOfBirth': dateOfBirth,
      'profileImageUrl': profileImageUrl,
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
