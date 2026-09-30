import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data pengguna yang sedang aktif
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6), // Sesuai tema aplikasi
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF192A3A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(color: Color(0xFF192A3A), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Tidak ada data pengguna'))
          : ListView(
        padding: const EdgeInsets.all(32.0),
        children: [
          // Foto Profil Inisial
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFFE5E5E5),
            child: Text(
              user.nama.isNotEmpty ? user.nama[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF192A3A),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nama & Email
          Text(
            user.nama,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: Color(0xFF192A3A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Tombol Edit Profil
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text(
                'Edit Profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF192A3A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Keluar (Logout)
          OutlinedButton.icon(
            onPressed: () async {
              // Proses logout menghapus data dari memori
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                // Mengarahkan paksa kembali ke layar Login dengan animasi halus
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 600),
                  ),
                      (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Color(0xFFE87A5D)),
            label: const Text(
                'Keluar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE87A5D))
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: const BorderSide(color: Color(0xFFE87A5D), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}