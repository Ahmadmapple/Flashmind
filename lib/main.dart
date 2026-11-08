import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/flashcard_set.dart';
import 'pages/all_review_sets_page.dart';
import 'pages/all_study_history_page.dart';
import 'pages/berkas_page.dart';
import 'pages/detail_set_page.dart';
import 'pages/login_page.dart';
import 'pages/profil_page.dart';
import 'pages/statistic_page.dart';
import 'pages/study_session_continue_page.dart';
import 'pages/study_session_start_page.dart';
import 'providers/auth_provider.dart';
import 'repositories/flash_mind_repository.dart';
import 'widgets/app_bottom_nav.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const FlashMindApp(),
    ),
  );
}

class FlashMindApp extends StatelessWidget {
  const FlashMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flash Mind',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFBF9F6),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF192A3A)),
        fontFamily: 'sans-serif',
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Splash
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await context.read<AuthProvider>().checkLoginStatus();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) =>
            isLoggedIn ? const MainPage() : const LoginPage(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF192A3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Color(0xFFF3C279), size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Flash Mind',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'serif',
                color: Color(0xFF192A3A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Small reviews. Lasting memory.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MainPage
// ─────────────────────────────────────────────────────────────────────────────

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  AppNavTab _selectedTab = AppNavTab.beranda;

  void _selectTab(AppNavTab tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _selectedTab.index,
        children: const [BerkasPage(), _HomeView(), StatisticPage()],
      ),
      floatingActionButton: AppHomeFab(
        isActive: _selectedTab == AppNavTab.beranda,
        onPressed: () => _selectTab(AppNavTab.beranda),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        selectedTab: _selectedTab,
        onBerkasTap: () => _selectTab(AppNavTab.berkas),
        onStatistikTap: () => _selectTab(AppNavTab.statistik),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HomeView
// ─────────────────────────────────────────────────────────────────────────────

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  static const Color _primary = Color(0xFF192A3A);
  static const Color _cardBg  = Color(0xFF192A3A);
  static const Color _accent  = Color(0xFFF3C279);
  static const Color _orange  = Color(0xFFE87A5D);

  static String _greeting() {
    final int h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi,';
    if (h < 15) return 'Selamat siang,';
    if (h < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  static String _dayMonth() {
    const days   = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  static String _fmtDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String _fmtRelative(DateTime? dt) {
    if (dt == null) return 'Baru saja';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final user      = context.watch<AuthProvider>().currentUser;
    final firstName = user?.nama.split(' ').first ?? 'Pengguna';
    final initial   = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    final repo      = FlashMindRepository.instance;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final recSet     = repo.recommendedSet;
        final inProg     = recSet != null
            ? repo.getInProgressStudySessionForSet(recSet.id)
            : null;
        final isResume   = inProg != null;

        final streak     = repo.currentStreak;
        final weekSets   = repo.weeklyUniqueSets;
        final weekCards  = repo.weeklyCardCount;
        final weekDur    = repo.weeklyDuration;
        final weekAcc    = repo.weeklyAccuracy;
        final reviewSets = repo.reviewSets(limit: 3);

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
                            builder: (_) => const ProfilePage()),
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
                                    builder: (_) => StudySessionContinuePage(
                                        setId: recSet.id),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => StudySessionStartPage(
                                        setId: recSet.id),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: _primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(
                              isResume ? 'Lanjut Belajar' : 'Mulai Belajar',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
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
                        color: const Color(0xFFE8E4DB), width: 1.5),
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
                          _StatBox(label: 'Jumlah Set', value: '$weekSets'),
                          _StatBox(
                              label: 'Jumlah Kartu', value: '$weekCards'),
                          _StatBox(
                              label: 'Durasi Belajar',
                              value: _fmtDuration(weekDur)),
                          _StatBox(
                              label: 'Akurasi',
                              value: '${weekAcc.toStringAsFixed(0)}%'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (_) =>
                                    const AllStudyHistoryPage()),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lihat Detail →',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
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
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const AllReviewSetsPage()),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (reviewSets.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFE8E4DB), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 32, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text(
                          'Belum ada set untuk diulas.\nTambah set kartu dan mulai belajar!',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ...reviewSets.map((set) {
                    final sessions =
                        repo.getCompletedStudySessionsForSet(set.id);
                    final lastAcc = sessions.isEmpty
                        ? null
                        : sessions.last.accuracy;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReviewCard(
                        set: set,
                        lastAcc: lastAcc,
                        lastStudied: _fmtRelative(set.lastStudiedAt),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                DetailSetPage(setId: set.id),
                          ),
                        ),
                      ),
                    );
                  }),
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.set,
    required this.lastAcc,
    required this.lastStudied,
    required this.onTap,
  });

  final FlashcardSet set;
  final double? lastAcc;
  final String lastStudied;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF192A3A);
  static const Color _orange  = Color(0xFFE87A5D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  set.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${set.cardCount} kartu',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Terakhir dipelajari: $lastStudied',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          if (lastAcc != null)
            Text(
              'Tingkat kebenaran: ${lastAcc!.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                color: lastAcc! < 70 ? _orange : const Color(0xFF2F776F),
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: _orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat Detail →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
