import 'package:flutter/material.dart';

import 'responsive_scale.dart';

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

  static const Color _primary = Color(0xFF192A3A);
  static const Color _orange = Color(0xFFE87A5D);

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);

    Widget? trailing;
    if (infoText != null) {
      trailing = Text(
        infoText!,
        style: TextStyle(
          fontSize: 14 * s,
          color: _orange,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (actionLabel != null && onAction != null) {
      trailing = TextButton(
        onPressed: onAction,
        style: TextButton.styleFrom(
          foregroundColor: _orange,
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          actionLabel!,
          style: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w600),
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
              fontSize: 20 * s,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: _primary,
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }
}