import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';

// Kolom input multibaris berbingkai yang dipakai Tambah Set, Edit Set, dan Tambah Kartu.
// expands true -> mengisi tinggi induk pada Tambah Kartu
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.expands = false,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final bool expands;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    final double size = AppFont.bodyLarge * s;

    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      expands: expands,
      minLines: expands ? null : minLines,
      maxLines: expands ? null : maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.sentences,
      textAlignVertical: expands ? TextAlignVertical.top : null,
      textAlign: TextAlign.justify,
      style: TextStyle(fontSize: size, color: Colors.black87, height: 1.25),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: size, color: AppColors.hint, height: 1.25),
        contentPadding: const EdgeInsets.all(12),
        counterText: '',
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderStrong, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}