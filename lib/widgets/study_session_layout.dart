import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_session.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/formatter.dart';
import '../utils/responsive_scale.dart';
import 'app_button.dart';

// Desain dasar pada layar:
//  - Sesi Belajar awal
//  - Lanjutkan Sesi Belajar
//  - Sesi Belajar akhir

class StudySessionStyle {
  const StudySessionStyle._();
  static const Color primary = AppColors.primary;
  static const Color accent = AppColors.accent;
  static const Color header = AppColors.accentSoft;
  static const Color background = AppColors.background;
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
          fontSize: AppFont.appBar * s,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: StudySessionStyle.primary,
        ),
      ),
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
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
    this.onBack,
  });

  // Kata salam diikuti kata pertama nama pengguna.
  final String greeting;
  final String message;
  final Widget card;
  final Widget button;
  final VoidCallback? onBack;

  static String _firstName(String? fullName) {
    final String name = (fullName ?? '').trim();
    if (name.isEmpty) return 'Pengguna';
    return name.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    final String firstName = _firstName(
      context.watch<AuthProvider>().currentUser?.nama,
    );

    return Scaffold(
      backgroundColor: StudySessionStyle.background,
      appBar: StudySessionAppBar(
        onBack: onBack ?? () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 88),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 560 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$greeting, $firstName!',
                    style: TextStyle(
                      fontSize: AppFont.title * s,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: StudySessionStyle.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: AppFont.small * s,
                      color: AppColors.muted,
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
    return sessions.reduce((a, b) => b.totalDuration < a.totalDuration ? b : a);
  }

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    final StudySession? highest = _highestAccuracy(completedSessions);
    final StudySession? fastest = _fastest(completedSessions);

    final TextStyle valueStyle = TextStyle(
      fontSize: AppFont.small * s,
      color: StudySessionStyle.primary,
      height: 1.2,
    );
    final TextStyle sectionStyle = TextStyle(
      fontSize: AppFont.bodyLarge * s,
      fontWeight: FontWeight.bold,
      fontFamily: 'serif',
      color: StudySessionStyle.primary,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderStrong, width: 1),
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
              fontSize: AppFont.title * s,
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
            style: TextStyle(
              fontSize: AppFont.small * s,
              color: AppColors.muted,
              height: 1.25,
            ),
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
            accuracy: highest == null
                ? '-'
                : Formatter.percent(highest.accuracy),
            duration: highest == null
                ? '-'
                : Formatter.duration(highest.totalDuration),
            style: valueStyle,
          ),
          const SizedBox(height: 20),
          _RecordRow(
            label: 'Durasi pengerjaan tercepat',
            accuracy: fastest == null
                ? '-'
                : Formatter.percent(fastest.accuracy),
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
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.55,
              ),
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
    return AppButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      size: AppButtonSize.large,
    );
  }
}