import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import 'add_set_page.dart';
import 'detail_set_page.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/responsive_scale.dart';
import '../widgets/word_ellipsis_text.dart';

class BerkasPage extends StatefulWidget {
  const BerkasPage({super.key});

  @override
  State<BerkasPage> createState() => _BerkasPageState();
}

class _BerkasPageState extends State<BerkasPage> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor  = Color(0xFFF3C279);

  static final FlashMindRepository _repository = FlashMindRepository.instance;

  bool   _showInterruptedSessions = false;
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

                var filtered = _showInterruptedSessions
                    ? allSets
                        .where((set) =>
                            _repository.getInProgressStudySessionForSet(set.id) != null)
                        .toList(growable: false)
                    : allSets;

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
                                        child: _FlashcardSetCard(
                                          set: set,
                                          onViewDetail: () =>
                                              _openDetail(context, set.id),
                                        ),
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
              isSearching
                  ? 'Tidak ada set yang cocok\ndengan "$_searchQuery"'
                  : _showInterruptedSessions
                      ? 'Tidak ada sesi belajar yang terhenti.\nSemua sesi sudah selesai!'
                      : 'Belum ada set flashcard.\nTekan "+ Tambah Set" untuk mulai.',
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
      MaterialPageRoute<bool>(builder: (_) => DetailSetPage(setId: setId)),
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
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AddSetPage()),
            ),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah Set'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: _primaryColor,
              elevation: 0,
              minimumSize: Size(0, 44 * s),
              padding: EdgeInsets.symmetric(
                  horizontal: 15 * s, vertical: 9 * s),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              textStyle: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        _FilterChip(
          label: 'Semua',
          selected: !_showInterruptedSessions,
          onPressed: () {
            if (_showInterruptedSessions) {
              setState(() => _showInterruptedSessions = false);
            }
          },
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: 'Sesi Terhenti',
          selected: _showInterruptedSessions,
          onPressed: () {
            if (!_showInterruptedSessions) {
              setState(() => _showInterruptedSessions = true);
            }
          },
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFF192A3A) : Colors.white,
        foregroundColor: selected ? Colors.white : const Color(0xFF192A3A),
        side: BorderSide(
          color: selected ? const Color(0xFF192A3A) : const Color(0xFFE8E4DB),
          width: 1.5,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 9 * s),
        minimumSize: Size(0,5 * s),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

class _FlashcardSetCard extends StatelessWidget {
  const _FlashcardSetCard({
    required this.set,
    required this.onViewDetail,
  });

  final FlashcardSet set;
  final VoidCallback onViewDetail;

  static const Color _primaryColor = Color(0xFF192A3A);

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: WordEllipsisText(
                  set.title,
                  maxLines: 1,
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 17 * s,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${set.cardCount} kartu',
                style: TextStyle(color: Colors.grey, fontSize: 11 * s),
              ),
            ],
          ),
          if (set.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            WordEllipsisText(
              set.description,
              maxLines: 2,
              style: TextStyle(color: Colors.grey, fontSize: 12 * s, height: 1.3),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewDetail,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE87A5D),
                padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lihat Detail →',
                style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}