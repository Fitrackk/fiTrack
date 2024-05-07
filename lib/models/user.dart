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

  User({
    required this.fullName,
    required this.email,
    required this.username,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.score,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    return User(
      fullName: doc['fullName'] ?? '',
      email: doc['email'] ?? '',
      username: doc['username'] ?? '',
      age: doc['age'] ?? 18,
      gender: doc['gender'] ?? '',
      weight: doc['weight'] ?? 40.0,
      height: doc['height'] ?? 150.0,
      score: doc['score'] ?? 10.0,
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
    };
  }
}
