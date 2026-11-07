import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';
import '../widgets/responsive_scale.dart';

class StudySessionEndPage extends StatelessWidget {
  const StudySessionEndPage({
    super.key,
    required this.setId,
    required this.sessionId,
  });

  static const Color _primaryColor    = Color(0xFF192A3A);
  static const Color _accentColor     = Color(0xFFF3C279);
  static const Color _headerColor     = Color(0xFFFFE5B4);
  static const Color _backgroundColor = Color(0xFFFBF9F6);

  static TextStyle _valueStyle(double s) => TextStyle(
    fontSize: 13 * s,
    color: _primaryColor,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static TextStyle _sectionStyle(double s) => TextStyle(
    fontSize: 15 * s,
    fontWeight: FontWeight.bold,
    fontFamily: 'serif',
    color: _primaryColor,
  );

  final String setId;
  final String sessionId;

  static String _formatDuration(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int hours        = totalSeconds ~/ 3600;
    final int minutes      = (totalSeconds % 3600) ~/ 60;
    final int seconds      = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatRecordDuration(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int hours        = totalSeconds ~/ 3600;
    final int minutes      = (totalSeconds % 3600) ~/ 60;
    final int seconds      = totalSeconds % 60;
    if (hours > 0) {
      return '$hours jam${minutes > 0 ? ' $minutes menit' : ''}';
    }
    if (minutes > 0) {
      return '$minutes menit${seconds > 0 ? ' $seconds detik' : ''}';
    }
    return '$seconds detik';
  }

  static String _formatAccuracy(double accuracy) {
    final num value = accuracy.clamp(0, 100);
    return '${value.toStringAsFixed(2)}%';
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
        final set            = repository.getSetById(setId);
        final currentSession = repository.getStudySessionById(sessionId);

        if (currentSession == null) {
          return const Scaffold(
            backgroundColor: _backgroundColor,
            body: Center(child: Text('Data sesi belajar tidak ditemukan.')),
          );
        }

        // Nama serta deskripsi set
        final String title =
            set?.title ?? currentSession.setTitle ?? 'Set yang dihapus';
        final String description = set == null
            ? 'Set ini sudah dihapus.'
            : (set.description.isEmpty
                ? 'Tidak ada deskripsi set.'
                : set.description);

        // Sesi selesai milik setId ini tetap tersedia walau set sudah dihapus.
        final completedSessions =
            repository.getCompletedStudySessionsForSet(setId);
        final highestAccuracy = _highestAccuracySession(completedSessions);
        final fastestSession  = _fastestSession(completedSessions);

        return Scaffold(
          backgroundColor: _backgroundColor,
          appBar: _buildAppBar(context),
          body: _buildBody(context, title, description, currentSession, highestAccuracy, fastestSession),
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
    String title,
    String description,
    StudySession currentSession,
    StudySession? highestAccuracy,
    StudySession? fastestSession,
  ) {
    final double s = ResponsiveScale.of(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 88),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 34),
              child: Column(
                children: [
                  _buildSummaryCard(
                    s: s,
                    title: title,
                    description: description,
                    duration: _formatDuration(currentSession.totalDuration),
                    accuracy: _formatAccuracy(currentSession.accuracy),
                    cardProgress:
                        '${currentSession.completedCardCount}/${currentSession.totalCardCount} kartu',
                    highestAccuracy: highestAccuracy == null
                        ? '-'
                        : _formatAccuracy(highestAccuracy.accuracy),
                    highestAccuracyDuration: highestAccuracy == null
                        ? '-'
                        : _formatRecordDuration(highestAccuracy.totalDuration),
                    fastestDuration: fastestSession == null
                        ? '-'
                        : _formatRecordDuration(fastestSession.totalDuration),
                    fastestAccuracy: fastestSession == null
                        ? '-'
                        : _formatAccuracy(fastestSession.accuracy),
                  ),
                  const SizedBox(height: 30),
                  _buildBackButton(context, s),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required double s,
    required String title,
    required String description,
    required String duration,
    required String accuracy,
    required String cardProgress,
    required String highestAccuracy,
    required String highestAccuracyDuration,
    required String fastestDuration,
    required String fastestAccuracy,
  }) {
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
            title,
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
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 13 * s, color: Colors.grey, height: 1.25),
          ),
          const SizedBox(height: 25),
          Text('Riwayat Pembelajaran', style: _sectionStyle(s)),
          const SizedBox(height: 10),
          _buildStatRow(s, 'Durasi pengerjaan', duration),
          const SizedBox(height: 10),
          _buildStatRow(s, 'Persentase jawaban benar', accuracy),
          const SizedBox(height: 40),
          Text('Rekor Belajar', style: _sectionStyle(s)),
          const SizedBox(height: 10),
          _buildRecordRow(
            s: s,
            label: 'Tingkat kebenaran tertinggi',
            accuracy: highestAccuracy,
            duration: highestAccuracyDuration,
          ),
          const SizedBox(height: 20),
          _buildRecordRow(
            s: s,
            label: 'Durasi pengerjaan tercepat',
            accuracy: fastestAccuracy,
            duration: fastestDuration,
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerRight,
            child: Text(cardProgress, style: _valueStyle(s)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(double s, String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: _valueStyle(s))),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: constraints.maxWidth * 0.55),
              child: Text(value,
                  textAlign: TextAlign.right, style: _valueStyle(s)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordRow({
    required double s,
    required String label,
    required String accuracy,
    required String duration,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _valueStyle(s)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(accuracy, textAlign: TextAlign.left, style: _valueStyle(s)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(duration,
                  textAlign: TextAlign.right, style: _valueStyle(s)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context, double s) {
    return SizedBox(
      height: 40 * s,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_accentColor),
          foregroundColor: const WidgetStatePropertyAll(_primaryColor),
          elevation: const WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 22 * s)),
          minimumSize: WidgetStatePropertyAll(Size(120 * s, 40 * s)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
          ),
          textStyle: WidgetStatePropertyAll(
              TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w700)),
        ),
        child: const Text('Kembali'),
      ),
    );
  }
}