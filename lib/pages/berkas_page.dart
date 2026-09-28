import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import 'add_set_page.dart';
import 'detail_set_page.dart';

class BerkasPage extends StatelessWidget {
  const BerkasPage({super.key});

  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);

  static final FlashMindRepository _repository = FlashMindRepository.instance;

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
                final sets = _repository.sets;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterRow(),
                      const SizedBox(height: 18),
                      ...sets.map(
                        (set) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _FlashcardSetCard(
                            set: set,
                            onViewDetail: () => _openDetail(context, set.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openDetail(BuildContext context, String setId) async {
    // PERUBAHAN TAHAP 2: tombol Lihat Detail sekarang membuka Detail Set
    // menggunakan identitas set dari repository.
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => DetailSetPage(setId: setId)),
    );

    if (deleted == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 18, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Berkas',
                style: TextStyle(
                  letterSpacing: 1.2,
                  color: _primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              Text(
                'Daftar Set Flashcard',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE87A5D),
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AddSetPage()),
              );
            },
            style: ButtonStyle(
              backgroundColor: const WidgetStatePropertyAll(_accentColor),
              foregroundColor: const WidgetStatePropertyAll(_primaryColor),
              elevation: const WidgetStatePropertyAll(0),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              minimumSize: const WidgetStatePropertyAll(Size(0, 0)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            child: const Text(
              '+ Tambah Set',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        _FilterChip(label: 'Semuat Set', selected: true, onPressed: () {}),
        const SizedBox(width: 10),
        _FilterChip(label: 'Perlu Diulas', selected: false, onPressed: () {}),
      ],
    );
  }
}

class _FlashcardSetCard extends StatelessWidget {
  const _FlashcardSetCard({required this.set, required this.onViewDetail});

  final FlashcardSet set;
  final VoidCallback onViewDetail;

  static const Color _primaryColor = Color(0xFF192A3A);

  static const TextStyle _titleStyle = TextStyle(
    color: _primaryColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const String _ellipsis = ' ...';

  static const int _descriptionMaxLength = FlashcardSet.descriptionMaxLength;

  static String _truncateToFitWords(
    String text,
    TextStyle style,
    double maxWidth,
    TextScaler textScaler, {
    int maxLines = 1,
  }) {
    bool fits(String value) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: style),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: maxWidth);
      final bool exceeded = painter.didExceedMaxLines;
      painter.dispose();
      return !exceeded;
    }

    if (fits(text)) return text;

    final words = text.trim().split(RegExp(r'\s+'));
    for (int count = words.length - 1; count >= 1; count--) {
      final candidate = '${words.sublist(0, count).join(' ')}$_ellipsis';
      if (fits(candidate)) return candidate;
    }

    // Satu kata pertama saja sudah tidak muat: biarkan ellipsis bawaan Text
    // yang menangani (satu-satunya kasus pemotongan per huruf).
    return text;
  }

  static String _truncateByWords(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    final words = text.split(' ');
    final buffer = StringBuffer();
    for (final word in words) {
      final candidate = buffer.isEmpty ? word : '${buffer.toString()} $word';
      if (candidate.length > maxLength) break;
      buffer
        ..clear()
        ..write(candidate);
    }

    final trimmed = buffer.toString();
    return trimmed.isEmpty ? text.substring(0, maxLength) : '$trimmed...';
  }

  @override
  Widget build(BuildContext context) {
    final String description = _truncateByWords(
      set.description,
      _descriptionMaxLength,
    );

    final TextStyle effectiveTitleStyle = DefaultTextStyle.of(context).style
        .merge(_titleStyle);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E4DB), width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final String title = _truncateToFitWords(
                      set.title,
                      effectiveTitleStyle,
                      constraints.maxWidth,
                      textScaler,
                    );

                    return Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: effectiveTitleStyle,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${set.cardCount} Kartu',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.justify,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onViewDetail,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(left: 12, right: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat Detail →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE87A5D),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  static const Color _primaryColor = Color(0xFF192A3A);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? _primaryColor : Colors.white,
        foregroundColor: selected ? Colors.white : _primaryColor,
        side: BorderSide(
          color: selected ? _primaryColor : const Color(0xFFE8E4DB),
          width: 1.5,
        ),
        elevation: 0,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}
