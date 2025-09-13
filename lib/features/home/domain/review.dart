import 'dart:convert';

class Review {
  final String authorName;
  final int rating;
  final String content;
  final DateTime createdAt;

  Review({
    required this.authorName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'authorName': authorName,
        'rating': rating,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        authorName: json['authorName'] as String? ?? '-',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        content: json['content'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  static String encodeList(List<Review> list) => jsonEncode(list.map((e) => e.toJson()).toList());
  static List<Review> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final data = jsonDecode(raw) as List<dynamic>;
      return data.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
