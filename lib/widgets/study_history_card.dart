import 'package:flutter/material.dart';

import 'app_item_card.dart';
import 'responsive_scale.dart';
import '../utils/formatter.dart';

// Antarmuka set untuk layar:
// Berkas (filter Perlu Diulas), 
// Beranda (Ulas Kembali),
// Statistik (Riwayat Belajar) dan layar Riwayat Belajar.
class StudyHistoryCard extends StatelessWidget {
  const StudyHistoryCard({
    super.key,
    required this.title,
    required this.cardCount,
    required this.lastStudiedLabel,
    required this.accuracy,
    required this.onViewDetail,
  });

  final String title;
  final int cardCount;
  final String lastStudiedLabel;

  final double? accuracy;
  final VoidCallback onViewDetail;

  static const Color _goodColor = Color(0xFF2E7D32);
  static const Color _badColor = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);

    final int? rounded = accuracy?.round();
    final String accuracyText = accuracy == null ? '-' : Formatter.percent(accuracy!);
    final Color accuracyColor = rounded == null
        ? Colors.grey
        : (rounded <= 60 ? _badColor : _goodColor);

    return AppItemCard(
      header: AppSetCardHeader(title: title, cardCount: cardCount),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terakhir dipelajari  : $lastStudiedLabel',
            style: TextStyle(color: Colors.grey, fontSize: 13 * s, height: 1.3),
          ),
          const SizedBox(height: 2),
          Text(
            'Tingkat kebenaran : $accuracyText',
            style: TextStyle(
              color: accuracyColor,
              fontSize: 13 * s,
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