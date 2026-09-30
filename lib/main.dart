import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/profil_page.dart';
import 'pages/berkas_page.dart';
import 'pages/statistic_page.dart';
import 'repositories/flash_mind_repository.dart';
import 'models/flashcard_set.dart';

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
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    await context.read<AuthProvider>().checkLoginStatus();
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
      final targetPage = isLoggedIn ? const MainPage() : const LoginPage();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => targetPage,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
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
            const Text('Flash Mind',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: Color(0xFF192A3A))),
            const SizedBox(height: 8),
            const Text('Small reviews. Lasting memory.',
                style: TextStyle(fontSize: 14, color: Colors.black54)),
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
  int _selectedIndex = 1;

  Widget _buildNavItem(IconData icon, String label, int index) {
    final sel   = _selectedIndex == index;
    final color = sel ? const Color(0xFF192A3A) : Colors.grey.shade400;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedIndex = index),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: sel ? FontWeight.bold : FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [BerkasPage(), _HomeView(), StatisticPage()],
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                onPressed: () => setState(() => _selectedIndex = 1),
                backgroundColor: _selectedIndex == 1
                    ? const Color(0xFF192A3A)
                    : Colors.white,
                shape: const CircleBorder(),
                elevation: 3,
                child: Icon(Icons.home_rounded,
                    color: _selectedIndex == 1
                        ? Colors.white
                        : Colors.grey.shade400,
                    size: 30),
              ),
            ),
            const SizedBox(height: 4),
            Text('Beranda',
                style: TextStyle(
                    fontSize: 12,
                    color: _selectedIndex == 1
                        ? const Color(0xFF192A3A)
                        : Colors.grey.shade400,
                    fontWeight: _selectedIndex == 1
                        ? FontWeight.bold
                        : FontWeight.w600)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        padding: const EdgeInsets.symmetric(horizontal: 36.0),
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.article_outlined, 'Berkas', 0),
            _buildNavItem(Icons.timer_outlined, 'Statistik', 2),
          ],
        ),
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
  int? _selectedBarIndex;

  static const Color _primary  = Color(0xFF192A3A);
  static const Color _cardBg   = Color(0xFF2C3E50);
  static const Color _orange   = Color(0xFFE87A5D);
  static const Color _accent   = Color(0xFFF3C279);

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi,';
    if (h < 15) return 'Selamat siang,';
    if (h < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  static String _dayMonth() {
    const days   = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu'];
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final now = DateTime.now();
    return '${days[now.weekday - 1].toUpperCase()}, ${now.day} ${months[now.month - 1].toUpperCase()} ${now.year}';
  }

  static String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${d.day} ${months[d.month - 1]}';
  }

  static String _dayShort(DateTime d) {
    const days = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
    return days[d.weekday - 1];
  }

  List<_DayData> _buildWeekData(FlashMindRepository repo) {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - i));
      final sessions = repo.getSessionsOnDay(day);
      final uniqueSets = sessions.map((s) => s.setId).toSet().length;
      return _DayData(
        date: day,
        sessionCount: sessions.length,
        cardCount: sessions.fold(0, (s, x) => s + x.completedCardCount),
        uniqueSetCount: uniqueSets,
      );
    });
  }

  List<_RecommendedSet> _buildRecommendations(FlashMindRepository repo) {
    final sets   = repo.sets;
    final result = <_RecommendedSet>[];
    final rng    = Random();

    for (final set in sets) {
      if (repo.getInProgressStudySessionForSet(set.id) != null) {
        result.add(_RecommendedSet(
          set: set, reason: 'Terakhir dipelajari 1 hari lalu',
          color: const Color(0xFF52B788), dueCount: set.cardCount));
        continue;
      }
      final completed = repo.getCompletedStudySessionsForSet(set.id);
      if (completed.isNotEmpty && completed.last.accuracy < 70) {
        result.add(_RecommendedSet(
          set: set, reason: 'Terakhir dipelajari 1 hari lalu',
          color: const Color(0xFFE87A5D), dueCount: set.cardCount));
        continue;
      }
      if (set.lastStudiedAt == null) {
        result.add(_RecommendedSet(
          set: set, reason: 'Belum pernah dipelajari',
          color: const Color(0xFF52B788), dueCount: set.cardCount));
        continue;
      }
    }

    final existingIds = result.map((r) => r.set.id).toSet();
    final remaining   = sets.where((s) => !existingIds.contains(s.id)).toList()
      ..shuffle(rng);
    for (final set in remaining.take(3 - result.length)) {
      final lastStudied = set.lastStudiedAt;
      final diff = lastStudied == null ? 0 : DateTime.now().difference(lastStudied).inDays;
      final reason = lastStudied == null
          ? 'Belum pernah dipelajari'
          : 'Terakhir dipelajari $diff hari lalu';
      result.add(_RecommendedSet(
        set: set, reason: reason,
        color: const Color(0xFF52B788), dueCount: set.cardCount));
    }

    return result.take(3).toList();
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
        final sets            = repo.sets;
        final weekData        = _buildWeekData(repo);
        final recommendations = _buildRecommendations(repo);
        final maxCount        = weekData
            .map((d) => d.sessionCount)
            .reduce((a, b) => a > b ? a : b);
        final selected = _selectedBarIndex != null
            ? weekData[_selectedBarIndex!]
            : null;

        // Set terakhir dipelajari
        final lastStudiedSet = sets.isEmpty
            ? null
            : sets.reduce((a, b) =>
                (a.lastStudiedAt ?? DateTime(1970))
                    .isAfter(b.lastStudiedAt ?? DateTime(1970))
                    ? a
                    : b);

        // Total kartu minggu ini
        final weekCards = weekData.fold<int>(0, (s, d) => s + d.cardCount);

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                                fontSize: 9,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _greeting(),
                            style: const TextStyle(
                                fontSize: 24,
                                color: _primary,
                                fontFamily: 'serif',
                                fontWeight: FontWeight.w400,
                                height: 1.2),
                          ),
                          Text(
                            '$firstName.',
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'serif',
                                height: 1.05,
                                color: _primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFE8E8E8),
                      child: Text(initial,
                          style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 17)),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Banner set terakhir
                if (lastStudiedSet != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ULASAN TERAKHIR',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          lastStudiedSet.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              height: 1.15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${lastStudiedSet.cardCount} kartu sedang menunggumu',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: _primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                          ),
                          child: const Text(
                            'Mulai belajar →',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Ritme belajar
                Text(
                  'RITME BELAJAR',
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Pelan tapi pasti.',
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w400,
                          color: _primary,
                          height: 1.2),
                    ),
                    if (selected != null)
                      Text(
                        '${selected.uniqueSetCount} set',
                        style: const TextStyle(
                            fontSize: 12,
                            color: _orange,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                const SizedBox(height: 22),

                // Bar chart
                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (i) {
                      final day       = weekData[i];
                      final isToday   = i == 6;
                      final isSel     = _selectedBarIndex == i;
                      final fraction  = maxCount == 0 ? 0.0 : day.sessionCount / maxCount;
                      final barH      = (fraction * 110).clamp(12.0, 110.0);
                      final barColor  = isSel
                          ? _orange
                          : (day.sessionCount > 0
                              ? _orange.withValues(alpha: 0.6)
                              : const Color(0xFFE5E5E5));

                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedBarIndex = isSel ? null : i;
                        }),
                        child: SizedBox(
                          width: 36,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                width: isSel ? 36 : 32,
                                height: barH,
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _dayShort(day.date),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: isToday
                                        ? _primary
                                        : Colors.grey.shade400,
                                    fontWeight: isToday || isSel
                                        ? FontWeight.w600
                                        : FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kamu belajar $weekCards kartu minggu ini',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.normal),
                    ),
                    Text(
                      '+18%',
                      style: TextStyle(
                          fontSize: 11,
                          color: _orange,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Rekomendasi
                const Text(
                  'Rekomendasi Set Kartu',
                  style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w400,
                      color: _primary,
                      height: 1.2),
                ),
                const SizedBox(height: 16),
                ...recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _RecCard(rec: rec),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _DayData {
  const _DayData({
    required this.date,
    required this.sessionCount,
    required this.cardCount,
    required this.uniqueSetCount,
  });
  final DateTime date;
  final int sessionCount;
  final int cardCount;
  final int uniqueSetCount;
}

class _RecommendedSet {
  const _RecommendedSet({
    required this.set,
    required this.reason,
    required this.color,
    required this.dueCount,
  });
  final FlashcardSet set;
  final String reason;
  final Color color;
  final int dueCount;
}

class _RecCard extends StatelessWidget {
  const _RecCard({required this.rec});
  final _RecommendedSet rec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rec.set.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF192A3A),
                        fontSize: 15)),
                const SizedBox(height: 3),
                Text(rec.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${rec.dueCount} kartu',
              style: TextStyle(
                  color: rec.color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
