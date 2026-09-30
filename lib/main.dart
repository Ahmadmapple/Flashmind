import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/profil_page.dart';
import 'pages/berkas_page.dart';
import 'pages/statistic_page.dart';

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
    // Memeriksa status login saat splash screen muncul
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    // 1. Jalankan proses pengecekan ke memori lokal
    await context.read<AuthProvider>().checkLoginStatus();

    // 2. Tambahkan sedikit jeda agar animasi splash screen Caesar tetap terlihat (simulasi)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // 3. Tentukan halaman tujuan berdasarkan status login
      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
      final targetPage = isLoggedIn ? const MainPage() : const LoginPage();

      // 4. Lakukan navigasi dengan animasi transisi Caesar
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
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
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFF3C279),
                size: 40,
              ),
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
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFF192A3A) : Colors.grey.shade400;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
      body: _selectedIndex == 0
          ? const BerkasPage()
          : _selectedIndex == 1
          ? const _HomeView()
          : _selectedIndex == 2
          ? const StatisticPage()
          : const Center(
        child: Text(
          'Halaman Tidak Ditemukan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
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

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    // 1. Mengambil data user yang sedang aktif dari AuthProvider
    final user = context.watch<AuthProvider>().currentUser;

    // 2. Mengambil kata pertama dari nama untuk sapaan
    final namaDepan = user?.nama.split(' ').first ?? 'Pengguna';
    final inisial = namaDepan.isNotEmpty ? namaDepan[0].toUpperCase() : 'U';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RABU, 30 SEP 2026',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Teks sapaan dinamis
                    Text(
                      'Selamat pagi,\n$namaDepan.',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        height: 1.1,
                        color: Color(0xFF192A3A),
                      ),
                    ),
                  ],
                ),
                // Tombol Profil Dinamis
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE5E5E5),
                    child: Text(
                      inisial,
                      style: const TextStyle(
                        color: Color(0xFF192A3A),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF192A3A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ULASAN BERIKUTNYA',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cell Biology',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '8 kartu sedang menunggumu',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3C279),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Mulai sesi 5 menit →',
                      style: TextStyle(
                        color: Color(0xFF192A3A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'RITME BELAJAR',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'Tetap semangat.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: Color(0xFF192A3A),
                  ),
                ),
                Text(
                  'streak 12 hari',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE87A5D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE8E4DB), width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildChartBar(40, const Color(0xFFEFEFEF)),
                      _buildChartBar(50, const Color(0xFFEFEFEF)),
                      _buildChartBar(30, const Color(0xFFEFEFEF)),
                      _buildChartBar(60, const Color(0xFFEFEFEF)),
                      _buildChartBar(90, const Color(0xFFE87A5D)),
                      _buildChartBar(45, const Color(0xFFEFEFEF)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Kamu mempelajari 45 kartu minggu ini',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '+18%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE87A5D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  'Kartu yang terlewat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: Color(0xFF192A3A),
                  ),
                ),
                Text(
                  'Lihat semua',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE87A5D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMissedCardItem(
              title: 'Bahasa Jepang',
              subtitle: 'Terakhir dipelajari 6 hari lalu',
              dueText: '16 tertunda',
            ),
            const SizedBox(height: 12),
            _buildMissedCardItem(
              title: 'Organic Chemistry',
              subtitle: 'Terakhir dipelajari 8 hari lalu',
              dueText: '5 tertunda',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(double height, Color color) {
    return Container(
      width: 32,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildMissedCardItem({
    required String title,
    required String subtitle,
    required String dueText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF192A3A),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            dueText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFE87A5D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}