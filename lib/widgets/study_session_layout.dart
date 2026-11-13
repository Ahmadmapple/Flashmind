import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_session.dart';
import '../providers/auth_provider.dart';
import '../utils/formatter.dart';
import 'responsive_scale.dart';

// Desain dasar pada layar:
//  - Sesi Belajar awal      
//  - Lanjutkan Sesi Belajar 
//  - Sesi Belajar akhir 

class StudySessionStyle {
  const StudySessionStyle._();
  static const Color primary = Color(0xFF192A3A);
  static const Color accent = Color(0xFFF3C279);
  static const Color header = Color(0xFFFFE5B4);
  static const Color background = Color(0xFFFBF9F6);
}

// AppBar "Sesi Belajar" dengan judul di tengah layar.
class StudySessionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const StudySessionAppBar({
    super.key,
    required this.onBack,
    this.backgroundColor = StudySessionStyle.header,
    this.showDivider = false,
  });

  // null = tombol kembali dinonaktifkan
  final VoidCallback? onBack;
  final Color backgroundColor;
  final bool showDivider;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (showDivider ? 1 : 0));

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: true, // judul di tengah layar
      leading: IconButton(
        onPressed: onBack,
        icon: Icon(Icons.arrow_back, size: 28 * s),
        color: StudySessionStyle.primary,
        tooltip: 'Kembali',
      ),
      title: Text(
        'Sesi Belajar',
        style: TextStyle(
          fontSize: 25 * s,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: StudySessionStyle.primary,
        ),
      ),
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFE8E4DB)),
            )
          : null,
    );
  }
}

// Kerangka layar: AppBar, keterangan atas
// kartu ringkasan, dan tombol utama.
class StudySessionScaffold extends StatelessWidget {
  const StudySessionScaffold({
    super.key,
    required this.greeting,
    required this.message,
    required this.card,
    required this.button,
  });

  // Kata salam diikuti kata pertama nama pengguna.
  final String greeting;
  final String message;
  final Widget card;
  final Widget button;

  static String _firstName(String? fullName) {
    final String name = (fullName ?? '').trim();
    if (name.isEmpty) return 'Pengguna';
    return name.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    final String firstName =
        _firstName(context.watch<AuthProvider>().currentUser?.nama);

    return Scaffold(
      backgroundColor: StudySessionStyle.background,
      appBar: StudySessionAppBar(onBack: () => Navigator.of(context).pop()),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 88),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$greeting, $firstName!',
                    style: TextStyle(
                      fontSize: 20 * s,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: StudySessionStyle.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13 * s,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  card,
                  const SizedBox(height: 30),
                  Center(child: button),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Kartu ringkasan: nama set, deskripsi, riwayat pembelajaran, rekor belajar.
class StudySessionSummaryCard extends StatelessWidget {
  const StudySessionSummaryCard({
    super.key,
    required this.title,
    required this.description,
    required this.historyRows,
    required this.completedSessions,
    required this.footer,
  });

  final String title;
  final String description;

  // Pasangan (label, nilai) pada bagian Riwayat Pembelajaran.
  final List<(String, String)> historyRows;
  final List<StudySession> completedSessions;
  final String footer;

  static StudySession? _highestAccuracy(List<StudySession> sessions) {
    if (sessions.isEmpty) return null;
    return sessions.reduce((a, b) => b.accuracy > a.accuracy ? b : a);
  }

  static StudySession? _fastest(List<StudySession> sessions) {
    if (sessions.isEmpty) return null;
    return sessions
        .reduce((a, b) => b.totalDuration < a.totalDuration ? b : a);
  }

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    final StudySession? highest = _highestAccuracy(completedSessions);
    final StudySession? fastest = _fastest(completedSessions);

    final TextStyle valueStyle = TextStyle(
      fontSize: 13 * s,
      color: StudySessionStyle.primary,
      height: 1.2,
    );
    final TextStyle sectionStyle = TextStyle(
      fontSize: 15 * s,
      fontWeight: FontWeight.bold,
      fontFamily: 'serif',
      color: StudySessionStyle.primary,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB8B5AF), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 20 * s,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: StudySessionStyle.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 13 * s, color: Colors.grey, height: 1.25),
          ),
          const SizedBox(height: 25),
          Text('Riwayat Pembelajaran', style: sectionStyle),
          const SizedBox(height: 10),
          for (int i = 0; i < historyRows.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _StatRow(
              label: historyRows[i].$1,
              value: historyRows[i].$2,
              style: valueStyle,
            ),
          ],
          const SizedBox(height: 30),
          Text('Rekor Belajar', style: sectionStyle),
          const SizedBox(height: 10),
          _RecordRow(
            label: 'Tingkat kebenaran tertinggi',
            accuracy:
                highest == null ? '-' : Formatter.percent(highest.accuracy),
            duration: highest == null
                ? '-'
                : Formatter.duration(highest.totalDuration),
            style: valueStyle,
          ),
          const SizedBox(height: 20),
          _RecordRow(
            label: 'Durasi pengerjaan tercepat',
            accuracy:
                fastest == null ? '-' : Formatter.percent(fastest.accuracy),
            duration: fastest == null
                ? '-'
                : Formatter.duration(fastest.totalDuration),
            style: valueStyle,
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerRight,
            child: Text(footer, style: valueStyle),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: style)),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: constraints.maxWidth * 0.55),
              child: Text(value, textAlign: TextAlign.right, style: style),
            ),
          ],
        );
      },
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.label,
    required this.accuracy,
    required this.duration,
    required this.style,
  });

  final String label;
  final String accuracy;
  final String duration;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: style),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(accuracy, style: style),
            const SizedBox(width: 10),
            Flexible(
              child: Text(duration, textAlign: TextAlign.right, style: style),
            ),
          ],
        ),
      ],
    );
  }
}

// Tombol utama, yaitu Mulai, Lanjut, Kembali.
class StudySessionPrimaryButton extends StatelessWidget {
  const StudySessionPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return SizedBox(
      height: 40 * s,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return StudySessionStyle.accent.withValues(alpha: 0.55);
            }
            return StudySessionStyle.accent;
          }),
          foregroundColor:
              const WidgetStatePropertyAll(StudySessionStyle.primary),
          elevation: const WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 22 * s),
          ),
          minimumSize: WidgetStatePropertyAll(Size(120 * s, 40 * s)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w700),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 18 * s,
                height: 18 * s,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: StudySessionStyle.primary,
                ),
              )
            : Text(label),
      ),
    );
  }
}