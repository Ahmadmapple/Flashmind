import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/formatter.dart';
import 'app_item_card.dart';
import '../utils/responsive_scale.dart';

// Antarmuka set untuk layar:
// Berkas (filter Perlu Diulas),
// Beranda (Ulas Kembali),
// Statistik (Riwayat Belajar, Wawasan Belajar) dan layar Riwayat Belajar.
class StudyHistoryCard extends StatelessWidget {
  const StudyHistoryCard({
    super.key,
    required this.title,
    required this.cardCount,
    required this.lastStudiedLabel,
    required this.accuracy,
    required this.onViewDetail,
    this.timeCaption = 'Terakhir dipelajari',
    this.compact = false,
  });

  final String title;
  final int cardCount;

  // Nilai untuk teks waktu atau durasi
  final String lastStudiedLabel;
  final String timeCaption;

  // Versi lebih kecil agar muat di dalam kotak lain (Wawasan Belajar).
  final bool compact;

  final double? accuracy;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);

    final int? rounded = accuracy?.round();
    final String accuracyText =
        accuracy == null ? '-' : Formatter.percent(accuracy!);
    final Color accuracyColor = rounded == null
        ? AppColors.muted
        : (rounded <= 60 ? AppColors.danger : AppColors.success);

    final double bodySize = (compact ? AppFont.caption : AppFont.small) * s;

    return AppItemCard(
      // padding dan jarak dikecilkan pada mode compact
      padding: compact
          ? const EdgeInsets.fromLTRB(14, 10, 6, 6)
          : AppItemCardStyle.padding,
      headerGap: compact ? 4 : 6,
      footerGap: compact ? 2 : 6,
      header: AppSetCardHeader(
        title: title,
        cardCount: cardCount,
        titleSize: compact ? 16 : AppFont.title,
        countSize: compact ? 11 : AppFont.caption,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$timeCaption : $lastStudiedLabel',
            style: TextStyle(color: AppColors.muted, fontSize: bodySize, height: 1.3),
          ),
          const SizedBox(height: 2),
          Text(
            'Tingkat kebenaran: $accuracyText',
            style: TextStyle(
              color: accuracyColor,
              fontSize: bodySize,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
      footer: Align(
        alignment: Alignment.centerRight,
        child: AppDetailLink(onPressed: onViewDetail),
      ),
    );
  }
}