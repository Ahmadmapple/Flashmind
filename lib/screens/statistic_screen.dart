import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

import 'detail_set_screen.dart';
import 'study_history_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: FlashMindRepository.instance,
      builder: (context, _) => _buildContent(context),
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

    final recentSets = repo.recentStudiedSets(limit: 3);

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
            const SizedBox(height: 18),

            const Text(
              'Performa Pengguna',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: _primary,
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 18),

            const Text(
              'Wawasan Belajar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: _primary,
              ),
            ),
            const SizedBox(height: 10),
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
                  _InsightRow(
                    label: 'Konsistensi tertinggi',
                    value: '$highestStreak hari',
                  ),
                  if (best != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Color(0xFFE8E4DB), height: 1),
                    ),
                    Text(
                      'Set yang paling dikuasai',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 6),
                    _InsightSetBox(
                      setTitle: best.title,
                      duration: Formatter.duration(
                        repo.getCompletedStudySessionsForSet(best.id).isEmpty
                            ? Duration.zero
                            : repo.getCompletedStudySessionsForSet(best.id).last.totalDuration,
                      ),
                      detail: 'Akurasi: ${Formatter.percent(repo.bestMasteredAccuracy(best.id))}',
                    ),
                  ],
                  if (worst != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Color(0xFFE8E4DB), height: 1),
                    ),
                    Text(
                      'Set yang perlu diperhatikan',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 6),
                    _InsightSetBox(
                      setTitle: worst.title,
                      duration: Formatter.duration(
                        repo.getCompletedStudySessionsForSet(worst.id).isEmpty
                            ? Duration.zero
                            : repo.getCompletedStudySessionsForSet(worst.id).last.totalDuration,
                      ),
                      detail: 'Akurasi: ${Formatter.percent(repo.worstSetAccuracy(worst.id))}',
                    ),
                  ],
                  if (best == null && worst == null)
                    const Text(
                      'Belum ada data. Mulai belajar untuk melihat wawasan.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Riwayat Belajar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: _primary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const StudyHistoryScreen()),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: _orange,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lihat semua',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (recentSets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
                ),
                child: Column(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 36, color: Colors.grey.shade300),
                    const SizedBox(height: 10),
                    const Text(
                      'Belum ada riwayat belajar.',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Buka set kartu dan mulai belajar\nuntuk melihat riwayat di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...recentSets.map((set) {
                final latest = repo.getLatestCompletedSessionForSet(set.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: StudyHistoryCard(
                    title: set.title,
                    cardCount: set.cardCount,
                    lastStudiedLabel: latest == null
                        ? 'Belum pernah'
                        : Formatter.relativeTime(
                            latest.finishedAt ?? latest.startedAt),
                    accuracy: latest?.accuracy,
                    onViewDetail: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => DetailSetScreen(setId: set.id)),
                    ),
                  ),
                );
              }
            ),
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

class _InsightSetBox extends StatelessWidget {
  const _InsightSetBox({
    required this.setTitle,
    required this.duration,
    required this.detail,
  });

  final String setTitle;
  final String duration;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3C279),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  setTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF192A3A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                detail,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF192A3A)),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Durasi penyelesaian: $duration',
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF192A3A),
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}