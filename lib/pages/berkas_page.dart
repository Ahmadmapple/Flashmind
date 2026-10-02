import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import 'add_set_page.dart';
import 'detail_set_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SafeArea(
            top: false,
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _buildFilterRow(),
                    ),
                    const SizedBox(height: 14),
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
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14, color: Color(0xFF192A3A)),
        decoration: InputDecoration(
          hintText: 'Cari set flashcard...',
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB4B1AC)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9A9894), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF9A9894), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
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
    final isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.folder_open,
              size: 40,
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
              style: const TextStyle(color: Colors.grey, fontSize: 13),
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 18, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Berkas',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
                Text(
                  'Daftar Set Flashcard',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE87A5D),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
        const SizedBox(width: 8),
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? const Color(0xFF192A3A) : Colors.white,
        foregroundColor: selected ? Colors.white : const Color(0xFF192A3A),
        side: BorderSide(
          color: selected ? const Color(0xFF192A3A) : const Color(0xFFE8E4DB),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
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
                child: Text(
                  set.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${set.cardCount} kartu',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          if (set.description.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              set.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.3),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewDetail,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE87A5D),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat Detail →',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
