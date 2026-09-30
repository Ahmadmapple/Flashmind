import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper: membangun sesi belajar selesai
// ─────────────────────────────────────────────────────────────────────────────

StudySession _makeSession({
  required String id,
  required String setId,
  required List<String> cardIds,
  required DateTime startedAt,
  required Duration totalDuration,
  required int correctCount,
}) {
  final wrong    = cardIds.length - correctCount;
  final accuracy = cardIds.isEmpty ? 0.0 : correctCount / cardIds.length * 100;
  final perCard  = cardIds.isEmpty
      ? Duration.zero
      : Duration(microseconds: totalDuration.inMicroseconds ~/ cardIds.length);

  final results = List<StudyCardResult>.generate(cardIds.length, (i) {
    final front   = startedAt.add(perCard * i);
    final reveal  = front.add(const Duration(seconds: 3));
    final evalAt  = reveal.add(const Duration(seconds: 2));
    return StudyCardResult(
      cardId: cardIds[i],
      frontShownAt: front,
      answerRevealedAt: reveal,
      evaluatedAt: evalAt,
      isCorrect: i < correctCount,
      duration: perCard,
    );
  });

  return StudySession(
    id: id,
    setId: setId,
    startedAt: startedAt,
    finishedAt: startedAt.add(totalDuration),
    status: StudySessionStatus.completed,
    cardOrder: List<String>.from(cardIds),
    nextCardIndex: cardIds.length,
    cardResults: results,
    totalDuration: totalDuration,
    correctCount: correctCount,
    wrongCount: wrong,
    accuracy: accuracy,
    averageCardDuration: perCard,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

class FlashMindRepository extends ChangeNotifier {
  FlashMindRepository._internal() {
    _initDummyData();
  }

  static final FlashMindRepository instance = FlashMindRepository._internal();

  final List<FlashcardSet>  _sets          = [];
  final List<StudySession>  _studySessions = [];
  int _nextSetNumber     = 6;
  int _nextCardNumber    = 100;
  int _nextSessionNumber = 20;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<FlashcardSet> get sets => List.unmodifiable(_sets);

  List<StudySession> get allCompletedSessions => List.unmodifiable(
    _studySessions.where((s) => s.status == StudySessionStatus.completed),
  );

  List<StudySession> getSessionsOnDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end   = start.add(const Duration(days: 1));
    return _studySessions.where((s) {
      if (s.status != StudySessionStatus.completed) return false;
      final t = s.finishedAt ?? s.startedAt;
      return !t.isBefore(start) && t.isBefore(end);
    }).toList();
  }

  List<StudySession> getStudySessionsForSet(String setId) =>
      List.unmodifiable(_studySessions.where((s) => s.setId == setId));

  List<StudySession> getCompletedStudySessionsForSet(String setId) =>
      List.unmodifiable(_studySessions.where(
        (s) => s.setId == setId && s.status == StudySessionStatus.completed,
      ));

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

  // ── Data dummy ────────────────────────────────────────────────────────────

  void _initDummyData() {
    final now = DateTime.now();

    // ────────────────────── SET 1 : Biologi Sel ──────────────────────────────
    const s1 = 'set-1';
    final cards1 = [
      Flashcard(id: 'c1-1', setId: s1, createdAt: now,
        frontText: 'Apa fungsi utama membran sel?',
        backText:  'Mengatur zat yang masuk dan keluar sel serta menjaga keseimbangan internal.'),
      Flashcard(id: 'c1-2', setId: s1, createdAt: now,
        frontText: 'Apa itu mitokondria?',
        backText:  'Organel penghasil energi (ATP) melalui respirasi seluler; disebut "pembangkit listrik sel".'),
      Flashcard(id: 'c1-3', setId: s1, createdAt: now,
        frontText: 'Jelaskan fotosintesis secara singkat.',
        backText:  'Proses tumbuhan mengubah cahaya matahari, air, dan CO₂ menjadi glukosa dan oksigen.'),
      Flashcard(id: 'c1-4', setId: s1, createdAt: now,
        frontText: 'Apa perbedaan sel prokariotik dan eukariotik?',
        backText:  'Prokariotik tidak memiliki nukleus bermembran; eukariotik memiliki nukleus yang diselubungi membran inti.'),
      Flashcard(id: 'c1-5', setId: s1, createdAt: now,
        frontText: 'Apa fungsi ribosom?',
        backText:  'Mensintesis protein dengan menerjemahkan mRNA menjadi rantai asam amino.'),
    ];

    // ────────────────────── SET 2 : Bahasa Jepang ────────────────────────────
    const s2 = 'set-2';
    final cards2 = [
      Flashcard(id: 'c2-1', setId: s2, createdAt: now,
        frontText: 'ありがとう (Arigatou) artinya?',
        backText:  'Terima kasih'),
      Flashcard(id: 'c2-2', setId: s2, createdAt: now,
        frontText: 'おはよう (Ohayou) artinya?',
        backText:  'Selamat pagi'),
      Flashcard(id: 'c2-3', setId: s2, createdAt: now,
        frontText: 'こんにちは (Konnichiwa) artinya?',
        backText:  'Selamat siang / Halo'),
      Flashcard(id: 'c2-4', setId: s2, createdAt: now,
        frontText: 'さようなら (Sayounara) artinya?',
        backText:  'Selamat tinggal'),
      Flashcard(id: 'c2-5', setId: s2, createdAt: now,
        frontText: 'すみません (Sumimasen) artinya?',
        backText:  'Permisi / Maaf'),
    ];

    // ────────────────────── SET 3 : Kimia Organik ────────────────────────────
    const s3 = 'set-3';
    final cards3 = [
      Flashcard(id: 'c3-1', setId: s3, createdAt: now,
        frontText: 'Apa itu isomer?',
        backText:  'Senyawa dengan rumus molekul sama tetapi struktur atau susunan atom berbeda.'),
      Flashcard(id: 'c3-2', setId: s3, createdAt: now,
        frontText: 'Apa itu alkana?',
        backText:  'Hidrokarbon jenuh dengan ikatan tunggal C–C; rumus umum CₙH₂ₙ₊₂.'),
      Flashcard(id: 'c3-3', setId: s3, createdAt: now,
        frontText: 'Perbedaan alkena dan alkuna?',
        backText:  'Alkena: ikatan rangkap dua (C=C). Alkuna: ikatan rangkap tiga (C≡C).'),
      Flashcard(id: 'c3-4', setId: s3, createdAt: now,
        frontText: 'Apa itu gugus fungsi?',
        backText:  'Atom/kelompok atom pada molekul organik yang menentukan sifat kimianya.'),
      Flashcard(id: 'c3-5', setId: s3, createdAt: now,
        frontText: 'Apa itu reaksi substitusi?',
        backText:  'Reaksi penggantian satu atom/gugus dalam molekul dengan atom/gugus lain.'),
    ];

    // ────────────────────── SET 4 : Matematika Dasar ─────────────────────────
    const s4 = 'set-4';
    final cards4 = [
      Flashcard(id: 'c4-1', setId: s4, createdAt: now,
        frontText: 'Berapa hasil dari 7 × 8?',
        backText:  '56'),
      Flashcard(id: 'c4-2', setId: s4, createdAt: now,
        frontText: 'Apa rumus luas lingkaran?',
        backText:  'L = π × r² (di mana r adalah jari-jari)'),
      Flashcard(id: 'c4-3', setId: s4, createdAt: now,
        frontText: 'Apa itu bilangan prima?',
        backText:  'Bilangan asli lebih dari 1 yang hanya habis dibagi 1 dan dirinya sendiri.'),
      Flashcard(id: 'c4-4', setId: s4, createdAt: now,
        frontText: 'Apa rumus Teorema Pythagoras?',
        backText:  'a² + b² = c², di mana c adalah sisi miring segitiga siku-siku.'),
      Flashcard(id: 'c4-5', setId: s4, createdAt: now,
        frontText: 'Apa itu FPB?',
        backText:  'Faktor Persekutuan Terbesar: bilangan terbesar yang habis membagi dua bilangan.'),
    ];

    // ────────────────────── SET 5 : Sejarah Indonesia ────────────────────────
    const s5 = 'set-5';
    final cards5 = [
      Flashcard(id: 'c5-1', setId: s5, createdAt: now,
        frontText: 'Kapan Indonesia merdeka?',
        backText:  '17 Agustus 1945'),
      Flashcard(id: 'c5-2', setId: s5, createdAt: now,
        frontText: 'Siapa proklamator kemerdekaan Indonesia?',
        backText:  'Soekarno dan Mohammad Hatta'),
      Flashcard(id: 'c5-3', setId: s5, createdAt: now,
        frontText: 'Apa isi Sumpah Pemuda 1928?',
        backText:  'Satu bangsa (Indonesia), satu tanah air (Indonesia), satu bahasa (Indonesia).'),
      Flashcard(id: 'c5-4', setId: s5, createdAt: now,
        frontText: 'Apa nama operasi militer yang membebaskan Irian Barat?',
        backText:  'Operasi Trikora (Tri Komando Rakyat), 1961–1962.'),
      Flashcard(id: 'c5-5', setId: s5, createdAt: now,
        frontText: 'Siapa presiden pertama Republik Indonesia?',
        backText:  'Ir. Soekarno, menjabat 1945–1967.'),
    ];

    // Daftar set (lastStudiedAt diset setelah sesi dibuat)
    _sets.addAll([
      FlashcardSet(id: s1, title: 'Biologi Sel',
        description: 'Konsep dasar biologi sel dan organel-organelnya.',
        createdAt: now.subtract(const Duration(days: 12)), cards: cards1),
      FlashcardSet(id: s2, title: 'Bahasa Jepang',
        description: 'Kosakata dasar dan sapaan sehari-hari bahasa Jepang.',
        createdAt: now.subtract(const Duration(days: 9)), cards: cards2),
      FlashcardSet(id: s3, title: 'Kimia Organik',
        description: 'Alkana, alkena, alkuna, isomer, dan gugus fungsi.',
        createdAt: now.subtract(const Duration(days: 7)), cards: cards3),
      FlashcardSet(id: s4, title: 'Matematika Dasar',
        description: 'Operasi dasar, rumus geometri, dan teori bilangan.',
        createdAt: now.subtract(const Duration(days: 5)), cards: cards4),
      FlashcardSet(id: s5, title: 'Sejarah Indonesia',
        description: 'Peristiwa penting dalam sejarah kemerdekaan Indonesia.',
        createdAt: now.subtract(const Duration(days: 3)), cards: cards5),
    ]);

    // ── Sesi belajar (dalam 7 hari terakhir) ─────────────────────────────────
    // Hari ini (idx 6) = now; hari -6 = now-6d
    final d = (int daysAgo) => now.subtract(Duration(days: daysAgo));

    // Set 1 – 3 sesi: 5 hari lalu, 2 hari lalu, kemarin
    _addSession(_makeSession(id: 'ses-1', setId: s1,
      cardIds: cards1.map((c) => c.id).toList(),
      startedAt: d(5), totalDuration: const Duration(minutes: 5), correctCount: 4));
    _addSession(_makeSession(id: 'ses-2', setId: s1,
      cardIds: cards1.map((c) => c.id).toList(),
      startedAt: d(2), totalDuration: const Duration(minutes: 4), correctCount: 5));
    _addSession(_makeSession(id: 'ses-3', setId: s1,
      cardIds: cards1.map((c) => c.id).toList(),
      startedAt: d(0).subtract(const Duration(hours: 3)),
      totalDuration: const Duration(minutes: 3, seconds: 30), correctCount: 5));

    // Set 2 – 2 sesi: 4 hari lalu, kemarin
    _addSession(_makeSession(id: 'ses-4', setId: s2,
      cardIds: cards2.map((c) => c.id).toList(),
      startedAt: d(4), totalDuration: const Duration(minutes: 3), correctCount: 3));
    _addSession(_makeSession(id: 'ses-5', setId: s2,
      cardIds: cards2.map((c) => c.id).toList(),
      startedAt: d(1), totalDuration: const Duration(minutes: 2, seconds: 45), correctCount: 4));

    // Set 3 – 2 sesi: 6 hari lalu, 3 hari lalu
    _addSession(_makeSession(id: 'ses-6', setId: s3,
      cardIds: cards3.map((c) => c.id).toList(),
      startedAt: d(6), totalDuration: const Duration(minutes: 4, seconds: 15), correctCount: 2));
    _addSession(_makeSession(id: 'ses-7', setId: s3,
      cardIds: cards3.map((c) => c.id).toList(),
      startedAt: d(3), totalDuration: const Duration(minutes: 3), correctCount: 3));

    // Set 4 – 1 sesi: 2 hari lalu
    _addSession(_makeSession(id: 'ses-8', setId: s4,
      cardIds: cards4.map((c) => c.id).toList(),
      startedAt: d(2).subtract(const Duration(hours: 5)),
      totalDuration: const Duration(minutes: 2, seconds: 50), correctCount: 5));

    // Set 5 – belum pernah dipelajari (tidak ada sesi)
  }

  /// Tambahkan sesi dan perbarui lastStudiedAt set terkait.
  void _addSession(StudySession session) {
    _studySessions.add(session);
    final setIndex = _sets.indexWhere((s) => s.id == session.setId);
    if (setIndex != -1 && session.finishedAt != null) {
      final existing = _sets[setIndex].lastStudiedAt;
      if (existing == null || session.finishedAt!.isAfter(existing)) {
        _sets[setIndex] = _sets[setIndex].copyWith(
          lastStudiedAt: session.finishedAt,
        );
      }
    }
  }

  // ── CRUD Set ──────────────────────────────────────────────────────────────

  Future<FlashcardSet> createSet({
    required String title,
    required String description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final set = FlashcardSet(
      id: 'set-${_nextSetNumber++}',
      title: title.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
    );
    _sets.add(set);
    notifyListeners();
    return set;
  }

  Future<void> updateSet({
    required String id,
    required String title,
    required String description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final i = _sets.indexWhere((s) => s.id == id);
    if (i == -1) return;
    _sets[i] = _sets[i].copyWith(title: title.trim(), description: description.trim());
    notifyListeners();
  }

  Future<void> deleteSet(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _sets.removeWhere((s) => s.id == id);
    _studySessions.removeWhere((s) => s.setId == id);
    notifyListeners();
  }

  // ── CRUD Kartu ────────────────────────────────────────────────────────────

  Future<Flashcard?> addFlashcard({
    required String setId,
    required String frontText,
    required String backText,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final i = _sets.indexWhere((s) => s.id == setId);
    if (i == -1) return null;
    final card = Flashcard(
      id: 'card-${_nextCardNumber++}',
      setId: setId,
      frontText: frontText.trim(),
      backText: backText.trim(),
      createdAt: DateTime.now(),
    );
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
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final si = _sets.indexWhere((s) => s.id == setId);
    if (si == -1) return false;
    final ci = _sets[si].cards.indexWhere((c) => c.id == id);
    if (ci == -1) return false;
    final old = _sets[si].cards[ci];
    final updated = List<Flashcard>.from(_sets[si].cards)
      ..[ci] = Flashcard(
          id: old.id, setId: old.setId,
          frontText: frontText.trim(), backText: backText.trim(),
          createdAt: old.createdAt);
    _sets[si] = _sets[si].copyWith(cards: updated);
    notifyListeners();
    return true;
  }

  Future<bool> deleteFlashcard(String cardId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    for (int i = 0; i < _sets.length; i++) {
      final ci = _sets[i].cards.indexWhere((c) => c.id == cardId);
      if (ci == -1) continue;
      _sets[i] = _sets[i].copyWith(
        cards: List<Flashcard>.from(_sets[i].cards)..removeAt(ci),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── Sesi Belajar ──────────────────────────────────────────────────────────

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
    final i = _studySessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return false;
    final s = _studySessions[i];
    if (s.status != StudySessionStatus.inProgress ||
        s.nextCardIndex >= s.cardOrder.length ||
        s.currentCardFrontShownAt != null) return false;
    _studySessions[i] = s.copyWith(
        currentCardFrontShownAt: DateTime.now(), clearLastPausedAt: true);
    notifyListeners();
    return true;
  }

  bool pauseStudySession(String sessionId) {
    final i = _studySessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return false;
    final s = _studySessions[i];
    if (s.status != StudySessionStatus.inProgress) return false;
    final now     = DateTime.now();
    var elapsed   = s.currentCardElapsedDuration;
    if (s.currentCardFrontShownAt != null) {
      final seg = now.difference(s.currentCardFrontShownAt!);
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
    final i = _studySessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return false;
    final s = _studySessions[i];
    if (s.status != StudySessionStatus.inProgress ||
        s.currentCardFrontShownAt == null) return false;
    _studySessions[i] = s.copyWith(currentCardAnswerRevealedAt: DateTime.now());
    notifyListeners();
    return true;
  }

  StudySession? evaluateCurrentCard({
    required String sessionId,
    required String cardId,
    required bool isCorrect,
  }) {
    final i = _studySessions.indexWhere((s) => s.id == sessionId);
    if (i == -1) return null;
    final s = _studySessions[i];
    if (s.status != StudySessionStatus.inProgress ||
        s.nextCardIndex >= s.cardOrder.length ||
        s.cardOrder[s.nextCardIndex] != cardId ||
        s.currentCardFrontShownAt == null) return null;

    final now        = DateTime.now();
    final seg        = now.difference(s.currentCardFrontShownAt!);
    final safeSeg    = seg.isNegative ? Duration.zero : seg;
    final dur        = s.currentCardElapsedDuration + safeSeg;
    final res        = StudyCardResult(
      cardId: cardId, frontShownAt: s.currentCardFrontShownAt!,
      answerRevealedAt: s.currentCardAnswerRevealedAt,
      evaluatedAt: now, isCorrect: isCorrect, duration: dur,
    );
    final results    = [...s.cardResults, res];
    final next       = s.nextCardIndex + 1;
    final done       = next >= s.cardOrder.length;
    final total      = results.fold<Duration>(Duration.zero, (a, r) => a + r.duration);
    final correct    = results.where((r) => r.isCorrect).length;
    final avg        = results.isEmpty
        ? Duration.zero
        : Duration(microseconds: total.inMicroseconds ~/ results.length);

    final updated = s.copyWith(
      status: done ? StudySessionStatus.completed : StudySessionStatus.inProgress,
      finishedAt: done ? now : null, clearFinishedAt: !done,
      nextCardIndex: next, cardResults: results,
      currentCardFrontShownAt: null, clearCurrentCardFrontShownAt: true,
      clearCurrentCardAnswerRevealedAt: true,
      currentCardElapsedDuration: Duration.zero, clearLastPausedAt: true,
      totalDuration: total, correctCount: correct,
      wrongCount: results.length - correct,
      accuracy: results.isEmpty ? 0.0 : correct / results.length * 100,
      averageCardDuration: avg,
    );
    _studySessions[i] = updated;

    if (done) {
      final si = _sets.indexWhere((st) => st.id == s.setId);
      if (si != -1) _sets[si] = _sets[si].copyWith(lastStudiedAt: now);
    }
    notifyListeners();
    return updated;
  }
}
