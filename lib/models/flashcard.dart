/// Representasi satu flashcard yang menjadi bagian dari sebuah set.
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
}
