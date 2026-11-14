import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

import '../widgets/app_bottom_nav.dart';
import '../widgets/history_range_filter.dart';
import '../widgets/responsive_scale.dart';
import '../widgets/study_history_card.dart';
import '../widgets/app_empty_card.dart';

import 'study_session_end_screen.dart';


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
  HistoryRange _range = HistoryRange.week;

  List<_HistoryEntry> _buildEntries() {
    final sessions = _range.filter(_repository.allCompletedSessions);

    final List<_HistoryEntry> entries = [
      for (final session in sessions)
        _HistoryEntry(
          session,
          _repository.getSetById(session.setId),
          session.finishedAt ?? session.startedAt,
        ),
    ];
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
                  child: HistoryRangeFilter(
                    selected: _range,
                    onChanged: (r) => setState(() => _range = r),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: entries.isEmpty
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: AppEmptyCard(
                              icon: Icons.history_rounded,
                              title: _range.emptyTitle,
                              subtitle:
                                  'Selesaikan sesi belajar untuk melihat riwayatnya di sini.',
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          itemCount: entries.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, i) {
                            final e = entries[i];
                            return StudyHistoryCard(
                              title: e.title,
                              cardCount: e.cardCount,
                              timeCaption: 'Waktu diselesaikan',
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
}