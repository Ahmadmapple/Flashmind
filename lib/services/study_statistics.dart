import '../models/study_session.dart';

// Penggabungan ringkasan dari kumpulan sesi selesai.
class StudyStatistics {
  const StudyStatistics._();

  // Jumlah seluruh kartu yang sudah dinilai.
  static int totalCards(Iterable<StudySession> sessions) =>
      sessions.fold<int>(0, (sum, s) => sum + s.completedCardCount);

  // Jumlah seluruh durasi pengerjaan.
  static Duration totalDuration(Iterable<StudySession> sessions) =>
      sessions.fold<Duration>(Duration.zero, (sum, s) => sum + s.totalDuration);

  // Rata-rata tingkat kebenaran per sesi (0 bila tidak ada sesi).
  static double averageAccuracy(Iterable<StudySession> sessions) {
    final List<StudySession> list = sessions.toList(growable: false);
    if (list.isEmpty) return 0;
    return list.fold<double>(0, (sum, s) => sum + s.accuracy) / list.length;
  }

  static SessionSummary summarize(Iterable<StudySession> sessions) {
    final List<StudySession> list = sessions.toList(growable: false);
    return SessionSummary(
      sessionCount: list.length,
      cardCount: totalCards(list),
      totalDuration: totalDuration(list),
      accuracy: averageAccuracy(list),
      correctCount: list.fold<int>(0, (sum, s) => sum + s.correctCount),
      wrongCount: list.fold<int>(0, (sum, s) => sum + s.wrongCount),
    );
  }
}

// Hasil ringkasan satu kumpulan yang dibutuhkan untuk layar Statistik
class SessionSummary {
  const SessionSummary({
    required this.sessionCount,
    required this.cardCount,
    required this.totalDuration,
    required this.accuracy,
    required this.correctCount,
    required this.wrongCount,
  });

  final int sessionCount;
  final int cardCount;
  final Duration totalDuration;

  // Rata-rata tingkat kebenaran per sesi.
  final double accuracy;
  final int correctCount;
  final int wrongCount;

  int get answeredCount => correctCount + wrongCount;

  int get correctPercent =>
      answeredCount == 0 ? 0 : (correctCount / answeredCount * 100).round();

  int get wrongPercent => answeredCount == 0 ? 0 : 100 - correctPercent;

  double get correctFraction =>
      answeredCount == 0 ? 0 : correctCount / answeredCount;

  Duration get averageDurationPerSession => sessionCount == 0
      ? Duration.zero
      : Duration(microseconds: totalDuration.inMicroseconds ~/ sessionCount);

  Duration get averageDurationPerCard => cardCount == 0
      ? Duration.zero
      : Duration(microseconds: totalDuration.inMicroseconds ~/ cardCount);
}