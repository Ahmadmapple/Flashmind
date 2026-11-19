import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../services/study_statistics.dart';

typedef _JsonMap = Map<String, dynamic>;

class FlashMindRepository extends ChangeNotifier {
  FlashMindRepository._internal();

  static final FlashMindRepository instance = FlashMindRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  final List<FlashcardSet> _sets = [];
  final List<StudySession> _studySessions = [];
  bool _isLoading = false;
  int _nextSessionNumber = 20;

  bool get isLoading => _isLoading;

  List<FlashcardSet> get sets => List.unmodifiable(_sets);

  List<StudySession> get allCompletedSessions => List.unmodifiable(
    _studySessions.where((s) => s.status == StudySessionStatus.completed),
  );

  CollectionReference<_JsonMap> _setsCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('sets');

  CollectionReference<_JsonMap> _cardsCollection(String uid, String setId) =>
      _setsCollection(uid).doc(setId).collection('cards');

  CollectionReference<_JsonMap> _sessionsCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('study_sessions');

  Future<void> loadUserData([String? uid]) async {
    final String? targetUid = uid ?? _auth.currentUser?.uid;
    if (targetUid == null) {
      clearData();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final setsSnapshot = await _setsCollection(targetUid)
          .orderBy('createdAt')
          .get();

      final loadedSets = await Future.wait<FlashcardSet>(
        setsSnapshot.docs.map((doc) async {
          final cardsSnapshot = await doc.reference
              .collection('cards')
              .orderBy('createdAt')
              .get();

          final cards = cardsSnapshot.docs
              .map((cardDoc) => Flashcard.fromMap(cardDoc.data(), cardDoc.id))
              .toList();

          return FlashcardSet.fromMap(doc.data(), doc.id, cards: cards);
        }),
      );

      final sessionsSnapshot = await _sessionsCollection(targetUid)
          .orderBy('startedAt')
          .get();

      final loadedSessions = sessionsSnapshot.docs
          .map((doc) => StudySession.fromMap(doc.data(), doc.id))
          .toList();

      _sets
        ..clear()
        ..addAll(loadedSets);
      _studySessions
        ..clear()
        ..addAll(loadedSessions);
    } catch (e) {
      debugPrint('Gagal memuat data Firestore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _sets.clear();
    _studySessions.clear();
    _isLoading = false;
    notifyListeners();
  }

  List<StudySession> getCompletedStudySessionsForSet(String setId) =>
      List.unmodifiable(
        _studySessions.where(
              (s) => s.setId == setId && s.status == StudySessionStatus.completed,
        ),
      );

  StudySession? getLatestCompletedSessionForSet(String setId) {
    StudySession? latest;
    for (final s in _studySessions) {
      if (s.setId != setId || s.status != StudySessionStatus.completed) {
        continue;
      }
      if (latest == null ||
          (s.finishedAt ?? s.startedAt).isAfter(
            latest.finishedAt ?? latest.startedAt,
          )) {
        latest = s;
      }
    }
    return latest;
  }

  double? getAverageAccuracyForSet(String setId) {
    final sessions = getCompletedStudySessionsForSet(setId);
    if (sessions.isEmpty) return null;
    return StudyStatistics.averageAccuracy(sessions);
  }

  Duration? getAverageDurationForSet(String setId) {
    final sessions = getCompletedStudySessionsForSet(setId);
    if (sessions.isEmpty) return null;
    final int total = sessions.fold<int>(
      0,
          (acc, s) => acc + s.totalDuration.inMicroseconds,
    );
    return Duration(microseconds: total ~/ sessions.length);
  }

  StudySession? getInProgressStudySessionForSet(String setId) {
    for (final s in _studySessions.reversed) {
      if (s.setId == setId && s.status == StudySessionStatus.inProgress) {
        return s;
      }
    }
    return null;
  }

  StudySession? getStudySessionById(String id) =>
      _studySessions.where((s) => s.id == id).firstOrNull;

  FlashcardSet? getSetById(String id) =>
      _sets.where((s) => s.id == id).firstOrNull;

  static const String deletedSetTitle = 'Set yang dihapus';

  String titleForSession(StudySession session) =>
      getSetById(session.setId)?.title ?? session.setTitle ?? deletedSetTitle;

  int cardCountForSession(StudySession session) =>
      getSetById(session.setId)?.cardCount ?? session.totalCardCount;

  Future<FlashcardSet> createSet({
    required String title,
    required String description,
  }) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Pengguna belum masuk.');
    }

    final docRef = _setsCollection(uid).doc();
    final set = FlashcardSet(
      id: docRef.id,
      title: title.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
    );

    await docRef.set(set.toMap());
    _sets.add(set);
    notifyListeners();
    return set;
  }

  Future<void> updateSet({
    required String id,
    required String title,
    required String description,
  }) async {
    final int i = _sets.indexWhere((s) => s.id == id);
    if (i == -1) return;

    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final String trimmedTitle = title.trim();
    final String trimmedDescription = description.trim();

    await _setsCollection(uid).doc(id).update({
      'title': trimmedTitle,
      'description': trimmedDescription,
    });

    _sets[i] = _sets[i].copyWith(
      title: trimmedTitle,
      description: trimmedDescription,
    );
    notifyListeners();
  }

  Future<void> deleteSet(String id) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final String? title = getSetById(id)?.title;
    final setRef = _setsCollection(uid).doc(id);
    final cardsSnapshot = await setRef.collection('cards').get();
    final batch = _firestore.batch();

    for (final cardDoc in cardsSnapshot.docs) {
      batch.delete(cardDoc.reference);
    }
    batch.delete(setRef);

    for (final session in _studySessions) {
      if (session.setId != id) continue;
      final sessionRef = _sessionsCollection(uid).doc(session.id);
      if (session.status == StudySessionStatus.inProgress) {
        batch.delete(sessionRef);
      } else {
        batch.set(
          sessionRef,
          {'setTitle': title},
          SetOptions(merge: true),
        );
      }
    }

    await batch.commit();

    _sets.removeWhere((s) => s.id == id);
    _studySessions.removeWhere(
          (s) => s.setId == id && s.status == StudySessionStatus.inProgress,
    );
    for (int i = 0; i < _studySessions.length; i++) {
      if (_studySessions[i].setId == id) {
        _studySessions[i] = _studySessions[i].copyWith(setTitle: title);
      }
    }
    notifyListeners();
  }

  Future<Flashcard?> addFlashcard({
    required String setId,
    required String frontText,
    required String backText,
  }) async {
    final int i = _sets.indexWhere((s) => s.id == setId);
    if (i == -1) return null;

    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final docRef = _cardsCollection(uid, setId).doc();
    final card = Flashcard(
      id: docRef.id,
      setId: setId,
      frontText: frontText.trim(),
      backText: backText.trim(),
      createdAt: DateTime.now(),
    );

    await docRef.set(card.toMap());
    _sets[i] = _sets[i].copyWith(cards: [..._sets[i].cards, card]);
    notifyListeners();
    return card;
  }

  Future<bool> updateFlashcard({
    required String id,
    required String setId,
    required String frontText,
    required String backText,
  }) async {
    final int si = _sets.indexWhere((s) => s.id == setId);
    if (si == -1) return false;
    final int ci = _sets[si].cards.indexWhere((c) => c.id == id);
    if (ci == -1) return false;

    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final String trimmedFront = frontText.trim();
    final String trimmedBack = backText.trim();

    await _cardsCollection(uid, setId).doc(id).update({
      'frontText': trimmedFront,
      'backText': trimmedBack,
    });

    final old = _sets[si].cards[ci];
    final updated = List<Flashcard>.from(_sets[si].cards)
      ..[ci] = Flashcard(
        id: old.id,
        setId: old.setId,
        frontText: trimmedFront,
        backText: trimmedBack,
        createdAt: old.createdAt,
      );
    _sets[si] = _sets[si].copyWith(cards: updated);
    notifyListeners();
    return true;
  }

  Future<bool> deleteFlashcard(String cardId) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    for (int i = 0; i < _sets.length; i++) {
      final int ci = _sets[i].cards.indexWhere((c) => c.id == cardId);
      if (ci == -1) continue;

      final String setId = _sets[i].id;
      await _cardsCollection(uid, setId).doc(cardId).delete();

      _sets[i] = _sets[i].copyWith(
        cards: List<Flashcard>.from(_sets[i].cards)..removeAt(ci),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<StudySession?> startStudySession(String setId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final set = getSetById(setId);
    if (set == null || set.cards.isEmpty) return null;
    final existing = getInProgressStudySessionForSet(setId);
    if (existing != null) return existing;
    final cardOrder = set.cards.map((c) => c.id).toList()..shuffle(Random());
    final session = StudySession(
      id: 'session-${_nextSessionNumber++}',
      setId: setId,
      startedAt: DateTime.now(),
      status: StudySessionStatus.inProgress,
      cardOrder: cardOrder,
    );
    _studySessions.add(session);
    notifyListeners();
    return session;
  }

  bool markCurrentCardFrontShown(String sessionId) {
    final int i = _studySessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return false;
    final s = _studySessions[i];
    if (s.status != StudySessionStatus.inProgress ||
        s.nextCardIndex >= s.cardOrder.length ||
        s.currentCardFrontShownAt != null) {
      return false;
    }
    _studySessions[i] = s.copyWith(
      currentCardFrontShownAt: DateTime.now(),
      clearLastPausedAt: true,
    );
    notifyListeners();
    return true;
  }

  bool pauseStudySession(String sessionId) {
    final int i = _studySessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return false;
    final s = _studySessions[i];
    if (s.status != StudySessionStatus.inProgress) return false;
    final DateTime now = DateTime.now();
    Duration elapsed = s.currentCardElapsedDuration;
    if (s.currentCardFrontShownAt != null) {
      final Duration seg = now.difference(s.currentCardFrontShownAt!);
      if (!seg.isNegative) elapsed += seg;
    }
    _studySessions[i] = s.copyWith(
      currentCardFrontShownAt: null,
      currentCardElapsedDuration: elapsed,
      lastPausedAt: now,
      clearCurrentCardFrontShownAt: true,
    );
    notifyListeners();
    return true;
  }

  bool markAnswerRevealed(String sessionId) {
    final int i = _studySessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return false;
    final s = _studySessions[i];
    if (s.status != StudySessionStatus.inProgress ||
        s.currentCardFrontShownAt == null) {
      return false;
    }
    _studySessions[i] = s.copyWith(currentCardAnswerRevealedAt: DateTime.now());
    notifyListeners();
    return true;
  }

  StudySession? evaluateCurrentCard({
    required String sessionId,
    required String cardId,
    required bool isCorrect,
  }) {
    final int i = _studySessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return null;
    final s = _studySessions[i];
    if (s.status != StudySessionStatus.inProgress ||
        s.nextCardIndex >= s.cardOrder.length ||
        s.cardOrder[s.nextCardIndex] != cardId ||
        s.currentCardFrontShownAt == null) {
      return null;
    }

    final DateTime now = DateTime.now();
    final Duration seg = now.difference(s.currentCardFrontShownAt!);
    final Duration safe = seg.isNegative ? Duration.zero : seg;
    final Duration dur = s.currentCardElapsedDuration + safe;
    final StudyCardResult res = StudyCardResult(
      cardId: cardId,
      frontShownAt: s.currentCardFrontShownAt!,
      answerRevealedAt: s.currentCardAnswerRevealedAt,
      evaluatedAt: now,
      isCorrect: isCorrect,
      duration: dur,
    );
    final results = [...s.cardResults, res];
    final int next = s.nextCardIndex + 1;
    final bool done = next >= s.cardOrder.length;
    final Duration total = results.fold<Duration>(
      Duration.zero,
          (a, r) => a + r.duration,
    );
    final int correct = results.where((r) => r.isCorrect).length;
    final Duration avg = results.isEmpty
        ? Duration.zero
        : Duration(microseconds: total.inMicroseconds ~/ results.length);

    final updated = s.copyWith(
      status: done
          ? StudySessionStatus.completed
          : StudySessionStatus.inProgress,
      finishedAt: done ? now : null,
      clearFinishedAt: !done,
      nextCardIndex: next,
      cardResults: results,
      currentCardFrontShownAt: null,
      clearCurrentCardFrontShownAt: true,
      clearCurrentCardAnswerRevealedAt: true,
      currentCardElapsedDuration: Duration.zero,
      clearLastPausedAt: true,
      totalDuration: total,
      correctCount: correct,
      wrongCount: results.length - correct,
      accuracy: results.isEmpty ? 0.0 : correct / results.length * 100,
      averageCardDuration: avg,
    );
    _studySessions[i] = updated;

    if (done) {
      final int si = _sets.indexWhere((st) => st.id == s.setId);
      if (si != -1) _sets[si] = _sets[si].copyWith(lastStudiedAt: now);
    }
    notifyListeners();
    return updated;
  }

  int get currentStreak {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    int streak = 0;
    DateTime check = today;
    while (true) {
      final bool active = _studySessions.any((s) {
        if (s.status != StudySessionStatus.completed) return false;
        final DateTime t = s.finishedAt ?? s.startedAt;
        final DateTime d = DateTime(t.year, t.month, t.day);
        return d == check;
      });
      if (!active) break;
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get highestStreak {
    if (_studySessions.isEmpty) return 0;
    final activeDays =
    _studySessions
        .where((s) => s.status == StudySessionStatus.completed)
        .map((s) {
      final DateTime t = s.finishedAt ?? s.startedAt;
      return DateTime(t.year, t.month, t.day);
    })
        .toSet()
        .toList()
      ..sort();
    if (activeDays.isEmpty) return 0;
    int best = 1;
    int cur = 1;
    for (int i = 1; i < activeDays.length; i++) {
      final diff = activeDays[i].difference(activeDays[i - 1]).inDays;
      if (diff == 1) {
        cur++;
        if (cur > best) best = cur;
      } else {
        cur = 1;
      }
    }
    return best;
  }

  Iterable<StudySession> get _weeklySessions {
    final DateTime cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _studySessions.where(
          (s) =>
      s.status == StudySessionStatus.completed &&
          (s.finishedAt ?? s.startedAt).isAfter(cutoff),
    );
  }

  int get weeklyUniqueSets =>
      _weeklySessions.map((s) => s.setId).toSet().length;

  int get weeklyCardCount =>
      StudyStatistics.totalCards(_weeklySessions);

  Duration get weeklyDuration =>
      StudyStatistics.totalDuration(_weeklySessions);

  double get weeklyAccuracy =>
      StudyStatistics.averageAccuracy(_weeklySessions);

  List<FlashcardSet> _rankedSetsByPerformance() {
    final entries =
    <({FlashcardSet set, double acc, int durMs, DateTime last})>[];

    for (final set in _sets) {
      final sessions = getCompletedStudySessionsForSet(set.id);
      if (sessions.isEmpty) continue;
      final double acc = StudyStatistics.averageAccuracy(sessions);
      final int durMs =
          sessions.fold<int>(0, (s, x) => s + x.totalDuration.inMilliseconds) ~/
              sessions.length;
      final StudySession latest = getLatestCompletedSessionForSet(set.id)!;
      entries.add((
      set: set,
      acc: acc,
      durMs: durMs,
      last: latest.finishedAt ?? latest.startedAt,
      ));
    }
    if (entries.isEmpty) return const <FlashcardSet>[];

    final int minDur = entries.map((e) => e.durMs).reduce(min);
    final int maxDur = entries.map((e) => e.durMs).reduce(max);

    final scored = [
      for (final e in entries)
        (
        set: e.set,
        score:
        ((e.acc.clamp(0, 100) / 100 * 0.5 +
            (maxDur == minDur
                ? 1.0
                : (maxDur - e.durMs) / (maxDur - minDur)) *
                0.5) *
            100)
            .round(),
        last: e.last,
        ),
    ];

    scored.sort((a, b) {
      final int byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : b.last.compareTo(a.last);
    });
    return scored.map((e) => e.set).toList();
  }

  FlashcardSet? get bestMasteredSet {
    final ranked = _rankedSetsByPerformance();
    return ranked.isEmpty ? null : ranked.first;
  }

  FlashcardSet? get worstSet {
    final ranked = _rankedSetsByPerformance();
    return ranked.length < 2 ? null : ranked.last;
  }

  static DateTime sessionStoppedAt(StudySession s) {
    if (s.lastPausedAt != null) return s.lastPausedAt!;
    if (s.cardResults.isNotEmpty) return s.cardResults.last.evaluatedAt;
    return s.currentCardFrontShownAt ?? s.startedAt;
  }

  List<StudySession> get inProgressSessions {
    final list =
    _studySessions
        .where((s) => s.status == StudySessionStatus.inProgress)
        .toList()
      ..sort((a, b) => sessionStoppedAt(b).compareTo(sessionStoppedAt(a)));
    return List.unmodifiable(list);
  }
}
