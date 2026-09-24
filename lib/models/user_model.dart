import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final int age;
  final String gym;
  final String goal;
  final String frequency;
  final String? photoUrl;
  final DateTime? dob;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gym,
    required this.goal,
    required this.frequency,
    this.photoUrl,
    this.dob,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gym: data['gym'] ?? '',
      goal: data['goal'] ?? '',
      frequency: data['frequency'] ?? '',
      photoUrl: data['photoUrl'],
      dob: data['dob'] != null ? (data['dob'] as Timestamp).toDate() : null,
    );
  }
}