class UserModel {
  final String id;
  final String name;
  final int age;
  final String gym;
  final String goal;
  final String frequency;
  final String? photoUrl;


  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gym,
    required this.goal,
    required this.frequency,
    this.photoUrl
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



    );
  }
}