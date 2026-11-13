import 'package:flutter/material.dart';

import '../utils/formatter.dart';
import '../models/study_session.dart';
import '../repositories/flash_mind_repository.dart';

import 'study_session_screen.dart';
import 'study_session_start_screen.dart';

import '../widgets/study_session_layout.dart';

// Layar informasi untuk sesi belajar yang masih berstatus inProgress karena sesi belajar sempat dihentikan.
class StudySessionContinueScreen extends StatefulWidget {
  const StudySessionContinueScreen({super.key, required this.setId});

  final String setId;

  @override
  State<StudySessionContinueScreen> createState() =>
      _StudySessionContinueScreenState();
}

class _StudySessionContinueScreenState
    extends State<StudySessionContinueScreen> {
  final FlashMindRepository _repository = FlashMindRepository.instance;

  bool _isReplacing = false;

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

  void _continue(StudySession session) {
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            StudySessionScreen(setId: widget.setId, sessionId: session.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _repository,
      builder: (context, _) {
        final set = _repository.getSetById(widget.setId);
        final session =
            _repository.getInProgressStudySessionForSet(widget.setId);

        if (set == null || session == null) {
          if (set != null) _scheduleReplaceWithStart();
          return const Scaffold(backgroundColor: StudySessionStyle.background);
        }

        final completed = _repository.getCompletedStudySessionsForSet(set.id);

        return StudySessionScaffold(
          greeting: 'Halo',
          message:
              'Silakan tekan tombol Lanjut untuk melanjutkan sesi belajar yang terhenti.',
          card: StudySessionSummaryCard(
            title: set.title,
            description: set.description.isEmpty
                ? 'Tidak ada deskripsi set.'
                : set.description,
            historyRows: [
              (
                'Durasi pengerjaan',
                Formatter.duration(_currentSessionDuration(session)),
              ),
              (
                'Waktu terakhir dipelajari',
                session.lastPausedAt == null
                    ? '-'
                    : Formatter.relativeTime(session.lastPausedAt!),
              ),
            ],
            completedSessions: completed,
            footer:
                '${session.completedCardCount}/${session.totalCardCount} kartu',
          ),
          button: StudySessionPrimaryButton(
            label: 'Lanjut',
            onPressed: () => _continue(session),
          ),
        );
      },
    );
  }
}