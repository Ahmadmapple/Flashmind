import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';

// Subjudul bagian pada Beranda dan Statistik.
// Teks pendamping di sisi kanan bersifat opsional:
//  - infoText    : teks biasa, seperti "3 hari beruntun"
//  - actionLabel : tombol teks, seperti "Lihat semua"
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.infoText,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? infoText;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);

    Widget? trailing;
    if (infoText != null) {
      trailing = Text(
        infoText!,
        style: TextStyle(
          fontSize: AppFont.body * s,
          color: AppColors.link,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (actionLabel != null && onAction != null) {
      trailing = TextButton(
        onPressed: onAction,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.link,
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          actionLabel!,
          style: TextStyle(fontSize: AppFont.body * s, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: AppFont.title * s,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: AppColors.primary,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }
}