import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

import 'study_session_continue_screen.dart';
import 'study_session_screen.dart';

import '../widgets/responsive_scale.dart';

class StudySessionStartScreen extends StatefulWidget {
  const StudySessionStartScreen({super.key, required this.setId});

  final String setId;

  @override
  State<StudySessionStartScreen> createState() => _StudySessionStartScreenState();
}

class _StudySessionStartScreenState extends State<StudySessionStartScreen> {
  static const Color _primaryColor    = Color(0xFF192A3A);
  static const Color _accentColor     = Color(0xFFF3C279);
  static const Color _headerColor     = Color(0xFFFFE5B4);
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

  bool _isStarting = false;

  static Duration _averageDuration(List<StudySession> sessions) {
    if (sessions.isEmpty) return Duration.zero;
    final int totalMicroseconds = sessions.fold<int>(
      0,
      (sum, session) => sum + session.totalDuration.inMicroseconds,
    );
    return Duration(microseconds: totalMicroseconds ~/ sessions.length);
  }

  static double _averageAccuracy(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0;
    final double total = sessions.fold<double>(
        0, (sum, session) => sum + session.accuracy);
    return total / sessions.length;
  }

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

  @override
  Widget build(BuildContext context) {
    final repository = FlashMindRepository.instance;

    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final set = repository.getSetById(widget.setId);

        if (set == null) {
          return const Scaffold(
            backgroundColor: _backgroundColor,
            body: Center(child: Text('Set tidak ditemukan.')),
          );
        }

        final completedSessions =
            repository.getCompletedStudySessionsForSet(set.id);

        return Scaffold(
          backgroundColor: _backgroundColor,
          appBar: _buildAppBar(context),
          body: _buildBody(context, set, completedSessions),
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
          fontSize: 24 * s,
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
    List<StudySession> completedSessions,
  ) {
    final averageDuration = _averageDuration(completedSessions);
    final averageAccuracy = _averageAccuracy(completedSessions);
    final highestAccuracy = _highestAccuracySession(completedSessions);
    final fastestSession  = _fastestSession(completedSessions);

    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 88),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 34),
              child: Column(
                children: [
                  _buildSummaryCard(
                    set: set,
                    averageDuration: completedSessions.isEmpty
                        ? '-'
                        : Formatter.duration(averageDuration),
                    averageAccuracy: completedSessions.isEmpty
                        ? '-'
                        : Formatter.percent(averageAccuracy),
                    lastStudied: Formatter.relativeTime(set.lastStudiedAt!),
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
                  ),
                  const SizedBox(height: 30),
                  _buildStartButton(context),
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
    required String averageDuration,
    required String averageAccuracy,
    required String lastStudied,
    required String highestAccuracy,
    required String highestAccuracyDuration,
    required String fastestDuration,
    required String fastestAccuracy,
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
            set.description.isEmpty ? 'Tidak ada deskripsi set.' : set.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 13 * s, color: Colors.grey, height: 1.25),
          ),
          const SizedBox(height: 25),
          Text('Riwayat Pembelajaran', style: _sectionStyle),
          const SizedBox(height: 10),
          _buildStatRow('Durasi rata-rata', averageDuration),
          const SizedBox(height: 10),
          _buildStatRow('Rata-rata jawaban benar', averageAccuracy),
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
            child: Text('${set.cardCount} kartu', style: _valueStyle),
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
              constraints:
                  BoxConstraints(maxWidth: constraints.maxWidth * 0.55),
              child: Text(value, textAlign: TextAlign.right, style: _valueStyle),
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
              child: Text(duration,
                  textAlign: TextAlign.right, style: _valueStyle),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _startSession(BuildContext context) async {
    if (_isStarting) return;
    setState(() => _isStarting = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final session = await FlashMindRepository.instance
          .startStudySession(widget.setId);

      if (!mounted) return;

      if (session == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Sesi belajar tidak dapat dimulai.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          ),
        );
        return;
      }

      navigator.pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => StudySessionContinueScreen(setId: widget.setId),
        ),
      );
      navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => StudySessionScreen(
              setId: widget.setId, sessionId: session.id),
        ),
      );
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Widget _buildStartButton(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return SizedBox(
      height: 40 * s,
      child: ElevatedButton(
        onPressed: _isStarting ? null : () => _startSession(context),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return _accentColor.withValues(alpha: 0.55);
            }
            return _accentColor;
          }),
          foregroundColor: const WidgetStatePropertyAll(_primaryColor),
          elevation: const WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 22 * s)),
          minimumSize: WidgetStatePropertyAll(Size(120 * s, 40 * s)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          textStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w700)),
        ),
        child: _isStarting
            ? SizedBox(
                width: 18 * s,
                height: 18 * s,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: _primaryColor),
              )
            : const Text('Mulai'),
      ),
    );
  }
}