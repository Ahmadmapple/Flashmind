import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';

// Desain dasar filter
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary : AppColors.surface,
        foregroundColor: selected ? Colors.white : AppColors.primary,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 9 * s),
        minimumSize: Size(0, 5 * s),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: TextStyle(fontSize: AppFont.body * s, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}