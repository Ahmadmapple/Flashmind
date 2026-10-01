import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';
import 'detail_set_page.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  static const Color _primary = Color(0xFF192A3A);
  static const Color _orange  = Color(0xFFE87A5D);

  // ── Format helpers ─────────────────────────────────────────────────────────

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

  static String _formatAccuracy(double a) =>
      '${a.toStringAsFixed(0)}%';

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

    // Agregat keseluruhan
    final totalSessions    = sessions.length;
    final totalCardsStudied = sessions.fold<int>(
      0, (sum, s) => sum + s.completedCardCount,
    );
    final totalActiveSet   = sets.length;
    final overallAccuracy  = sessions.isEmpty
        ? 0.0
        : sessions.fold<double>(0, (sum, s) => sum + s.accuracy) /
            sessions.length;

    // Sesi terbaru
    final StudySession? latestSession = sessions.isEmpty
        ? null
        : sessions.reduce(
            (a, b) => (a.finishedAt ?? a.startedAt)
                    .isAfter(b.finishedAt ?? b.startedAt)
                ? a
                : b,
          );

    FlashcardSet? latestSet;
    if (latestSession != null) {
      latestSet = repo.getSetById(latestSession.setId);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
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
              'RIWAYAT BELAJAR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _orange,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            // ── Overall card ───────────────────────────────────────────────
            _OverallCard(
              accuracy: overallAccuracy,
              totalSessions: totalSessions,
              totalCardsStudied: totalCardsStudied,
              totalActiveSets: totalActiveSet,
            ),
            const SizedBox(height: 24),

            // ── Sesi terbaru ───────────────────────────────────────────────
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

            // ── Semua set ──────────────────────────────────────────────────
            const Text(
              'Semua Set',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: _primary,
              ),
            ),
            const SizedBox(height: 12),

            if (sets.isEmpty)
              const _EmptySetList()
            else
              ...sets.map((set) {
                final setSessions =
                    repo.getCompletedStudySessionsForSet(set.id);
                final lastAcc = setSessions.isEmpty
                    ? null
                    : setSessions.last.accuracy;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SetStatCard(
                    set: set,
                    lastAccuracy: lastAcc,
                    formatAccuracy: _formatAccuracy,
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

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Overall card
// ─────────────────────────────────────────────────────────────────────────────

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
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Latest session card
// ─────────────────────────────────────────────────────────────────────────────

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
        child: const Text(
          'Belum ada sesi belajar.\nMulai belajar untuk melihat riwayat di sini.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
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
          // Judul + waktu
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDECE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check, color: Color(0xFF2F776F), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      set!.title,
                      style: const TextStyle(
                        color: Color(0xFF192A3A),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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
                      fontSize: 16,
                    ),
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
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8A9A9E)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF192A3A),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Set stat card
// ─────────────────────────────────────────────────────────────────────────────

class _SetStatCard extends StatelessWidget {
  const _SetStatCard({
    required this.set,
    required this.lastAccuracy,
    required this.formatAccuracy,
    required this.onTap,
  });

  final FlashcardSet set;
  final double? lastAccuracy;
  final String Function(double) formatAccuracy;
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
                Text(
                  set.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF192A3A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${set.cardCount} kartu',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (lastAccuracy != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${formatAccuracy(lastAccuracy!)} terakhir',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2F776F),
                      fontWeight: FontWeight.w500,
                    ),
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

class _EmptySetList extends StatelessWidget {
  const _EmptySetList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
      ),
      child: const Text(
        'Belum ada set. Buat set di halaman Berkas.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }
}
