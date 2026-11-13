import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

import 'study_session_screen.dart';

import '../widgets/study_session_layout.dart';

class StudySessionStartScreen extends StatefulWidget {
  const StudySessionStartScreen({super.key, required this.setId});

  final String setId;

  @override
  State<StudySessionStartScreen> createState() =>
      _StudySessionStartScreenState();
}

class _StudySessionStartScreenState extends State<StudySessionStartScreen> {
  bool _isStarting = false;

  static Duration _averageDuration(List<StudySession> sessions) {
    if (sessions.isEmpty) return Duration.zero;
    final int total = sessions.fold<int>(
      0,
      (sum, s) => sum + s.totalDuration.inMicroseconds,
    );
    return Duration(microseconds: total ~/ sessions.length);
  }

  static double _averageAccuracy(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0;
    return sessions.fold<double>(0, (sum, s) => sum + s.accuracy) /
        sessions.length;
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
            backgroundColor: StudySessionStyle.background,
            body: Center(child: Text('Set tidak ditemukan.')),
          );
        }

        final completed = repository.getCompletedStudySessionsForSet(set.id);
        final bool hasHistory = completed.isNotEmpty;

        return StudySessionScaffold(
          greeting: 'Halo',
          message:
              'Silakan tekan tombol Mulai untuk melaksanakan sesi belajar.',
          card: StudySessionSummaryCard(
            title: set.title,
            description: set.description.isEmpty
                ? 'Tidak ada deskripsi set.'
                : set.description,
            historyRows: [
              (
                'Durasi pengerjaan',
                hasHistory ? Formatter.duration(_averageDuration(completed)) : '-',
              ),
              (
                'Tingkat kebenaran',
                hasHistory ? Formatter.percent(_averageAccuracy(completed)) : '-',
              ),
              (
                'Waktu terakhir dipelajari',
                set.lastStudiedAt == null
                    ? '-'
                    : Formatter.relativeTime(set.lastStudiedAt!),
              ),
            ],
            completedSessions: completed,
            footer: '${set.cardCount} kartu',
          ),
          button: StudySessionPrimaryButton(
            label: 'Mulai',
            isLoading: _isStarting,
            onPressed: _startSession,
          ),
        );
      },
    );
  }

  Future<void> _startSession() async {
    if (_isStarting) return;
    setState(() => _isStarting = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final session =
          await FlashMindRepository.instance.startStudySession(widget.setId);

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

      // PERBAIKAN ALUR: layar awal diganti langsung oleh layar pelaksanaan.
      // Bila sesi dihentikan, pengguna kembali ke Detail Set (yang kini
      // menampilkan "Lanjutkan Sesi Belajar").
      navigator.pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) =>
              StudySessionScreen(setId: widget.setId, sessionId: session.id),
        ),
      );
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }
}