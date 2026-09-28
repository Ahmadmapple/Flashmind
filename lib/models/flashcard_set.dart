import 'flashcard.dart';

/// Model data untuk satu set flashcard.
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
}
