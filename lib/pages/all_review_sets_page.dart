import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import 'detail_set_page.dart';

class AllReviewSetsPage extends StatelessWidget {
  const AllReviewSetsPage({super.key});

  static const Color _primary = Color(0xFF192A3A);


  static String _formatRelative(DateTime? dt) {
    if (dt == null) return 'Belum pernah';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  static String _formatAccuracy(double a) => '${a.toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF9F6),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 26, color: _primary),
        ),
        title: const Text(
          'Ulas Kembali',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
            color: _primary,
          ),
        ),
        centerTitle: false,
      ),
      body: AnimatedBuilder(
        animation: FlashMindRepository.instance,
        builder: (context, _) {
          final repo = FlashMindRepository.instance;
          final sets = repo.reviewSets(limit: 999);

          if (sets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 14),
                  const Text(
                    'Tidak ada set yang perlu diulas.',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tambah set kartu dan mulai belajar\nuntuk mendapat rekomendasi ulasan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: sets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final set = sets[i];
              return _ReviewCard(
                set: set,
                formatRelative: _formatRelative,
                formatAccuracy: _formatAccuracy,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DetailSetPage(setId: set.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.set,
    required this.formatRelative,
    required this.formatAccuracy,
    required this.onTap,
  });

  final FlashcardSet set;
  final String Function(DateTime?) formatRelative;
  final String Function(double) formatAccuracy;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF192A3A);
  static const Color _orange  = Color(0xFFE87A5D);

  @override
  Widget build(BuildContext context) {
    final sessions = FlashMindRepository.instance
        .getCompletedStudySessionsForSet(set.id);
    final lastAcc = sessions.isEmpty ? null : sessions.last.accuracy;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${set.cardCount} kartu',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Terakhir dipelajari: ${formatRelative(set.lastStudiedAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (lastAcc != null) ...[
            const SizedBox(height: 2),
            Text(
              'Tingkat kebenaran: ${formatAccuracy(lastAcc)}',
              style: TextStyle(
                fontSize: 12,
                color: lastAcc < 70 ? _orange : const Color(0xFF2F776F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: _orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
