import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/formatter.dart';
import '../providers/auth_provider.dart';
import '../repositories/flash_mind_repository.dart';

import 'detail_set_screen.dart';
import 'study_history_screen.dart';
import 'profile_screen.dart';
import 'study_session_continue_screen.dart';
import 'study_session_start_screen.dart';
import '../services/review_recommendation.dart';
import '../widgets/study_history_card.dart';

// Layar Beranda

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key, required this.onViewAllReviews});

  final VoidCallback onViewAllReviews;

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  static const Color _primary = Color(0xFF192A3A);
  static const Color _cardBg = Color(0xFF192A3A);
  static const Color _accent = Color(0xFFF3C279);
  static const Color _orange = Color(0xFFE87A5D);

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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final firstName = user?.nama.split(' ').first ?? 'Pengguna';
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    final repo = FlashMindRepository.instance;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final recSet = repo.recommendedSet;
        final inProg = recSet != null
            ? repo.getInProgressStudySessionForSet(recSet.id)
            : null;
        final isResume = inProg != null;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ────────────────────────────────────────────────
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
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              fontSize: 26,
                              color: _primary,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.w400,
                              height: 1.15,
                            ),
                          ),
                          Text(
                            '$firstName.',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              height: 1.05,
                              color: _primary,
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
                        radius: 22,
                        backgroundColor: const Color(0xFFE8E8E8),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Banner Pelajar Sekarang ───────────────────────────────
                if (recSet != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pelajari Sekarang',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          recSet.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isResume
                              ? '${inProg.nextCardIndex}/${recSet.cardCount} Kartu'
                              : '${recSet.cardCount} Kartu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              if (isResume) {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => StudySessionContinueScreen(
                                      setId: recSet.id,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => StudySessionStartScreen(
                                      setId: recSet.id,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: _primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              isResume ? 'Lanjut Belajar' : 'Mulai Belajar',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Statistik Mingguan ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Statistik mingguan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: _primary,
                      ),
                    ),
                    Text(
                      streak > 0 ? '$streak hari beruntun' : 'Mulai streak!',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE8E4DB),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.2,
                        children: [
                          _StatBox(label: 'Jumlah set', value: '$weekSets'),
                          _StatBox(label: 'Jumlah kartu', value: '$weekCards'),
                          _StatBox(label: 'Durasi belajar', value: Formatter.duration(weekDur)),
                          _StatBox(label: 'Tingkat kebenaran', value: Formatter.percent(weekAcc)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const StudyHistoryScreen(),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _orange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lihat Detail →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Ulas Kembali ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Ulas Kembali',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: _primary,
                      ),
                    ),
                    if (dueSets.isNotEmpty)
                      TextButton(
                        onPressed: widget.onViewAllReviews,
                        style: TextButton.styleFrom(
                          foregroundColor: _orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Lihat semua',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (reviewSets.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE8E4DB),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tidak ada set yang perlu diulas hari ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Set akan muncul di sini saat sudah waktunya diulas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ...reviewSets.map((set) {
                    final latest = repo.getLatestCompletedSessionForSet(set.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: StudyHistoryCard(
                        title: set.title,
                        cardCount: set.cardCount,
                        lastStudiedLabel: latest == null
                            ? 'Belum pernah'
                            : Formatter.relativeTime(
                                latest.finishedAt ?? latest.startedAt),
                        accuracy: latest?.accuracy,
                        onViewDetail: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DetailSetScreen(setId: set.id),
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3C279),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF192A3A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF192A3A),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}