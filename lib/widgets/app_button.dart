import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';

// Warna tombol.
enum AppButtonTone { accent, danger, primary }

// Ukuran tombol:
//  - large  : Mulai, Lanjut, Kembali, Buat Set, Buat Kartu, Tambah Kartu, Batal/Hapus pada dialog
//  - medium : Tambah Set, Hapus Set, Mulai Belajar, Hapus Kartu, Edit Kartu, Edit Set, dst.
enum AppButtonSize { large, medium }

// Desain dasar tombol aksi pada aplikasi.
// - onPressed null dan isLoading false -> tombol terkunci (abu-abu)
// - isLoading true -> warna tetap, isi diganti indikator loading
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = AppButtonTone.accent,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.expand = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonTone tone;
  final AppButtonSize size;
  final bool isLoading;

  // True -> melebar mengikuti lebar induk dipakai di dalam Expanded.
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    final bool large = size == AppButtonSize.large;
    final bool locked = onPressed == null && !isLoading;

    // warna dari AppColors
    final (Color bg, Color fg, Color border) = locked
        ? (AppColors.disabledBg, AppColors.inactive, AppColors.disabledBg)
        : switch (tone) {
            AppButtonTone.accent =>
              (AppColors.accent, AppColors.primary, AppColors.accentBorder),
            AppButtonTone.danger =>
              (AppColors.danger, Colors.white, AppColors.danger),
            AppButtonTone.primary =>
              (AppColors.primary, Colors.white, AppColors.primary),
          };

    final double height = (large ? 44 : 40) * s;
    final double minWidth = expand ? 0 : (large ? 120 : 110) * s;

    final Widget content = isLoading
        ? SizedBox(
            width: 18 * s,
            height: 18 * s,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: (large ? 22 : 18) * s),
                  SizedBox(width: 6 * s),
                ],
                Text(label),
              ],
            ),
          );

    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(bg),
          foregroundColor: WidgetStatePropertyAll(fg),
          elevation: const WidgetStatePropertyAll(0),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: (large ? 22 : 15) * s),
          ),
          minimumSize: WidgetStatePropertyAll(Size(minWidth, height)),
          shape: WidgetStatePropertyAll(
            StadiumBorder(side: BorderSide(color: border, width: 0.7)),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontSize: (large ? AppFont.button : AppFont.body) * s,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child: content,
      ),
    );
  }
}