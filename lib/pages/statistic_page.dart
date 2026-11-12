import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';
import 'detail_set_page.dart';
import 'study_history_page.dart'; ////

enum _Filter { tujuhHari, tigaPuluhHari, keseluruhan }

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  _Filter _filter = _Filter.tujuhHari;

  static const Color _primary = Color(0xFF192A3A);
  static const Color _orange  = Color(0xFFE87A5D);
  static const Color _green   = Color(0xFF2F776F);

  static String _fmtDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String _fmtRelative(DateTime? dt) {
    if (dt == null) return 'Belum pernah';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '-';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _fmtAccuracy(double a) => '${a.toStringAsFixed(0)}%';

  List<StudySession> _filteredSessions(FlashMindRepository repo) {
    final now = DateTime.now();
    switch (_filter) {
      case _Filter.tujuhHari:
        return repo.getSessionsInRange(now.subtract(const Duration(days: 7)), now);
      case _Filter.tigaPuluhHari:
        return repo.getSessionsInRange(now.subtract(const Duration(days: 30)), now);
      case _Filter.keseluruhan:
        return repo.allCompletedSessions.toList();
    }
  }

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

            Row(
              children: [
                _FilterChip(
                  label: '7 Hari',
                  selected: _filter == _Filter.tujuhHari,
                  onTap: () => setState(() => _filter = _Filter.tujuhHari),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '30 Hari',
                  selected: _filter == _Filter.tigaPuluhHari,
                  onTap: () => setState(() => _filter = _Filter.tigaPuluhHari),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Keseluruhan',
                  selected: _filter == _Filter.keseluruhan,
                  onTap: () => setState(() => _filter = _Filter.keseluruhan),
                ),
              ],
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
                  _SummaryBox(label: 'Total durasi belajar', value: _fmtDuration(totalDur)),
                  _SummaryBox(label: 'Akurasi', value: _fmtAccuracy(accuracy)),
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
                      final int totalAnswered =
                          sessions.fold<int>(0, (s, x) => s + x.correctCount) +
                          sessions.fold<int>(0, (s, x) => s + x.wrongCount);
                      final double correctFraction = totalAnswered == 0
                          ? 0.5
                          : sessions.fold<int>(0, (s, x) => s + x.correctCount) /
                              totalAnswered;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 8,
                          child: Row(
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
                    value:
                        '${sessions.fold<int>(0, (s, x) => s + x.correctCount)} '
                        '(${_fmtAccuracy(accuracy)})',
                    valueColor: _green,
                  ),
                  const SizedBox(height: 6),
                  _PerformRow(
                    label: 'Jumlah Salah',
                    value:
                        '${sessions.fold<int>(0, (s, x) => s + x.wrongCount)} '
                        '(${_fmtAccuracy(sessions.isEmpty ? 0 : 100 - accuracy)})',
                    valueColor: _orange,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Color(0xFFE8E4DB), height: 1),
                  ),
                  if (sessions.isNotEmpty) ...[
                    _PerformRow(
                      label: 'Rata-rata durasi per sesi',
                      value: _fmtDuration(Duration(
                          microseconds: totalDur.inMicroseconds ~/ sessions.length)),
                    ),
                    const SizedBox(height: 6),
                    _PerformRow(
                      label: 'Rata-rata durasi per kartu',
                      value: _fmtDuration(totalCards == 0
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
                      duration: _fmtDuration(
                        repo.getCompletedStudySessionsForSet(best.id).isEmpty
                            ? Duration.zero
                            : repo.getCompletedStudySessionsForSet(best.id).last.totalDuration,
                      ),
                      detail: 'Akurasi: ${_fmtAccuracy(repo.bestMasteredAccuracy(best.id))}',
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
                      duration: _fmtDuration(
                        repo.getCompletedStudySessionsForSet(worst.id).isEmpty
                            ? Duration.zero
                            : repo.getCompletedStudySessionsForSet(worst.id).last.totalDuration,
                      ),
                      detail: 'Akurasi: ${_fmtAccuracy(repo.worstSetAccuracy(worst.id))}',
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
                        builder: (_) => const StudyHistoryPage()),
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
                final setSessions = repo.getCompletedStudySessionsForSet(set.id);
                final lastAcc     = setSessions.isEmpty ? null : setSessions.last.accuracy;
                final inProg      = repo.getInProgressStudySessionForSet(set.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistoryCard(
                    set: set,
                    lastAcc: lastAcc,
                    lastStudied: _fmtRelative(set.lastStudiedAt),
                    lastStudiedDate: _fmtDate(set.lastStudiedAt),
                    isInProgress: inProg != null,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => DetailSetPage(setId: set.id)),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF192A3A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF192A3A) : const Color(0xFFE8E4DB),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF192A3A),
          ),
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.set,
    required this.lastAcc,
    required this.lastStudied,
    required this.lastStudiedDate,
    required this.isInProgress,
    required this.onTap,
  });

  final FlashcardSet set;
  final double? lastAcc;
  final String lastStudied;
  final String lastStudiedDate;
  final bool isInProgress;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF192A3A);
  static const Color _orange  = Color(0xFFE87A5D);
  static const Color _green   = Color(0xFF2F776F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                    fontSize: 14,
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
          if (isInProgress) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Terhenti',
                style: TextStyle(
                    fontSize: 10, color: _orange, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 3),
          Text(
            'Terakhir dipelajari: $lastStudiedDate',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          if (lastAcc != null)
            Text(
              'Tingkat kebenaran: ${lastAcc!.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: lastAcc! < 70 ? _orange : _green,
              ),
            ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: _orange,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat Detail →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
