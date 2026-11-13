import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../repositories/flash_mind_repository.dart';
import '../widgets/study_session_layout.dart';

class StudySessionEndScreen extends StatelessWidget {
  const StudySessionEndScreen({
    super.key,
    required this.setId,
    required this.sessionId,
  });

  final String setId;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final repository = FlashMindRepository.instance;

    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final set = repository.getSetById(setId);
        final currentSession = repository.getStudySessionById(sessionId);

        if (currentSession == null) {
          return const Scaffold(
            backgroundColor: StudySessionStyle.background,
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
        final completed = repository.getCompletedStudySessionsForSet(setId);

        return StudySessionScaffold(
          greeting: 'Selamat',
          message:
              'Sesi belajar sudah selesai! Terima kasih karena telah belajar hari ini.',
          card: StudySessionSummaryCard(
            title: title,
            description: description,
            historyRows: [
              (
                'Durasi pengerjaan',
                Formatter.duration(currentSession.totalDuration),
              ),
              (
                'Tingkat kebenaran',
                Formatter.percent(currentSession.accuracy),
              ),
            ],
            completedSessions: completed,
            footer:
                '${currentSession.completedCardCount}/${currentSession.totalCardCount} kartu',
          ),
          button: StudySessionPrimaryButton(
            label: 'Kembali',
            onPressed: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }
}