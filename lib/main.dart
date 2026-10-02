import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/flashcard_set.dart';
import 'pages/berkas_page.dart';
import 'pages/detail_set_page.dart';
import 'pages/login_page.dart';
import 'pages/profil_page.dart';
import 'pages/statistic_page.dart';
import 'providers/auth_provider.dart';
import 'repositories/flash_mind_repository.dart';

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
          pageBuilder: (context, animation, secondaryAnimation) => targetPage,
          transitionsBuilder: (context, anim, secondaryAnimation, child) =>
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

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool sel = _selectedIndex == index;
    final Color color =
        sel ? const Color(0xFF192A3A) : Colors.grey.shade400;
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: sel ? FontWeight.bold : FontWeight.w600,
              ),
            ),
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
                child: Icon(
                  Icons.home_rounded,
                  color: _selectedIndex == 1
                      ? Colors.white
                      : Colors.grey.shade400,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Beranda',
              style: TextStyle(
                fontSize: 12,
                color: _selectedIndex == 1
                    ? const Color(0xFF192A3A)
                    : Colors.grey.shade400,
                fontWeight: _selectedIndex == 1
                    ? FontWeight.bold
                    : FontWeight.w600,
              ),
            ),
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

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int? _selectedBarIndex;
  final int _recSeed = DateTime.now().millisecondsSinceEpoch;

  static const Color _primary = Color(0xFF192A3A);
  static const Color _cardBg  = Color(0xFF2C3E50);
  static const Color _orange  = Color(0xFFE87A5D);
  static const Color _accent  = Color(0xFFF3C279);

  static String _greeting() {
    final int h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi,';
    if (h < 15) return 'Selamat siang,';
    if (h < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  static String _dayMonth() {
    const List<String> days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final DateTime now = DateTime.now();
    return '${days[now.weekday - 1].toUpperCase()}, '
        '${now.day} ${months[now.month - 1].toUpperCase()} ${now.year}';
  }

  static String _dayShort(DateTime d) {
    const List<String> days = [
      'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min',
    ];
    return days[d.weekday - 1];
  }

  static String _fmtDate(DateTime d) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  List<_DayData> _buildWeekData(FlashMindRepository repo) {
    final DateTime today = DateTime.now();
    return List.generate(7, (i) {
      final DateTime day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - i));
      final sessions    = repo.getSessionsOnDay(day);
      final int uniqueSets =
          sessions.map((s) => s.setId).toSet().length;
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
    final rng    = Random(_recSeed);

    for (final set in sets) {
      if (repo.getInProgressStudySessionForSet(set.id) != null) {
        result.add(_RecommendedSet(set: set, dueCount: set.cardCount));
      }
    }

    for (final set in sets) {
      if (result.any((r) => r.set.id == set.id)) continue;
      final completed = repo.getCompletedStudySessionsForSet(set.id);
      if (completed.isNotEmpty && completed.last.accuracy < 70) {
        result.add(_RecommendedSet(set: set, dueCount: set.cardCount));
      }
    }

    for (final set in sets) {
      if (result.any((r) => r.set.id == set.id)) continue;
      if (set.lastStudiedAt == null) {
        result.add(_RecommendedSet(set: set, dueCount: set.cardCount));
      }
    }

    final remaining = sets
        .where((s) => !result.any((r) => r.set.id == s.id))
        .toList()
      ..shuffle(rng);
    for (final set in remaining) {
      if (result.length >= 3) break;
      result.add(_RecommendedSet(set: set, dueCount: set.cardCount));
    }

    return result.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user       = context.watch<AuthProvider>().currentUser;
    final firstName  = user?.nama.split(' ').first ?? 'Pengguna';
    final initial    = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    final repo       = FlashMindRepository.instance;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final sets            = repo.sets;
        final weekData        = _buildWeekData(repo);
        final recommendations = _buildRecommendations(repo);
        final int maxCount    = weekData
            .map((d) => d.sessionCount)
            .reduce((a, b) => a > b ? a : b);
        final _DayData? selected =
            _selectedBarIndex != null ? weekData[_selectedBarIndex!] : null;

        final FlashcardSet? lastStudiedSet = sets.isEmpty
            ? null
            : sets.reduce((a, b) =>
                (a.lastStudiedAt ?? DateTime(1970))
                        .isAfter(b.lastStudiedAt ?? DateTime(1970))
                    ? a
                    : b);

        final int weekCards =
            weekData.fold<int>(0, (s, d) => s + d.cardCount);

        return SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              fontSize: 24,
                              color: _primary,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            '$firstName.',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              height: 1.05,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProfilePage(),
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFE8E8E8),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

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
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          lastStudiedSet.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${lastStudiedSet.cardCount} kartu sedang menunggumu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  DetailSetPage(setId: lastStudiedSet.id),
                            ),
                          ),
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

                Text(
                  'RITME BELAJAR',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
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
                        height: 1.2,
                      ),
                    ),
                    if (selected != null)
                      Text(
                        '${_fmtDate(selected.date)} · ${selected.uniqueSetCount} set',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),

                SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (i) {
                      final _DayData day = weekData[i];
                      final bool isToday = i == 6;
                      final bool isSel   = _selectedBarIndex == i;
                      final double fraction = maxCount == 0
                          ? 0.0
                          : day.sessionCount / maxCount;
                      final double barH =
                          (fraction * 110).clamp(12.0, 110.0);
                      final Color barColor = isSel
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
                                      : FontWeight.normal,
                                ),
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
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                const Text(
                  'Karena kamu melewatkan ini',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w400,
                    color: _primary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                if (recommendations.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: const Color(0xFFE8E4DB), width: 1),
                    ),
                    child: const Text(
                      'Belum ada rekomendasi.\n'
                      'Mulai pelajari set kartu untuk mendapatkan rekomendasi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey, height: 1.5),
                    ),
                  )
                else
                  ...recommendations.map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _RecCard(
                          rec: rec,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  DetailSetPage(setId: rec.set.id),
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
    required this.dueCount,
  });

  final FlashcardSet set;
  final int dueCount;
}

class _RecCard extends StatelessWidget {
  const _RecCard({required this.rec, required this.onTap});

  final _RecommendedSet rec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  rec.set.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF192A3A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${rec.dueCount} kartu',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          if (rec.set.description.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              rec.set.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12, height: 1.3),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE87A5D),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat Detail →',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
