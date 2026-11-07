import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

// Logika rekomendasi set pada filter "Perlu Diulas".
// ulasan ke-1     -> muncul lagi setelah 1 hari
// ulasan ke-2     -> muncul lagi setelah 3 hari
// ulasan ke-3 dst -> muncul lagi setiap 7 hari
class ReviewRecommendation {
  const ReviewRecommendation._();

  /// Jeda sampai set muncul kembali, berdasarkan jumlah ulasan yang sudah dihitung.
  static Duration intervalAfterReview(int reviewCount) {
    if (reviewCount <= 1) return const Duration(days: 1);
    if (reviewCount == 2) return const Duration(days: 3);
    return const Duration(days: 7);
  }

  static DateTime? nextReviewAt(List<StudySession> completedSessions) {
    if (completedSessions.isEmpty) return null;

    final sorted = List<StudySession>.from(completedSessions)
      ..sort((a, b) => _endOf(a).compareTo(_endOf(b)));

    int reviews = 0;
    DateTime? next;
    for (final s in sorted) {
      final DateTime t = _endOf(s);
      if (next == null || !t.isBefore(next)) {
        reviews++;
        next = t.add(intervalAfterReview(reviews));
      }
    }
    return next;
  }

  // Daftar set yang perlu diulas diurutkan dari yang paling urgen.
  static List<FlashcardSet> dueSets(FlashMindRepository repo, {DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    final List<_Candidate> studied = [];
    final List<FlashcardSet> fresh = [];

    for (final set in repo.sets) {
      // Set tanpa kartu tidak diikutsertakan
      if (set.cardCount == 0) continue;

      final sessions = repo.getCompletedStudySessionsForSet(set.id);
      final DateTime? due = nextReviewAt(sessions);

      if (due == null) {
        // set baru akan berada pada urutan paling bawah
        fresh.add(set);
        continue;
      }
      if (due.isAfter(current)) continue;

      final latest = sessions.reduce(
        (a, b) => _endOf(a).isAfter(_endOf(b)) ? a : b,
      );
      studied.add(_Candidate(set, _endOf(latest), latest.accuracy));
    }

    studied.sort(_compareUrgency);
    fresh.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return [...studied.map((c) => c.set), ...fresh];
  }

  // Kriteria pengurutan utama, yaitu waktu terakhir dipelajari paling lama.
  // Bila berada di hari kalender yang sama digunakan tingkat kebenaran terendah
  static int _compareUrgency(_Candidate a, _Candidate b) {
    final DateTime dayA = DateTime(
      a.lastStudiedAt.year,
      a.lastStudiedAt.month,
      a.lastStudiedAt.day,
    );
    final DateTime dayB = DateTime(
      b.lastStudiedAt.year,
      b.lastStudiedAt.month,
      b.lastStudiedAt.day,
    );
    final int byDay = dayA.compareTo(dayB);
    if (byDay != 0) return byDay;

    final int byAccuracy = a.accuracy.compareTo(b.accuracy);
    if (byAccuracy != 0) return byAccuracy;

    return a.lastStudiedAt.compareTo(b.lastStudiedAt);
  }

  static DateTime _endOf(StudySession s) => s.finishedAt ?? s.startedAt;
}

class _Candidate {
  const _Candidate(this.set, this.lastStudiedAt, this.accuracy);

  final FlashcardSet set;
  final DateTime lastStudiedAt;
  final double accuracy;
}
