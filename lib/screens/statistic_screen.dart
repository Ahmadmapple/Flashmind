import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

import 'detail_set_screen.dart';
import 'study_history_screen.dart';
import 'study_session_end_screen.dart';
import '../widgets/app_empty_card.dart';
import '../widgets/app_section_header.dart';
import '../widgets/history_range_filter.dart';
import '../widgets/study_history_card.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  HistoryRange _range = HistoryRange.week;

  static const Color _primary = Color(0xFF192A3A);
  static const Color _orange  = Color(0xFFE87A5D);
  static const Color _green   = Color(0xFF2F776F);

  List<StudySession> _filteredSessions(FlashMindRepository repo) =>
      _range.filter(repo.allCompletedSessions);

  static DateTime _endOf(StudySession s) => s.finishedAt ?? s.startedAt;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FlashMindRepository.instance,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildInsightSetCard(
      BuildContext context, FlashMindRepository repo, FlashcardSet set) {
    final latest = repo.getLatestCompletedSessionForSet(set.id);
    return StudyHistoryCard(
      title: set.title,
      cardCount: set.cardCount,
      lastStudiedLabel: latest == null
          ? 'Belum pernah'
          : Formatter.relativeTime(latest.finishedAt ?? latest.startedAt),
      accuracy: repo.getAverageAccuracyForSet(set.id),
      onViewDetail: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (_) => DetailSetScreen(setId: set.id)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final repo     = FlashMindRepository.instance;
    final sessions = _filteredSessions(repo);
    final sets     = repo.sets;

    final int totalSessions = sessions.length;
    final int totalCards    = sessions.fold(0, (s, x) => s + x.completedCardCount);
    final Duration totalDur = sessions.fold(Duration.zero, (d, x) => d + x.totalDuration);
    final double accuracy   = sessions.isEmpty
        ? 0
        : sessions.fold<double>(0, (s, x) => s + x.accuracy) / sessions.length;
    final int totalSets     = sets.length;

    // Data performa dihitung dari sesi pada rentang yang dipilih.
    final int totalCorrect  = sessions.fold<int>(0, (s, x) => s + x.correctCount);
    final int totalWrong    = sessions.fold<int>(0, (s, x) => s + x.wrongCount);
    final int totalAnswered = totalCorrect + totalWrong;
    final int correctPct = totalAnswered == 0
        ? 0
        : (totalCorrect / totalAnswered * 100).round();
    final int wrongPct = totalAnswered == 0 ? 0 : 100 - correctPct;
    final double correctFraction =
        totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;

    final int highestStreak   = repo.highestStreak;
    final FlashcardSet? best  = repo.bestMasteredSet;
    final FlashcardSet? worst = repo.worstSet;

    // Riwayat Belajar menampilkan sesi terbaru dahulu, maksimal 3.
    final List<StudySession> recentSessions = (repo.allCompletedSessions
            .toList()
          ..sort((a, b) => _endOf(b).compareTo(_endOf(a))))
        .take(3)
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: _primary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Data Belajar Pengguna',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _orange,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            HistoryRangeFilter(
              selected: _range,
              onChanged: (r) => setState(() => _range = r),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF192A3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.7,
                children: [
                  _SummaryBox(label: 'Total sesi selesai', value: '$totalSessions'),
                  _SummaryBox(label: 'Total kartu diulas', value: '$totalCards'),
                  _SummaryBox(label: 'Total durasi belajar', value: Formatter.duration(totalDur)),
                  _SummaryBox(label: 'Tingkat kebenaran', value: Formatter.percent(accuracy)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Performa Pengguna
            const AppSectionHeader(title: 'Performa Pengguna'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 8,
                          child: totalAnswered == 0
                              // Belum ada data pada rentang ini: bar netral
                              ? Container(color: const Color(0xFFE8E4DB))
                              : Row(
                                  children: [
                                    Container(
                                      width: constraints.maxWidth * correctFraction,
                                      color: _green,
                                    ),
                                    Expanded(child: Container(color: _orange)),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _PerformRow(
                    label: 'Jumlah Benar',
                    value: '$totalCorrect (${Formatter.percent(correctPct)})',
                    valueColor: _green,
                  ),
                  const SizedBox(height: 6),
                  _PerformRow(
                    label: 'Jumlah Salah',
                    value: '$totalWrong (${Formatter.percent(wrongPct)})',
                    valueColor: _orange,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Color(0xFFE8E4DB), height: 1),
                  ),
                  if (sessions.isNotEmpty) ...[
                    _PerformRow(
                      label: 'Rata-rata durasi per sesi',
                      value: Formatter.duration(Duration(
                          microseconds: totalDur.inMicroseconds ~/ sessions.length)),
                    ),
                    const SizedBox(height: 6),
                    _PerformRow(
                      label: 'Rata-rata durasi per kartu',
                      value: Formatter.duration(totalCards == 0
                          ? Duration.zero
                          : Duration(
                              microseconds: totalDur.inMicroseconds ~/ totalCards)),
                    ),
                    const SizedBox(height: 6),
                  ],
                  _PerformRow(label: 'Total set aktif', value: '$totalSets set'),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Wawasan Belajar
            const AppSectionHeader(title: 'Wawasan Belajar'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
              ),
              child: _InsightRow(
                label: 'Konsistensi tertinggi',
                value: '$highestStreak hari',
              ),
            ),
            if (best != null) ...[
              const SizedBox(height: 14),
              const _InsightLabel('Set yang paling dikuasai'),
              const SizedBox(height: 8),
              _buildInsightSetCard(context, repo, best),
            ],
            // Set terburuk hanya tampil bila berbeda dari set terbaik.
            if (worst != null && worst.id != best?.id) ...[
              const SizedBox(height: 14),
              const _InsightLabel('Set yang paling perlu diperhatikan'),
              const SizedBox(height: 8),
              _buildInsightSetCard(context, repo, worst),
            ],
            if (best == null) ...[
              const SizedBox(height: 12),
              const AppEmptyCard(
                icon: Icons.insights_rounded,
                title: 'Belum ada wawasan belajar.',
                subtitle: 'Selesaikan sesi belajar untuk melihat set\nyang paling dikuasai dan perlu diperhatikan.',
              ),
            ],
            const SizedBox(height: 25),

            // Riwayat Belajar
            AppSectionHeader(
              title: 'Riwayat Belajar',
              actionLabel: 'Lihat semua →',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                    builder: (_) => const StudyHistoryScreen()),
              ),
            ),
            const SizedBox(height: 12),
            if (recentSessions.isEmpty)
              const AppEmptyCard(
                icon: Icons.menu_book_rounded,
                title: 'Belum ada sesi yang selesai.',
                subtitle: 'Selesaikan sesi belajar agar\nriwayatnya muncul di sini.',
              )
            else
              ...recentSessions.map((session) {
                final set = repo.getSetById(session.setId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StudyHistoryCard(
                    title: set?.title ?? session.setTitle ?? 'Set yang dihapus',
                    cardCount: set?.cardCount ?? session.totalCardCount,
                    lastStudiedLabel: Formatter.relativeTime(_endOf(session)),
                    accuracy: session.accuracy,
                    // [DIUBAH] mengarah ke layar sesi belajar akhir pada sesi ini.
                    onViewDetail: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StudySessionEndScreen(
                          setId: session.setId,
                          sessionId: session.id,
                        ),
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

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3C279),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF192A3A),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF192A3A),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformRow extends StatelessWidget {
  const _PerformRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF192A3A),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF192A3A)),
        ),
      ],
    );
  }
}

// Label kecil di atas kartu set pada Wawasan Belajar.
class _InsightLabel extends StatelessWidget {
  const _InsightLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}