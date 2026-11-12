import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _resentSuccess = false;

  static const Color _primary = Color(0xFF192A3A);
  static const Color _orange  = Color(0xFFE87A5D);

  Future<void> _resend() async {
    setState(() {
      _isResending    = true;
      _resentSuccess  = false;
    });

    final error = await context
        .read<AuthProvider>()
        .resendVerificationEmail(widget.email, widget.password);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (error == null) {
      setState(() => _resentSuccess = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verifikasi telah dikirim ulang.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        ),
      );
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _primary),
          onPressed: _goToLogin,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      color: Color(0xFFF3C279),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  'Verifikasi Email',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: _primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Deskripsi
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black54, height: 1.6),
                    children: [
                      const TextSpan(
                          text: 'Kami telah mengirim link verifikasi ke\n'),
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                      const TextSpan(
                          text:
                              '\n\nKlik link tersebut untuk mengaktifkan akun, '
                              'lalu kembali ke sini dan masuk.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Kotak info langkah
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFE8E4DB), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      _StepRow(
                        number: '1',
                        text: 'Buka aplikasi email di perangkat kamu',
                      ),
                      const SizedBox(height: 10),
                      _StepRow(
                        number: '2',
                        text: 'Cari email dari Flash Mind / Firebase',
                      ),
                      const SizedBox(height: 10),
                      _StepRow(
                        number: '3',
                        text: 'Klik tombol "Verifikasi Email" di email tersebut',
                      ),
                      const SizedBox(height: 10),
                      _StepRow(
                        number: '4',
                        text: 'Kembali ke sini dan tekan "Masuk ke Akun"',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol utama
                ElevatedButton(
                  onPressed: _goToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Masuk ke Akun',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Kirim ulang
                TextButton(
                  onPressed: _isResending ? null : _resend,
                  style: TextButton.styleFrom(
                    foregroundColor: _orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isResending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _orange,
                          ),
                        )
                      : Text(
                          _resentSuccess
                              ? 'Email terkirim ✓'
                              : 'Tidak menerima email? Kirim ulang',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF3C279),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF192A3A),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }
}
