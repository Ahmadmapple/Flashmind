import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  const Flashcard({
    required this.id,
    required this.setId,
    required this.frontText,
    required this.backText,
    required this.createdAt,
  });

  final String id;
  final String setId;
  final String frontText;
  final String backText;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'setId': setId,
      'frontText': frontText,
      'backText': backText,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map, String id) {
    final rawCreatedAt = map['createdAt'];
    DateTime createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Flashcard(
      id: id,
      setId: map['setId'] as String? ?? '',
      frontText: map['frontText'] as String? ?? '',
      backText: map['backText'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}
