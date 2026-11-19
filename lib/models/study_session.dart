import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _parseDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

enum StudySessionStatus {
  inProgress,
  completed,
}

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

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'frontShownAt': Timestamp.fromDate(frontShownAt),
      'answerRevealedAt': answerRevealedAt != null
          ? Timestamp.fromDate(answerRevealedAt!)
          : null,
      'evaluatedAt': Timestamp.fromDate(evaluatedAt),
      'isCorrect': isCorrect,
      'durationMicros': duration.inMicroseconds,
    };
  }

  factory StudyCardResult.fromMap(Map<String, dynamic> map) {
    return StudyCardResult(
      cardId: map['cardId'] as String? ?? '',
      frontShownAt: _parseDateTime(map['frontShownAt']),
      answerRevealedAt: _parseNullableDateTime(map['answerRevealedAt']),
      evaluatedAt: _parseDateTime(map['evaluatedAt']),
      isCorrect: map['isCorrect'] as bool? ?? false,
      duration: Duration(
        microseconds: (map['durationMicros'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

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
    this.currentCardElapsedDuration = Duration.zero,
    this.lastPausedAt,
    this.totalDuration = Duration.zero,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.accuracy = 0,
    this.averageCardDuration = Duration.zero,
    this.setTitle,
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
  final Duration currentCardElapsedDuration;
  final DateTime? lastPausedAt;
  final Duration totalDuration;
  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final Duration averageCardDuration;
  final String? setTitle;

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
    Duration? currentCardElapsedDuration,
    DateTime? lastPausedAt,
    bool clearFinishedAt = false,
    bool clearCurrentCardFrontShownAt = false,
    bool clearCurrentCardAnswerRevealedAt = false,
    bool clearLastPausedAt = false,
    Duration? totalDuration,
    int? correctCount,
    int? wrongCount,
    double? accuracy,
    Duration? averageCardDuration,
    String? setTitle,
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
      currentCardElapsedDuration:
      currentCardElapsedDuration ?? this.currentCardElapsedDuration,
      lastPausedAt: clearLastPausedAt ? null : (lastPausedAt ?? this.lastPausedAt),
      totalDuration: totalDuration ?? this.totalDuration,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      accuracy: accuracy ?? this.accuracy,
      averageCardDuration: averageCardDuration ?? this.averageCardDuration,
      setTitle: setTitle ?? this.setTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setId': setId,
      'startedAt': Timestamp.fromDate(startedAt),
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
      'status': status.name,
      'cardOrder': cardOrder,
      'nextCardIndex': nextCardIndex,
      'cardResults': cardResults.map((r) => r.toMap()).toList(),
      'currentCardFrontShownAt': currentCardFrontShownAt != null
          ? Timestamp.fromDate(currentCardFrontShownAt!)
          : null,
      'currentCardAnswerRevealedAt': currentCardAnswerRevealedAt != null
          ? Timestamp.fromDate(currentCardAnswerRevealedAt!)
          : null,
      'currentCardElapsedMicros': currentCardElapsedDuration.inMicroseconds,
      'lastPausedAt': lastPausedAt != null
          ? Timestamp.fromDate(lastPausedAt!)
          : null,
      'totalDurationMicros': totalDuration.inMicroseconds,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'accuracy': accuracy,
      'averageCardDurationMicros': averageCardDuration.inMicroseconds,
      'setTitle': setTitle,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map, String id) {
    final statusName = map['status'] as String?;
    final status = statusName == StudySessionStatus.completed.name
        ? StudySessionStatus.completed
        : StudySessionStatus.inProgress;

    final rawOrder = map['cardOrder'] as List<dynamic>? ?? const <dynamic>[];
    final cardOrder = rawOrder.map((e) => e.toString()).toList();

    final rawResults =
        map['cardResults'] as List<dynamic>? ?? const <dynamic>[];
    final cardResults = rawResults
        .whereType()
        .map((e) => StudyCardResult.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    return StudySession(
      id: id,
      setId: map['setId'] as String? ?? '',
      startedAt: _parseDateTime(map['startedAt']),
      finishedAt: _parseNullableDateTime(map['finishedAt']),
      status: status,
      cardOrder: cardOrder,
      nextCardIndex: (map['nextCardIndex'] as num?)?.toInt() ?? 0,
      cardResults: cardResults,
      currentCardFrontShownAt:
      _parseNullableDateTime(map['currentCardFrontShownAt']),
      currentCardAnswerRevealedAt:
      _parseNullableDateTime(map['currentCardAnswerRevealedAt']),
      currentCardElapsedDuration: Duration(
        microseconds: (map['currentCardElapsedMicros'] as num?)?.toInt() ?? 0,
      ),
      lastPausedAt: _parseNullableDateTime(map['lastPausedAt']),
      totalDuration: Duration(
        microseconds: (map['totalDurationMicros'] as num?)?.toInt() ?? 0,
      ),
      correctCount: (map['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (map['wrongCount'] as num?)?.toInt() ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      averageCardDuration: Duration(
        microseconds: (map['averageCardDurationMicros'] as num?)?.toInt() ?? 0,
      ),
      setTitle: map['setTitle'] as String?,
    );
  }
}
