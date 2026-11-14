import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';

// Footer di bawah kolom input
// pesan error merah di kiri dan penghitung jumlah karakter di kanan.
// errorTextFor menerima teks terbaru dan mengembalikan pesan error atau null bila valid.
// Tinggi footer tetap agar tata letak tidak bergeser saat error muncul/hilang.
class AppInputFooter extends StatelessWidget {
  const AppInputFooter({
    super.key,
    required this.controller,
    required this.maxLength,
    this.errorTextFor,
  });

  final TextEditingController controller;
  final int maxLength;
  final String? Function(String text)? errorTextFor;

  @override
  Widget build(BuildContext context) {
    final double s = ResponsiveScale.of(context);

    return SizedBox(
      height: 28 * s,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final String? error = errorTextFor?.call(value.text);

          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: error == null
                        ? const SizedBox.shrink()
                        : Text(
                            error,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: AppFont.small * s,
                              height: 1.2,
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${value.text.length}/$maxLength',
                    style: TextStyle(
                      fontSize: AppFont.caption * s,
                      color: AppColors.muted,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}