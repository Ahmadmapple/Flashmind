import 'package:flutter/material.dart';

import 'responsive_scale.dart';
import 'word_ellipsis_text.dart';

// Desain dasar untuk kartu set dan kartu flashcard.
class AppItemCardStyle {
  const AppItemCardStyle._();
  static const Color primary = Color(0xFF192A3A);
  static const Color border = Color(0xFFE8E4DB);
  static const Color link = Color(0xFFE87A5D);
  static const EdgeInsets padding = EdgeInsets.fromLTRB(18, 16, 10, 14);
}

// Kerangka kartu: 
// kontainer + bagian atas (header), isi (body), dan bawah (footer).
// Jika height diisi, tinggi kartu tetap dan body mengisi sisa ruang Expanded.
// Jika tidak, tinggi mengikuti isi.
class AppItemCard extends StatelessWidget {
  const AppItemCard({
    super.key,
    required this.header,
    required this.footer,
    this.body,
    this.height,
    this.padding = AppItemCardStyle.padding,
    this.headerGap = 6,
    this.footerGap = 6,
  });

  final Widget header;
  final Widget? body;
  final Widget footer;
  final double? height;
  final EdgeInsets padding;
  final double headerGap;
  final double footerGap;

  @override
  Widget build(BuildContext context) {
    final Widget? content = body;
    return Container(
      width: double.infinity,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppItemCardStyle.border, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          if (content != null) ...[
            SizedBox(height: headerGap),
            if (height != null) Expanded(child: content) else content,
          ],
          SizedBox(height: footerGap),
          footer,
        ],
      ),
    );
  }
}

// Bagian atas kartu set: 
// nama set dipotong pada batas kata dan jumlah kartu.
class AppSetCardHeader extends StatelessWidget {
  const AppSetCardHeader({
    super.key,
    required this.title,
    required this.cardCount,
  });

  final String title;
  final int cardCount;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: WordEllipsisText(
            title,
            maxLines: 1,
            style: TextStyle(
              color: AppItemCardStyle.primary,
              fontSize: 20 * s,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            '$cardCount kartu',
            style: TextStyle(color: Colors.grey, fontSize: 12 * s),
          ),
        ),
      ],
    );
  }
}

// Tautan "Lihat detail →" yang dipakai semua kartu.
class AppDetailLink extends StatelessWidget {
  const AppDetailLink({
    super.key,
    required this.onPressed,
    this.label = 'Lihat detail →',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppItemCardStyle.link,
        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 6 * s),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.bold),
      ),
    );
  }
}