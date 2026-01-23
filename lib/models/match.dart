class Match {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;

  Match({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'created_at': createdAt.toIso8601String(),
    };
  }
}