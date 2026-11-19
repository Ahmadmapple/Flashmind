import 'package:cloud_firestore/cloud_firestore.dart';
import 'flashcard.dart';

class FlashcardSet {
  const FlashcardSet({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.lastStudiedAt,
    this.cards = const <Flashcard>[],
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? lastStudiedAt;
  final List<Flashcard> cards;
  static const int titleMinLength = 3;
  static const int titleMaxLength = 40;
  static const int descriptionMaxLength = 100;

  int get cardCount => cards.length;

  FlashcardSet copyWith({
    String? title,
    String? description,
    DateTime? lastStudiedAt,
    List<Flashcard>? cards,
  }) {
    return FlashcardSet(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      cards: cards ?? this.cards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastStudiedAt': lastStudiedAt != null
          ? Timestamp.fromDate(lastStudiedAt!)
          : null,
    };
  }

  factory FlashcardSet.fromMap(
      Map<String, dynamic> map,
      String id, {
        List<Flashcard> cards = const <Flashcard>[],
      }) {
    final rawCreatedAt = map['createdAt'];
    DateTime createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    final rawLastStudiedAt = map['lastStudiedAt'];
    DateTime? lastStudiedAt;
    if (rawLastStudiedAt is Timestamp) {
      lastStudiedAt = rawLastStudiedAt.toDate();
    } else if (rawLastStudiedAt is String) {
      lastStudiedAt = DateTime.tryParse(rawLastStudiedAt);
    }

    return FlashcardSet(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: createdAt,
      lastStudiedAt: lastStudiedAt,
      cards: cards,
    );
  }
}