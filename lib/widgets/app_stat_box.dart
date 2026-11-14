import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';

// Kotak statistik (label + nilai) yang dipakai Beranda dan Statistik
class AppStatBox extends StatelessWidget {
  const AppStatBox({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: AppFont.small * s,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 22 * s,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Grid 2 kolom
class AppStatGrid extends StatelessWidget {
  const AppStatGrid({super.key, required this.items});

  // Pasangan (label, nilai).
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    return GridView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10 * s,
        mainAxisSpacing: 10 * s,
        mainAxisExtent: 78 * s,
      ),
      children: [
        for (final item in items) AppStatBox(label: item.$1, value: item.$2),
      ],
    );
  }
}