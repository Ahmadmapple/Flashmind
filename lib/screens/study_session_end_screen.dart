import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../repositories/flash_mind_repository.dart';
import '../widgets/study_session_layout.dart';
import 'study_session_start_screen.dart';

class StudySessionEndScreen extends StatelessWidget {
  const StudySessionEndScreen({
    super.key,
    required this.setId,
    required this.sessionId,
    this.returnToStart = false,
  });

  final String setId;
  final String sessionId;

  // Jika true, kembali ke layar sesi belajar awal (sesi selesai)
  // Jika false, kembali ke layar sebelumnya untuk Riwayat Belajar
  final bool returnToStart;

  void _goBack(BuildContext context, {required bool setExists}) {
    final navigator = Navigator.of(context);
    if (returnToStart && setExists) {
      navigator.pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => StudySessionStartScreen(setId: setId),
        ),
      );
    } else {
      navigator.pop();
    }
  }

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

        final bool setExists = set != null;

        // [BARU] PopScope agar tombol back sistem mengikuti perilaku Kembali.
        return PopScope<void>(
          canPop: !(returnToStart && setExists),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _goBack(context, setExists: setExists);
          },
          child: StudySessionScaffold(
            greeting: 'Selamat',
            message:
                'Sesi belajar sudah selesai! Terima kasih karena telah belajar hari ini.',
            onBack: () => _goBack(context, setExists: setExists),
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
              onPressed: () => _goBack(context, setExists: setExists),
            ),
          ),
        );
      },
    );
  }
}