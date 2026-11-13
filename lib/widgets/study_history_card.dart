import 'package:flutter/material.dart';

import 'responsive_scale.dart';
import 'word_ellipsis_text.dart';
import '../utils/formatter.dart';

// Antarmuka set untuk layar Riwayat Belajar dan filter "Perlu Diulas" di Berkas.
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

  static const Color _primaryColor = Color(0xFF192A3A);
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: WordEllipsisText(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    color: _primaryColor,
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
          ),
          const SizedBox(height: 6),
          Text(
            'Terakhir dipelajari  : $lastStudiedLabel',
            style: TextStyle(color: Colors.grey, fontSize: 13 * s, height: 1.3),
          ),
          const SizedBox(height: 2),
          Text(
            'Tingkat kebenaran: $accuracyText',
            style: TextStyle(
              color: accuracyColor,
              fontSize: 13 * s,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewDetail,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE87A5D),
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * s,
                  vertical: 6 * s,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lihat Detail →',
                style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
