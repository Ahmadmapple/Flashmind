import 'package:flashmind/widgets/app_item_card.dart';
import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import '../services/review_recommendation.dart';

import 'add_set_screen.dart';
import 'detail_set_screen.dart';

import '../widgets/app_bottom_nav.dart';
import '../widgets/app_filter_chip.dart';
import '../widgets/responsive_scale.dart';
import '../widgets/study_history_card.dart';
import '../widgets/word_ellipsis_text.dart';
import '../widgets/app_button.dart';

// Filter pada halaman berkas
enum BerkasFilter { semua, sesiTerhenti, perluDiulas }

class BerkasScreen extends StatefulWidget {
  const BerkasScreen({super.key});

  @override
  State<BerkasScreen> createState() => BerkasScreenState();
}

class BerkasScreenState extends State<BerkasScreen> {
  static const Color _primaryColor = Color(0xFF192A3A);

  static final FlashMindRepository _repository = FlashMindRepository.instance;

  BerkasFilter _filter = BerkasFilter.semua;

  // Dipanggil dari Beranda untuk membuka daftar dengan filter Perlu Diulas.
  void showReviewFilter() {
    if (_filter != BerkasFilter.perluDiulas) {
      setState(() => _filter = BerkasFilter.perluDiulas);
    }
  }

  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const double _bottomBarHeight = AppNavStyle.barHeight;

  double _keyboardOverlap(BuildContext context) {
    final double overlap =
        MediaQuery.of(context).viewInsets.bottom - _bottomBarHeight;
    return overlap > 0 ? overlap : 0;
  }

  // Menentukan daftar set sesuai filter yang dipilih
  List<FlashcardSet> _applyFilter(List<FlashcardSet> allSets) {
    switch (_filter) {
      case BerkasFilter.semua:
        return allSets;
      case BerkasFilter.sesiTerhenti:
        return allSets
            .where((set) =>
                _repository.getInProgressStudySessionForSet(set.id) != null)
            .toList(growable: false);
      case BerkasFilter.perluDiulas:
        return ReviewRecommendation.dueSets(_repository);
    }
  }

  // Daftar set pada filter "Perlu Diulas"
  Widget _buildSetItem(BuildContext context, FlashcardSet set) {
    if (_filter == BerkasFilter.perluDiulas) {
      final latest = _repository.getLatestCompletedSessionForSet(set.id);
      return StudyHistoryCard(
        title: set.title,
        cardCount: set.cardCount,
        lastStudiedLabel: latest == null
            ? 'Belum pernah'
            : Formatter.relativeTime(latest.finishedAt ?? latest.startedAt),
        accuracy: _repository.getAverageAccuracyForSet(set.id),
        onViewDetail: () => _openDetail(context, set.id),
      );
    }
    return _FlashcardSetCard(
      set: set,
      onViewDetail: () => _openDetail(context, set.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SafeArea(
            top: false,
            minimum: EdgeInsets.only(bottom: _keyboardOverlap(context)),
            child: AnimatedBuilder(
              animation: _repository,
              builder: (context, _) {
                final allSets = _repository.sets;

                var filtered = _applyFilter(allSets);

                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered
                      .where((s) => s.title.toLowerCase().contains(q))
                      .toList(growable: false);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: _buildSearchBar(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _buildFilterRow(),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: filtered
                                    .map(
                                      (set) => Padding(
                                        padding: const EdgeInsets.only(bottom: 14),
                                        child: _buildSetItem(context, set),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final double s = ResponsiveScale.of(context);
    return Container(
      height: 45 * s,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25 * s),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(fontSize: 15 * s, color: const Color(0xFF192A3A)),
        decoration: InputDecoration(
          hintText: 'Cari set flashcard',
          hintStyle: TextStyle(fontSize: 15 * s, color: const Color(0xFFB4B1AC)),
          prefixIcon: Icon(Icons.search, color: const Color(0xFF9A9894), size: 22 * s),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: const Color(0xFF9A9894), size: 18 * s),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final double s = ResponsiveScale.of(context);
    final isSearching = _searchQuery.isNotEmpty;

    // Pesan kosong untuk setiap filter
    final String message;
    if (isSearching) {
      message = 'Tidak ada set yang cocok\ndengan "$_searchQuery"';
    } else {
      switch (_filter) {
        case BerkasFilter.sesiTerhenti:
          message =
              'Tidak ada sesi belajar yang terhenti.\nSemua sesi sudah selesai!';
        case BerkasFilter.perluDiulas:
          message = 'Tidak ada set yang perlu diulas saat ini.';
        case BerkasFilter.semua:
          message =
              'Belum ada set flashcard.\nTekan "+ Tambah Set" untuk mulai.';
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.folder_open,
              size: 44 * s,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15 * s),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(BuildContext context, String setId) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => DetailSetScreen(setId: setId)),
    );

    if (deleted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 80),
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 18, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Berkas',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 30 * s,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
                Text(
                  'Daftar Set Flashcard',
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE87A5D),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            label: 'Tambah Set',
            icon: Icons.add,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AddSetScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // Area filter daftar set
  Widget _buildFilterRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        AppFilterChip(
          label: 'Semua',
          selected: _filter == BerkasFilter.semua,
          onPressed: () => _setFilter(BerkasFilter.semua),
        ),
        AppFilterChip(
          label: 'Sesi Terhenti',
          selected: _filter == BerkasFilter.sesiTerhenti,
          onPressed: () => _setFilter(BerkasFilter.sesiTerhenti),
        ),
        AppFilterChip(
          label: 'Perlu Diulas',
          selected: _filter == BerkasFilter.perluDiulas,
          onPressed: () => _setFilter(BerkasFilter.perluDiulas),
        ),
      ],
    );
  }

  void _setFilter(BerkasFilter next) {
    if (_filter != next) setState(() => _filter = next);
  }
}

class _FlashcardSetCard extends StatelessWidget {
  const _FlashcardSetCard({
    required this.set,
    required this.onViewDetail,
  });

  final FlashcardSet set;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return AppItemCard(
      header: AppSetCardHeader(title: set.title, cardCount: set.cardCount),
      body: set.description.isEmpty
          ? null
          : WordEllipsisText(
              set.description,
              maxLines: 2,
              style: TextStyle(color: Colors.grey, fontSize: 13 * s, height: 1.3),
            ),
      footer: Align(
        alignment: Alignment.centerRight,
        child: AppDetailLink(onPressed: onViewDetail),
      ),
    );
  }
}