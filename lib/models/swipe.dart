enum SwipeDirection { left, right }

class Swipe {
  final String id;
  final String swiperId;
  final String swipedId;
  final SwipeDirection direction;
  final DateTime createdAt;

  Swipe({
    required this.id,
    required this.swiperId,
    required this.swipedId,
    required this.direction,
    required this.createdAt,
  });

  factory Swipe.fromJson(Map<String, dynamic> json) {
    return Swipe(
      id: json['id'] as String,
      swiperId: json['swiper_id'] as String,
      swipedId: json['swiped_id'] as String,
      direction: SwipeDirection.values[json['direction'] as int],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'swiper_id': swiperId,
      'swiped_id': swipedId,
      'direction': direction.index,
      'created_at': createdAt.toIso8601String(),
    };
  }
}