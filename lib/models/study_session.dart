/// Status dari satu sesi belajar.
enum StudySessionStatus {
  inProgress,
  completed,
}

/// Hasil penilaian satu flashcard dalam sebuah sesi belajar.
class StudyCardResult {
  const StudyCardResult({
    required this.cardId,
    required this.frontShownAt,
    required this.evaluatedAt,
    required this.isCorrect,
    required this.duration,
    this.answerRevealedAt,
  });

  final String cardId;
  final DateTime frontShownAt;
  final DateTime? answerRevealedAt;
  final DateTime evaluatedAt;
  final bool isCorrect;
  final Duration duration;
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
    this.nextCardIndex = 0,
    this.cardResults = const <StudyCardResult>[],
    this.currentCardFrontShownAt,
    this.currentCardAnswerRevealedAt,
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
  final int nextCardIndex;
  final List<StudyCardResult> cardResults;
  final DateTime? currentCardFrontShownAt;
  final DateTime? currentCardAnswerRevealedAt;
  final Duration totalDuration;
  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final Duration averageCardDuration;

  int get completedCardCount => cardResults.length;
  int get totalCardCount => cardOrder.length;

  StudySession copyWith({
    String? id,
    String? setId,
    DateTime? startedAt,
    StudySessionStatus? status,
    DateTime? finishedAt,
    List<String>? cardOrder,
    int? nextCardIndex,
    List<StudyCardResult>? cardResults,
    DateTime? currentCardFrontShownAt,
    DateTime? currentCardAnswerRevealedAt,
    bool clearFinishedAt = false,
    bool clearCurrentCardFrontShownAt = false,
    bool clearCurrentCardAnswerRevealedAt = false,
    Duration? totalDuration,
    int? correctCount,
    int? wrongCount,
    double? accuracy,
    Duration? averageCardDuration,
  }) {
    return StudySession(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      startedAt: startedAt ?? this.startedAt,
      status: status ?? this.status,
      finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
      cardOrder: cardOrder ?? this.cardOrder,
      nextCardIndex: nextCardIndex ?? this.nextCardIndex,
      cardResults: cardResults ?? this.cardResults,
      currentCardFrontShownAt: clearCurrentCardFrontShownAt
          ? null
          : (currentCardFrontShownAt ?? this.currentCardFrontShownAt),
      currentCardAnswerRevealedAt: clearCurrentCardAnswerRevealedAt
          ? null
          : (currentCardAnswerRevealedAt ?? this.currentCardAnswerRevealedAt),
      totalDuration: totalDuration ?? this.totalDuration,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      accuracy: accuracy ?? this.accuracy,
      averageCardDuration: averageCardDuration ?? this.averageCardDuration,
    );
  }
}