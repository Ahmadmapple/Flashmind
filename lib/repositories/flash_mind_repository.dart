import 'package:flutter/foundation.dart';

import '../models/flashcard.dart';
import '../models/flashcard_set.dart';

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
  int _nextSetNumber = 4;
  int _nextCardNumber = 1;

  List<FlashcardSet> get sets => List.unmodifiable(_sets);

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

  Future<void> deleteSet(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final index = _sets.indexWhere((set) => set.id == id);
    if (index == -1) return;

    _sets.removeAt(index);
    notifyListeners();
  }
}
