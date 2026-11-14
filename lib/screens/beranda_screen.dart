import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_colors.dart';
import '../utils/formatter.dart';
import '../providers/auth_provider.dart';
import '../repositories/flash_mind_repository.dart';

import 'detail_set_screen.dart';
import 'study_history_screen.dart';
import 'profile_screen.dart';
import 'study_session_continue_screen.dart';
import 'study_session_start_screen.dart';
import '../services/review_recommendation.dart';
import '../widgets/app_button.dart';
import '../widgets/app_empty_card.dart';
import '../widgets/app_item_card.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_stat_box.dart';
import '../utils/responsive_scale.dart';
import '../widgets/study_history_card.dart';

// Layar Beranda

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key, required this.onViewAllReviews});

  final VoidCallback onViewAllReviews;

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  static String _greeting() {
    final int h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi,';
    if (h < 15) return 'Selamat siang,';
    if (h < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  static String _dayMonth() {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // Pembungkus banner agar dua kondisi banner tidak menulis dekorasi dua kali.
  Widget _bannerShell(double s, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 20 * s),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _bannerLabel(double s) {
    return Text(
      'Pelajari Sekarang',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.55),
        fontSize: AppFont.caption * s,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  // Banner rekomendasi belajar.
  // Prioritas:
  //  1. Sesi terhenti yang paling baru dihentikan
  //  2. Set "Perlu Diulas" paling urgen
  //  3. Tidak ada keduanya
  Widget _buildRecommendationBanner(
    BuildContext context,
    FlashMindRepository repo,
    List<dynamic> dueSets,
  ) {
    final double s = context.scale;
    final stopped = repo.inProgressSessions;
    final session = stopped.isEmpty ? null : stopped.first;
    final resumeSet = session == null ? null : repo.getSetById(session.setId);
    final bool isResume = session != null && resumeSet != null;

    final recSet = isResume
        ? resumeSet
        : (dueSets.isEmpty ? null : dueSets.first);

    // Kondisi kosong: tidak ada sesi terhenti dan tidak ada set diulas
    if (recSet == null) {
      final bool noSets = repo.sets.isEmpty;
      return _bannerShell(s, [
        _bannerLabel(s),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline,
                color: AppColors.accent, size: 32 * s),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    noSets
                        ? 'Belum ada set flashcard.'
                        : 'Tidak ada set yang perlu diulas.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFont.title * s,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    noSets
                        ? 'Buat set di halaman Berkas untuk mulai belajar.'
                        : 'Set akan muncul di sini ketika sudah waktunya untuk diulas.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: AppFont.small * s,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]);
    }

    // Ada rekomendasi (lanjut sesi terhenti atau set perlu diulas)
    final int otherStopped = isResume ? stopped.length - 1 : 0;

    return _bannerShell(s, [
      _bannerLabel(s),
      const SizedBox(height: 10),
      Text(
        recSet.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24 * s,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          height: 1.2,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        isResume
            ? '${session.completedCardCount}/${session.totalCardCount} Kartu'
            : '${recSet.cardCount} Kartu',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.65),
          fontSize: AppFont.small * s,
        ),
      ),
      if (otherStopped > 0) ...[
        const SizedBox(height: 4),
        Text(
          'Masih ada $otherStopped sesi terhenti lainnya.',
          style: TextStyle(
            color: AppColors.accent.withValues(alpha: 0.9),
            fontSize: AppFont.caption * s,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      const SizedBox(height: 16),
      AppButton(
        label: isResume ? 'Lanjut Belajar' : 'Mulai Belajar',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => isResume
                ? StudySessionContinueScreen(setId: recSet.id)
                : StudySessionStartScreen(setId: recSet.id),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    final user = context.watch<AuthProvider>().currentUser;
    final firstName = user?.nama.split(' ').first ?? 'Pengguna';
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    final repo = FlashMindRepository.instance;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final streak = repo.currentStreak;
        final weekSets = repo.weeklyUniqueSets;
        final weekCards = repo.weeklyCardCount;
        final weekDur = repo.weeklyDuration;
        final weekAcc = repo.weeklyAccuracy;
        final dueSets = ReviewRecommendation.dueSets(repo);
        final reviewSets = dueSets.take(3).toList();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: AppContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dayMonth(),
                              style: TextStyle(
                                fontSize: AppFont.small * s,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _greeting(),
                              style: TextStyle(
                                fontSize: 26 * s,
                                color: AppColors.primary,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w400,
                                height: 1.15,
                              ),
                            ),
                            Text(
                              '$firstName.',
                              style: TextStyle(
                                fontSize: AppFont.page * s,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'serif',
                                height: 1.05,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfileScreen(),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22 * s,
                          backgroundColor: const Color(0xFFE8E8E8),
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: AppFont.button * s,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Banner Pelajari Sekarang
                  _buildRecommendationBanner(context, repo, dueSets),
                  const SizedBox(height: 25),

                  // Statistik Mingguan
                  AppSectionHeader(
                    title: 'Statistik Mingguan',
                    infoText:
                        streak > 0 ? '$streak hari beruntun' : 'Mulai hari ini!',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // [DIUBAH] memakai AppStatGrid bersama (teks lebih besar)
                        AppStatGrid(
                          items: [
                            ('Jumlah set', '$weekSets'),
                            ('Jumlah kartu', '$weekCards'),
                            ('Durasi belajar', Formatter.duration(weekDur)),
                            ('Tingkat kebenaran', Formatter.percent(weekAcc)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppDetailLink(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const StudyHistoryScreen(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Ulas Kembali
                  AppSectionHeader(
                    title: 'Ulas Kembali',
                    actionLabel: dueSets.isNotEmpty ? 'Lihat semua →' : null,
                    onAction: widget.onViewAllReviews,
                  ),
                  const SizedBox(height: 12),
                  if (reviewSets.isEmpty)
                    const AppEmptyCard(
                      icon: Icons.check_circle_outline,
                      title: 'Tidak ada set yang perlu diulas hari ini.',
                      subtitle:
                          'Set akan muncul di sini saat sudah waktunya diulas.',
                    )
                  else
                    ...reviewSets.map((set) {
                      final latest =
                          repo.getLatestCompletedSessionForSet(set.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StudyHistoryCard(
                          title: set.title,
                          cardCount: set.cardCount,
                          lastStudiedLabel: latest == null
                              ? 'Belum pernah'
                              : Formatter.relativeTime(
                                  latest.finishedAt ?? latest.startedAt),
                          accuracy: repo.getAverageAccuracyForSet(set.id),
                          onViewDetail: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DetailSetScreen(setId: set.id),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}