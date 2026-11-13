import 'package:flutter/material.dart';

import '../models/study_session.dart';
import 'app_filter_chip.dart';

// Rentang waktu yang dipakai bersama oleh layar Riwayat Belajar dan Statistik.
enum HistoryRange {
  week('7 Hari', 7),
  month('30 Hari', 30),
  all('Keseluruhan', null);

  const HistoryRange(this.label, this.days);
  final String label;
  final int? days;

  // Batas awal rentang dengan null berarti tanpa batas.
  DateTime? cutoff({DateTime? now}) {
    final int? d = days;
    if (d == null) return null;
    return (now ?? DateTime.now()).subtract(Duration(days: d));
  }

  bool includes(DateTime time, {DateTime? now}) {
    final DateTime? c = cutoff(now: now);
    return c == null || !time.isBefore(c);
  }

  // Menyaring sesi selesai berdasarkan waktu selesai.
  List<StudySession> filter(Iterable<StudySession> sessions, {DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    return sessions
        .where((s) => includes(s.finishedAt ?? s.startedAt, now: current))
        .toList();
  }
}

// Baris chip filter rentang waktu.
class HistoryRangeFilter extends StatelessWidget {
  const HistoryRangeFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HistoryRange selected;
  final ValueChanged<HistoryRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        for (final r in HistoryRange.values)
          AppFilterChip(
            label: r.label,
            selected: selected == r,
            onPressed: () {
              if (selected != r) onChanged(r);
            },
          ),
      ],
    );
  }
}