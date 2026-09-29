/// Status dari satu sesi belajar.
enum StudySessionStatus {
  inProgress,
  completed,
}

/// Representasi satu kegiatan belajar pada sebuah set flashcard.
class StudySession {
  const StudySession({
    required this.id,
    required this.setId,
    required this.startedAt,
    required this.status,
    this.finishedAt,
    this.cardOrder = const <String>[],
    this.totalDuration = Duration.zero,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.accuracy = 0,
    this.averageCardDuration = Duration.zero,
  });

  final String id;
  final String setId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final StudySessionStatus status;
  final List<String> cardOrder;
  final Duration totalDuration;
  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final Duration averageCardDuration;
}
