import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';
import 'detail_set_page.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  static const Color _primary = Color(0xFF192A3A);
  static const Color _orange  = Color(0xFFE87A5D);

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}j ${m}m';
    if (m > 0) return '${m}m ${s}d';
    return '${s}d';
  }

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
    return AnimatedBuilder(
      animation: FlashMindRepository.instance,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final repo     = FlashMindRepository.instance;
    final sets     = repo.sets;
    final sessions = repo.allCompletedSessions;

    final totalSessions     = sessions.length;
    final totalCardsStudied = sessions.fold<int>(0, (sum, s) => sum + s.completedCardCount);
    final totalActiveSet    = sets.length;
    final overallAccuracy   = sessions.isEmpty
        ? 0.0
        : sessions.fold<double>(0, (sum, s) => sum + s.accuracy) / sessions.length;

    final StudySession? latestSession = sessions.isEmpty
        ? null
        : sessions.reduce(
            (a, b) => (a.finishedAt ?? a.startedAt).isAfter(b.finishedAt ?? b.startedAt) ? a : b,
          );

    final FlashcardSet? latestSet =
        latestSession != null ? repo.getSetById(latestSession.setId) : null;

    final studiedSets = sets.where((set) {
      final hasDone   = repo.getCompletedStudySessionsForSet(set.id).isNotEmpty;
      final hasInProg = repo.getInProgressStudySessionForSet(set.id) != null;
      return hasDone || hasInProg;
    }).toList()
      ..sort((a, b) =>
          (b.lastStudiedAt ?? DateTime(1970)).compareTo(a.lastStudiedAt ?? DateTime(1970)));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: _primary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'RINGKASAN BELAJAR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _orange,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            _OverallCard(
              accuracy: overallAccuracy,
              totalSessions: totalSessions,
              totalCardsStudied: totalCardsStudied,
              totalActiveSets: totalActiveSet,
            ),
            const SizedBox(height: 24),
            const Text(
              'Sesi Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: _primary,
              ),
            ),
            const SizedBox(height: 12),
            _LatestSessionCard(
              session: latestSession,
              set: latestSet,
              formatDuration: _formatDuration,
              formatRelative: _formatRelative,
              formatAccuracy: _formatAccuracy,
            ),
            const SizedBox(height: 24),
            const Text(
              'Riwayat Belajar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: _primary,
              ),
            ),
            const SizedBox(height: 12),
            if (studiedSets.isEmpty)
              _EmptyStudyHistory()
            else
              ...studiedSets.map((set) {
                final setSessions = repo.getCompletedStudySessionsForSet(set.id);
                final lastAcc     = setSessions.isEmpty ? null : setSessions.last.accuracy;
                final inProg      = repo.getInProgressStudySessionForSet(set.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SetStatCard(
                    set: set,
                    lastAccuracy: lastAcc,
                    isInProgress: inProg != null,
                    lastStudiedAt: set.lastStudiedAt,
                    formatAccuracy: _formatAccuracy,
                    formatRelative: _formatRelative,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DetailSetPage(setId: set.id),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({
    required this.accuracy,
    required this.totalSessions,
    required this.totalCardsStudied,
    required this.totalActiveSets,
  });

  final double accuracy;
  final int totalSessions;
  final int totalCardsStudied;
  final int totalActiveSets;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF192A3A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KESELURUHAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Color(0xFFF3C279),
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${accuracy.toStringAsFixed(0)}% ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 44,
                    fontFamily: 'serif',
                  ),
                ),
                const TextSpan(
                  text: 'tingkat hafalan',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFF2C455E)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatColumn(value: '$totalSessions', label: 'Sesi'),
              _StatColumn(value: '$totalCardsStudied', label: 'Kartu'),
              _StatColumn(value: '$totalActiveSets', label: 'Set Aktif'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _LatestSessionCard extends StatelessWidget {
  const _LatestSessionCard({
    required this.session,
    required this.set,
    required this.formatDuration,
    required this.formatRelative,
    required this.formatAccuracy,
  });

  final StudySession? session;
  final FlashcardSet? set;
  final String Function(Duration) formatDuration;
  final String Function(DateTime?) formatRelative;
  final String Function(double) formatAccuracy;

  @override
  Widget build(BuildContext context) {
    if (session == null || set == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(Icons.menu_book_rounded, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Belum ada sesi belajar.',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            const Text(
              'Buka salah satu set kartu dan mulai belajar\nuntuk melihat riwayat di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      set!.title,
                      style: const TextStyle(
                          color: Color(0xFF192A3A),
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Text(
                      formatRelative(session!.finishedAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${session!.correctCount}/${session!.totalCardCount}',
                    style: const TextStyle(
                        color: Color(0xFF2F776F),
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    formatAccuracy(session!.accuracy),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF9F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: 'Total durasi',
                    value: formatDuration(session!.totalDuration),
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: 'Rata-rata/kartu',
                    value: formatDuration(session!.averageCardDuration),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8A9A9E))),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192A3A))),
      ],
    );
  }
}

class _SetStatCard extends StatelessWidget {
  const _SetStatCard({
    required this.set,
    required this.lastAccuracy,
    required this.isInProgress,
    required this.lastStudiedAt,
    required this.formatAccuracy,
    required this.formatRelative,
    required this.onTap,
  });

  final FlashcardSet set;
  final double? lastAccuracy;
  final bool isInProgress;
  final DateTime? lastStudiedAt;
  final String Function(double) formatAccuracy;
  final String Function(DateTime?) formatRelative;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        set.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF192A3A)),
                      ),
                    ),
                    if (isInProgress) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE87A5D).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Terhenti',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFE87A5D),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text('${set.cardCount} kartu  ·  ${formatRelative(lastStudiedAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (lastAccuracy != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Skor terakhir: ${formatAccuracy(lastAccuracy!)}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2F776F),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE87A5D),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Lihat Detail →',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStudyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text(
            'Belum ada riwayat belajar.',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          const Text(
            'Buka set kartu di halaman Berkas\ndan mulai sesi belajar pertamamu.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
