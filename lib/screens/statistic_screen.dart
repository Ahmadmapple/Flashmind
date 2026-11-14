import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/formatter.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

import 'detail_set_screen.dart';
import 'study_history_screen.dart';
import 'study_session_end_screen.dart';
import '../widgets/app_empty_card.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_stat_box.dart';
import '../widgets/history_range_filter.dart';
import '../utils/responsive_scale.dart';
import '../widgets/study_history_card.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  HistoryRange _range = HistoryRange.week;

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
    final Duration? avgDuration = repo.getAverageDurationForSet(set.id);
    return StudyHistoryCard(
      compact: true,
      title: set.title,
      cardCount: set.cardCount,
      timeCaption: 'Durasi pengerjaan',
      lastStudiedLabel:
          avgDuration == null ? '-' : Formatter.duration(avgDuration),
      accuracy: repo.getAverageAccuracyForSet(set.id),
      onViewDetail: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => DetailSetScreen(setId: set.id)),
      ),
    );
  }

  // Garis pemisah antar komponen Wawasan Belajar.
  static const Widget _insightDivider = Padding(
    padding: EdgeInsets.symmetric(vertical: 14),
    child: Divider(color: AppColors.border, height: 1),
  );

  Widget _buildContent(BuildContext context) {
    final double s = context.scale;
    final repo = FlashMindRepository.instance;
    final sessions = _filteredSessions(repo);
    final sets = repo.sets;

    final int totalSessions = sessions.length;
    final int totalCards = sessions.fold(0, (s, x) => s + x.completedCardCount);
    final Duration totalDur =
        sessions.fold(Duration.zero, (d, x) => d + x.totalDuration);
    final double accuracy = sessions.isEmpty
        ? 0
        : sessions.fold<double>(0, (s, x) => s + x.accuracy) / sessions.length;
    final int totalSets = sets.length;

    // Data performa dihitung dari sesi pada rentang yang dipilih.
    final int totalCorrect = sessions.fold<int>(0, (s, x) => s + x.correctCount);
    final int totalWrong = sessions.fold<int>(0, (s, x) => s + x.wrongCount);
    final int totalAnswered = totalCorrect + totalWrong;
    final int correctPct =
        totalAnswered == 0 ? 0 : (totalCorrect / totalAnswered * 100).round();
    final int wrongPct = totalAnswered == 0 ? 0 : 100 - correctPct;
    final double correctFraction =
        totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;

    final int highestStreak = repo.highestStreak;
    final FlashcardSet? best = repo.bestMasteredSet;
    final FlashcardSet? worst = repo.worstSet;

    // Riwayat Belajar menampilkan sesi terbaru dahulu, maksimal 3.
    final List<StudySession> recentSessions = (repo.allCompletedSessions
            .toList()
          ..sort((a, b) => _endOf(b).compareTo(_endOf(a))))
        .take(3)
        .toList();

    // Set terburuk hanya tampil bila berbeda dari set terbaik.
    final bool showWorst = worst != null && worst.id != best?.id;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: AppContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistik',
                style: TextStyle(
                  fontSize: AppFont.page * s,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Data Belajar Pengguna',
                style: TextStyle(
                  fontSize: AppFont.caption * s,
                  fontWeight: FontWeight.bold,
                  color: AppColors.link,
                  letterSpacing: 1.2,
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppStatGrid(
                  items: [
                    ('Total sesi selesai', '$totalSessions'),
                    ('Total kartu diulas', '$totalCards'),
                    ('Total durasi belajar', Formatter.duration(totalDur)),
                    ('Tingkat kebenaran', Formatter.percent(accuracy)),
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 8 * s,
                            child: totalAnswered == 0
                                // Belum ada data pada rentang ini: bar netral
                                ? Container(color: AppColors.border)
                                : Row(
                                    children: [
                                      Container(
                                        width: constraints.maxWidth *
                                            correctFraction,
                                        color: AppColors.success,
                                      ),
                                      Expanded(
                                          child: Container(
                                              color: AppColors.danger)),
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
                      valueColor: AppColors.success,
                    ),
                    const SizedBox(height: 6),
                    _PerformRow(
                      label: 'Jumlah Salah',
                      value: '$totalWrong (${Formatter.percent(wrongPct)})',
                      valueColor: AppColors.danger,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                    if (sessions.isNotEmpty) ...[
                      _PerformRow(
                        label: 'Rata-rata durasi per sesi',
                        value: Formatter.duration(Duration(
                            microseconds:
                                totalDur.inMicroseconds ~/ sessions.length)),
                      ),
                      const SizedBox(height: 6),
                      _PerformRow(
                        label: 'Rata-rata durasi per kartu',
                        value: Formatter.duration(totalCards == 0
                            ? Duration.zero
                            : Duration(
                                microseconds:
                                    totalDur.inMicroseconds ~/ totalCards)),
                      ),
                      const SizedBox(height: 6),
                    ],
                    _PerformRow(label: 'Total set', value: '$totalSets set'),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Wawasan Belajar
              const AppSectionHeader(title: 'Wawasan Belajar'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InsightRow(
                      label: 'Konsistensi tertinggi',
                      value: '$highestStreak hari',
                    ),
                    if (best != null) ...[
                      _insightDivider,
                      const _InsightLabel('Set yang paling dikuasai'),
                      const SizedBox(height: 10),
                      _buildInsightSetCard(context, repo, best),
                    ],
                    if (showWorst) ...[
                      _insightDivider,
                      const _InsightLabel('Set yang paling perlu diperhatikan'),
                      const SizedBox(height: 10),
                      _buildInsightSetCard(context, repo, worst),
                    ],
                    if (best == null) ...[
                      _insightDivider,
                      Text(
                        'Belum ada wawasan belajar. Selesaikan sesi belajar untuk melihat set yang paling dikuasai dan perlu diperhatikan.',
                        style: TextStyle(
                          fontSize: AppFont.body * s,
                          color: AppColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
                  subtitle:
                      'Selesaikan sesi belajar agar\nriwayatnya muncul di sini.',
                )
              else
                ...recentSessions.map((session) {
                  final set = repo.getSetById(session.setId);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StudyHistoryCard(
                      title: set?.title ?? session.setTitle ?? 'Set yang dihapus',
                      cardCount: set?.cardCount ?? session.totalCardCount,
                      timeCaption: 'Waktu diselesaikan',
                      lastStudiedLabel: Formatter.relativeTime(_endOf(session)),
                      accuracy: session.accuracy,
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
      ),
    );
  }
}

class _PerformRow extends StatelessWidget {
  const _PerformRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.primary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label,
              style: TextStyle(fontSize: AppFont.body * s, color: AppColors.muted)),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
              fontSize: AppFont.body * s,
              fontWeight: FontWeight.w600,
              color: valueColor),
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
    final double s = context.scale;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: AppFont.bodyLarge * s, color: AppColors.muted)),
        Text(
          value,
          style: TextStyle(
              fontSize: AppFont.subtitle * s,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
      ],
    );
  }
}

// Label kecil di atas kartu set pada Wawasan Belajar
class _InsightLabel extends StatelessWidget {
  const _InsightLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: AppFont.bodyLarge * context.scale, color: AppColors.muted),
    );
  }
}