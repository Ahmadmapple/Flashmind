import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

import 'study_session_screen.dart';
import 'study_session_start_screen.dart';

import '../widgets/responsive_scale.dart';

/// Layar informasi untuk sesi belajar yang masih berstatus inProgress karena sesi belajar sempat dihentikan.
class StudySessionContinueScreen extends StatefulWidget {
  const StudySessionContinueScreen({super.key, required this.setId});

  final String setId;

  @override
  State<StudySessionContinueScreen> createState() =>
      _StudySessionContinueScreenState();
}

class _StudySessionContinueScreenState extends State<StudySessionContinueScreen> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);
  static const Color _headerColor = Color(0xFFFFE5B4);
  static const Color _backgroundColor = Color(0xFFFBF9F6);

  TextStyle get _valueStyle => TextStyle(
    fontSize: 13 * ResponsiveScale.of(context),
    color: _primaryColor,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  TextStyle get _sectionStyle => TextStyle(
    fontSize: 15 * ResponsiveScale.of(context),
    fontWeight: FontWeight.bold,
    fontFamily: 'serif',
    color: _primaryColor,
  );

  final FlashMindRepository _repository = FlashMindRepository.instance;

  bool _isReplacing = false;

  static StudySession? _highestAccuracySession(List<StudySession> sessions) {
    if (sessions.isEmpty) return null;

    return sessions.reduce(
      (current, next) => next.accuracy > current.accuracy ? next : current,
    );
  }

  static StudySession? _fastestSession(List<StudySession> sessions) {
    if (sessions.isEmpty) return null;

    return sessions.reduce(
      (current, next) =>
          next.totalDuration < current.totalDuration ? next : current,
    );
  }

  static Duration _currentSessionDuration(StudySession session) {
    return session.totalDuration + session.currentCardElapsedDuration;
  }

  void _scheduleReplaceWithStart() {
    if (_isReplacing) return;
    _isReplacing = true;

    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    final setId = widget.setId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || route == null || !route.isActive) return;

      navigator.replace<void>(
        oldRoute: route,
        newRoute: MaterialPageRoute<void>(
          builder: (_) => StudySessionStartScreen(setId: setId),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _repository,
      builder: (context, _) {
        final set = _repository.getSetById(widget.setId);
        final session = _repository.getInProgressStudySessionForSet(
          widget.setId,
        );

        if (set == null || session == null) {
          if (set != null) _scheduleReplaceWithStart();
          return const Scaffold(backgroundColor: _backgroundColor);
        }

        final completedSessions = _repository.getCompletedStudySessionsForSet(
          set.id,
        );
        final highestAccuracy = _highestAccuracySession(completedSessions);
        final fastestSession = _fastestSession(completedSessions);

        return Scaffold(
          backgroundColor: _backgroundColor,
          appBar: _buildAppBar(context),
          body: _buildBody(
            context,
            set,
            session,
            highestAccuracy,
            fastestSession,
          ),
          floatingActionButton: null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return AppBar(
      backgroundColor: _headerColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, size: 28 * s),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: Text(
        'Sesi Belajar',
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

  Widget _buildBody(
    BuildContext context,
    FlashcardSet set,
    StudySession session,
    StudySession? highestAccuracy,
    StudySession? fastestSession,
  ) {
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 88),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 34,
              ),
              child: Column(
                children: [
                  _buildSummaryCard(
                    set: set,
                    duration: Formatter.duration(_currentSessionDuration(session)),
                    accuracy: Formatter.percent(session.accuracy),
                    lastStudied: Formatter.relativeTime(session.lastPausedAt!),
                    highestAccuracy: highestAccuracy == null
                        ? '-'
                        : Formatter.percent(highestAccuracy.accuracy),
                    highestAccuracyDuration: highestAccuracy == null
                        ? '-'
                        : Formatter.duration(highestAccuracy.totalDuration),
                    fastestDuration: fastestSession == null
                        ? '-'
                        : Formatter.duration(fastestSession.totalDuration),
                    fastestAccuracy: fastestSession == null
                        ? '-'
                        : Formatter.percent(fastestSession.accuracy),
                    cardProgress:
                        '${session.completedCardCount}/${session.totalCardCount} kartu',
                  ),
                  const SizedBox(height: 30),
                  _buildContinueButton(context, session),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required FlashcardSet set,
    required String duration,
    required String accuracy,
    required String lastStudied,
    required String highestAccuracy,
    required String highestAccuracyDuration,
    required String fastestDuration,
    required String fastestAccuracy,
    required String cardProgress,
  }) {
    final double s = ResponsiveScale.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB8B5AF), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            set.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 20 * s,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            set.description.isEmpty
                ? 'Tidak ada deskripsi set.'
                : set.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 13 * s,
              color: Colors.grey,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 25),
          Text('Riwayat Pembelajaran', style: _sectionStyle),
          const SizedBox(height: 10),
          _buildStatRow('Durasi pengerjaan', duration),
          const SizedBox(height: 10),
          _buildStatRow('Persentase jawaban benar', accuracy),
          const SizedBox(height: 10),
          _buildStatRow('Waktu terakhir dipelajari', lastStudied),
          const SizedBox(height: 30),
          Text('Rekor Belajar', style: _sectionStyle),
          const SizedBox(height: 10),
          _buildRecordRow(
            label: 'Tingkat kebenaran tertinggi',
            accuracy: highestAccuracy,
            duration: highestAccuracyDuration,
          ),
          const SizedBox(height: 20),
          _buildRecordRow(
            label: 'Durasi pengerjaan tercepat',
            accuracy: fastestAccuracy,
            duration: fastestDuration,
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerRight,
            child: Text(cardProgress, style: _valueStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: _valueStyle)),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.55,
              ),
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: _valueStyle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordRow({
    required String label,
    required String accuracy,
    required String duration,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _valueStyle),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(accuracy, textAlign: TextAlign.left, style: _valueStyle),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                duration,
                textAlign: TextAlign.right,
                style: _valueStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context, StudySession session) {
    final double s = ResponsiveScale.of(context);
    return SizedBox(
      height: 40 * s,
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) =>
                  StudySessionScreen(setId: widget.setId, sessionId: session.id),
            ),
          );
        },
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_accentColor),
          foregroundColor: const WidgetStatePropertyAll(_primaryColor),
          elevation: const WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24 * s),
          ),
          minimumSize: WidgetStatePropertyAll(Size(120 * s, 40 * s)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w700),
          ),
        ),
        child: const Text('Lanjut'),
      ),
    );
  }
}