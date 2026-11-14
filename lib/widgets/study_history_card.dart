import 'package:flutter/material.dart';

import 'app_item_card.dart';
import 'responsive_scale.dart';
import '../utils/formatter.dart';

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

  static const Color _goodColor = Color(0xFF2E7D32);
  static const Color _badColor = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);

    final int? rounded = accuracy?.round();
    final String accuracyText = accuracy == null
        ? '-'
        : Formatter.percent(accuracy!);
    final Color accuracyColor = rounded == null
        ? Colors.grey
        : (rounded <= 60 ? _badColor : _goodColor);

    final double bodySize = (compact ? 12 : 13) * s;

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
        titleSize: compact ? 16 : 20,
        countSize: compact ? 11 : 12,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$timeCaption : $lastStudiedLabel', 
            style: TextStyle(color: Colors.grey, fontSize: bodySize, height: 1.3),
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