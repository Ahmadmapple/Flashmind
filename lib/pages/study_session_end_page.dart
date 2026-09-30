import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

/// Layar ringkasan setelah seluruh kartu dalam satu sesi selesai dinilai.
class StudySessionEndPage extends StatelessWidget {
  const StudySessionEndPage({
    super.key,
    required this.setId,
    required this.sessionId,
  });

  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);
  static const Color _headerColor = Color(0xFFFFE5B4);
  static const Color _backgroundColor = Color(0xFFFBF9F6);

  static const TextStyle _valueStyle = TextStyle(
    fontSize: 12,
    color: _primaryColor,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  final String setId;
  final String sessionId;

  static String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatRecordDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours jam${minutes > 0 ? ' $minutes menit' : ''}';
    }
    if (minutes > 0) {
      return '$minutes menit${seconds > 0 ? ' $seconds detik' : ''}';
    }
    return '$seconds detik';
  }

  static String _formatAccuracy(double accuracy) {
    final value = accuracy.clamp(0, 100);
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
        final set = repository.getSetById(setId);
        final currentSession = repository.getStudySessionById(sessionId);

        if (set == null || currentSession == null) {
          return const Scaffold(
            backgroundColor: _backgroundColor,
            body: Center(child: Text('Data sesi belajar tidak ditemukan.')),
          );
        }

        final completedSessions = repository.getCompletedStudySessionsForSet(
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
            currentSession,
            highestAccuracy,
            fastestSession,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _headerColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, size: 28),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: const Text(
        'Sesi Belajar',
        style: TextStyle(
          fontSize: 25,
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
    StudySession currentSession,
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
                  _buildBackButton(context),
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
    required String cardProgress,
    required String highestAccuracy,
    required String highestAccuracyDuration,
    required String fastestDuration,
    required String fastestAccuracy,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
            style: const TextStyle(
              fontSize: 20,
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
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Riwayat Pembelajaran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          _buildStatRow('Durasi pengerjaan', duration),
          const SizedBox(height: 10),
          _buildStatRow('Persentase jawaban benar', accuracy),
          const SizedBox(height: 40),
          const Text(
            'Rekor Belajar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: _primaryColor,
            ),
          ),
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

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_accentColor),
          foregroundColor: const WidgetStatePropertyAll(_primaryColor),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(90, 32)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        child: const Text('Kembali'),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: const Icon(Icons.home_rounded, size: 30),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Beranda',
            style: TextStyle(
              fontSize: 9,
              color: _primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 2,
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomNavItem(
            icon: Icons.article_outlined,
            label: 'Berkas',
            onTap: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          const SizedBox(width: 72),
          _buildBottomNavItem(
            icon: Icons.timer_outlined,
            label: 'Statistik',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final color = label == 'Berkas' ? _primaryColor : Colors.grey.shade400;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}