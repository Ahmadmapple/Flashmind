import 'package:flutter/material.dart';

import 'responsive_scale.dart';

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
        backgroundColor: selected ? const Color(0xFF192A3A) : Colors.white,
        foregroundColor: selected ? Colors.white : const Color(0xFF192A3A),
        side: BorderSide(
          color: selected ? const Color(0xFF192A3A) : const Color(0xFFE8E4DB),
          width: 1.5,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 9 * s),
        minimumSize: Size(0, 5 * s),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: TextStyle(fontSize: 14 * s, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}