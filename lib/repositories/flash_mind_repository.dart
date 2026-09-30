import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';

class FlashMindRepository extends ChangeNotifier {
  FlashMindRepository._internal()
    : _sets = [
        FlashcardSet(
          id: 'set-1',
          title: 'Nama Set',
          description: 'Deskripsi set',
          createdAt: DateTime(2026, 9, 28),
        ),
        FlashcardSet(
          id: 'set-2',
          title: 'Bahasa Jepang',
          description: 'Kosakata bahasa Jepang',
          createdAt: DateTime(2026, 9, 28),
        ),
        FlashcardSet(
          id: 'set-3',
          title: 'Biologi',
          description: 'Definisi dari istilah-istilah ilmiah',
          createdAt: DateTime(2026, 9, 28),
        ),
      ];

  static final FlashMindRepository instance = FlashMindRepository._internal();

  final List<FlashcardSet> _sets;
  final List<StudySession> _studySessions = [];
  int _nextSetNumber = 4;
  int _nextCardNumber = 1;
  int _nextSessionNumber = 1;

  List<FlashcardSet> get sets => List.unmodifiable(_sets);

  List<StudySession> getStudySessionsForSet(String setId) {
    return List.unmodifiable(
      _studySessions.where((session) => session.setId == setId),
    );
  }

  List<StudySession> getCompletedStudySessionsForSet(String setId) {
    return List.unmodifiable(
      _studySessions.where(
        (session) =>
            session.setId == setId &&
            session.status == StudySessionStatus.completed,
      ),
    );
  }

  StudySession? getInProgressStudySessionForSet(String setId) {
    for (final session in _studySessions.reversed) {
      if (session.setId == setId &&
          session.status == StudySessionStatus.inProgress) {
        return session;
      }
    }
    return null;
  }

  StudySession? getStudySessionById(String sessionId) {
    for (final session in _studySessions) {
      if (session.id == sessionId) return session;
    }
    return null;
  }

  FlashcardSet? getSetById(String id) {
    for (final set in _sets) {
      if (set.id == id) return set;
    }
    return null;
  }

  Future<FlashcardSet> createSet({
    required String title,
    required String description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final set = FlashcardSet(
      id: 'set-${_nextSetNumber++}',
      title: title,
      description: description,
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

    final index = _sets.indexWhere((set) => set.id == id);
    if (index == -1) return;

    _sets[index] = _sets[index].copyWith(
      title: title,
      description: description,
    );
    notifyListeners();
  }

  Future<Flashcard?> addFlashcard({
    required String setId,
    required String frontText,
    required String backText,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final index = _sets.indexWhere((set) => set.id == setId);
    if (index == -1) return null;

    final card = Flashcard(
      id: 'card-${_nextCardNumber++}',
      setId: setId,
      frontText: frontText,
      backText: backText,
      createdAt: DateTime.now(),
    );

    final set = _sets[index];
    _sets[index] = set.copyWith(
      cards: [...set.cards, card],
    );
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

    final setIndex = _sets.indexWhere((set) => set.id == setId);
    if (setIndex == -1) return false;

    final set = _sets[setIndex];
    final cardIndex = set.cards.indexWhere((card) => card.id == id);
    if (cardIndex == -1) return false;

    final oldCard = set.cards[cardIndex];
    final updatedCard = Flashcard(
      id: oldCard.id,
      setId: oldCard.setId,
      frontText: frontText,
      backText: backText,
      createdAt: oldCard.createdAt,
    );

    final updatedCards = List<Flashcard>.from(set.cards)
      ..[cardIndex] = updatedCard;

    _sets[setIndex] = set.copyWith(cards: updatedCards);
    notifyListeners();
    return true;
  }

  Future<bool> deleteFlashcard(String cardId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    for (int index = 0; index < _sets.length; index++) {
      final set = _sets[index];
      final cardIndex = set.cards.indexWhere((card) => card.id == cardId);

      if (cardIndex == -1) continue;

      final updatedCards = List<Flashcard>.from(set.cards)..removeAt(cardIndex);
      _sets[index] = set.copyWith(cards: updatedCards);
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> deleteSet(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final index = _sets.indexWhere((set) => set.id == id);
    if (index == -1) return;

    _sets.removeAt(index);
    _studySessions.removeWhere((session) => session.setId == id);
    notifyListeners();
  }

  Future<StudySession?> startStudySession(String setId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final set = getSetById(setId);
    if (set == null || set.cards.isEmpty) return null;

    final existingSession = getInProgressStudySessionForSet(setId);
    if (existingSession != null) return existingSession;

    final cardOrder = set.cards.map((card) => card.id).toList()..shuffle(Random());
    final now = DateTime.now();
    final session = StudySession(
      id: 'session-${_nextSessionNumber++}',
      setId: setId,
      startedAt: now,
      status: StudySessionStatus.inProgress,
      cardOrder: cardOrder,
      currentCardFrontShownAt: null,
    );

    _studySessions.add(session);
    notifyListeners();
    return session;
  }

  bool markCurrentCardFrontShown(String sessionId) {
    final index = _studySessions.indexWhere((session) => session.id == sessionId);
    if (index == -1) return false;

    final session = _studySessions[index];
    if (session.status != StudySessionStatus.inProgress ||
        session.nextCardIndex >= session.cardOrder.length ||
        session.currentCardFrontShownAt != null) {
      return false;
    }

    _studySessions[index] = session.copyWith(
      currentCardFrontShownAt: DateTime.now(),
      clearLastPausedAt: true,
    );
    notifyListeners();
    return true;
  }

  bool pauseStudySession(String sessionId) {
    final index = _studySessions.indexWhere((session) => session.id == sessionId);
    if (index == -1) return false;

    final session = _studySessions[index];
    if (session.status != StudySessionStatus.inProgress) return false;

    final now = DateTime.now();
    var elapsed = session.currentCardElapsedDuration;

    if (session.currentCardFrontShownAt != null) {
      final currentElapsed = now.difference(session.currentCardFrontShownAt!);
      if (!currentElapsed.isNegative) {
        elapsed += currentElapsed;
      }
    }

    _studySessions[index] = session.copyWith(
      currentCardFrontShownAt: null,
      currentCardElapsedDuration: elapsed,
      lastPausedAt: now,
      clearCurrentCardFrontShownAt: true,
    );
    notifyListeners();
    return true;
  }

  bool markAnswerRevealed(String sessionId) {
    final index = _studySessions.indexWhere((session) => session.id == sessionId);
    if (index == -1) return false;

    final session = _studySessions[index];
    if (session.status != StudySessionStatus.inProgress ||
        session.currentCardFrontShownAt == null) {
      return false;
    }

    _studySessions[index] = session.copyWith(
      currentCardAnswerRevealedAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  StudySession? evaluateCurrentCard({
    required String sessionId,
    required String cardId,
    required bool isCorrect,
  }) {
    final index = _studySessions.indexWhere((session) => session.id == sessionId);
    if (index == -1) return null;

    final session = _studySessions[index];
    if (session.status != StudySessionStatus.inProgress ||
        session.nextCardIndex >= session.cardOrder.length ||
        session.cardOrder[session.nextCardIndex] != cardId ||
        session.currentCardFrontShownAt == null) {
      return null;
    }

    final evaluatedAt = DateTime.now();
    final currentSegment = evaluatedAt.difference(session.currentCardFrontShownAt!);
    final safeCurrentSegment =
        currentSegment.isNegative ? Duration.zero : currentSegment;
    final duration = session.currentCardElapsedDuration + safeCurrentSegment;
    final result = StudyCardResult(
      cardId: cardId,
      frontShownAt: session.currentCardFrontShownAt!,
      answerRevealedAt: session.currentCardAnswerRevealedAt,
      evaluatedAt: evaluatedAt,
      isCorrect: isCorrect,
      duration: duration,
    );
    final updatedResults = [...session.cardResults, result];
    final nextCardIndex = session.nextCardIndex + 1;
    final isCompleted = nextCardIndex >= session.cardOrder.length;

    final totalDuration = updatedResults.fold<Duration>(
      Duration.zero,
      (sum, item) => sum + item.duration,
    );
    final correctCount = updatedResults.where((item) => item.isCorrect).length;
    final wrongCount = updatedResults.length - correctCount;
    final accuracy = updatedResults.isEmpty
        ? 0.0
        : correctCount / updatedResults.length * 100;
    final averageCardDuration = updatedResults.isEmpty
        ? Duration.zero
        : Duration(
            microseconds:
                totalDuration.inMicroseconds ~/ updatedResults.length,
          );

    final updatedSession = session.copyWith(
      status: isCompleted
          ? StudySessionStatus.completed
          : StudySessionStatus.inProgress,
      finishedAt: isCompleted ? evaluatedAt : null,
      clearFinishedAt: !isCompleted,
      nextCardIndex: nextCardIndex,
      cardResults: updatedResults,
      currentCardFrontShownAt: null,
      clearCurrentCardFrontShownAt: true,
      clearCurrentCardAnswerRevealedAt: true,
      currentCardElapsedDuration: Duration.zero,
      clearLastPausedAt: true,
      totalDuration: totalDuration,
      correctCount: correctCount,
      wrongCount: wrongCount,
      accuracy: accuracy,
      averageCardDuration: averageCardDuration,
    );

    _studySessions[index] = updatedSession;

    if (isCompleted) {
      final setIndex = _sets.indexWhere((set) => set.id == session.setId);
      if (setIndex != -1) {
        _sets[setIndex] = _sets[setIndex].copyWith(
          lastStudiedAt: evaluatedAt,
        );
      }
    }

    notifyListeners();
    return updatedSession;
  }
}
