import 'package:flutter/material.dart';

import 'responsive_scale.dart';

// Kartu keadaan kosong
class AppEmptyCard extends StatelessWidget {
  const AppEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36 * s, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF192A3A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13 * s, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}