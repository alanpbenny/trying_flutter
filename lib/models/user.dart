class User {
  final String id;
  final String name;
  final String gym;
  final String goal;
  final String frequency;
  final String? bio;
  final String? profileImageUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.gym,
    required this.goal,
    required this.frequency,
    this.bio,
    this.profileImageUrl,
    required this.createdAt,
  });

  // Create User from Supabase data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      gym: json['gym'] as String,
      goal: json['goal'] as String,
      frequency: json['frequency'] as String,
      bio: json['bio'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert User to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gym': gym,
      'goal': goal,
      'frequency': frequency,
      'bio': bio,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? gym,
    String? goal,
    String? frequency,
    String? bio,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      gym: gym ?? this.gym,
      goal: goal ?? this.goal,
      frequency: frequency ?? this.frequency,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Global user instance
User? currentUser;

// Global matches list
List<Map<String, String>> matches = [];