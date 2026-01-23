class User {
  String name;
  String gym;
  String goal;
  String frequency;

  User({
    required this.name,
    required this.gym,
    required this.goal,
    required this.frequency,
  });
}

// Global user instance
User? currentUser;

// Global matches list
List<Map<String, String>> matches = [];