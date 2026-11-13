import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

import '../widgets/app_bottom_nav.dart';
import '../widgets/app_filter_chip.dart';
import '../widgets/responsive_scale.dart';
import '../widgets/study_history_card.dart';


import 'study_session_end_screen.dart';

enum _HistoryRange {
  week('7 Hari', 7),
  month('30 Hari', 30),
  all('Keseluruhan', null);

  const _HistoryRange(this.label, this.days);
  final String label;
  final int? days;
}

class _HistoryEntry {
  const _HistoryEntry(this.session, this.set, this.finishedAt);
  final StudySession session;
  final FlashcardSet? set;
  final DateTime finishedAt;

  String get title => set?.title ?? session.setTitle ?? 'Set yang dihapus';
  int get cardCount => set?.cardCount ?? session.totalCardCount;
}

class StudyHistoryScreen extends StatefulWidget {
  const StudyHistoryScreen({super.key});

  @override
  State<StudyHistoryScreen> createState() => _StudyHistoryScreenState();
}

class _StudyHistoryScreenState extends State<StudyHistoryScreen> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _backgroundColor = Color(0xFFFBF9F6);

  final FlashMindRepository _repository = FlashMindRepository.instance;
  _HistoryRange _range = _HistoryRange.week;

  List<_HistoryEntry> _buildEntries() {
    final DateTime now = DateTime.now();
    final int? days = _range.days;
    final DateTime? cutoff = days == null ? null : now.subtract(Duration(days: days));

    final List<_HistoryEntry> entries = [];
    for (final session in _repository.allCompletedSessions) {
      final DateTime t = session.finishedAt ?? session.startedAt;
      if (cutoff != null && t.isBefore(cutoff)) continue;
      entries.add(_HistoryEntry(session, _repository.getSetById(session.setId), t));
    }
    entries.sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
    return entries;
  }

  void _openSessionResult(_HistoryEntry e) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudySessionEndScreen(
          setId: e.session.setId,
          sessionId: e.session.id,
        ),
      ),
    );
  }

  void _goBack() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _repository,
          builder: (context, _) {
            final entries = _buildEntries();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _buildFilterRow(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: entries.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: entries.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, i) {
                            final e = entries[i];
                            return StudyHistoryCard(
                              title: e.title,
                              cardCount: e.cardCount,
                              lastStudiedLabel: Formatter.relativeTime(e.finishedAt),
                              accuracy: e.session.accuracy,
                              onViewDetail: () => _openSessionResult(e),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: AppHomeFab(
        isActive: true,
        compact: true,
        onPressed: _goBack,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        selectedTab: AppNavTab.berkas,
        compact: true,
        elevation: 2,
        onBerkasTap: _goBack,
        onStatistikTap: null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final double s = ResponsiveScale.of(context);
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _goBack,
        icon: Icon(Icons.arrow_back, size: 28 * s),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: Text(
        'Riwayat Belajar',
        style: TextStyle(
          fontSize: 25 * s,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: _primaryColor,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildFilterRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        for (final r in _HistoryRange.values)
          AppFilterChip(
            label: r.label,
            selected: _range == r,
            onPressed: () {
              if (_range != r) setState(() => _range = r);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final double s = ResponsiveScale.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 44 * s, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Tidak ada set yang dipelajari pada rentang waktu ini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15 * s),
            ),
          ],
        ),
      ),
    );
  }
}