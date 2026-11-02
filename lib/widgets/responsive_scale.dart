import 'package:flutter/material.dart';

// Pengaturan ukuran teks dan tombol berdasarkan lebar layar.
class ResponsiveScale {
  const ResponsiveScale._();

  static double of(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) return 1.3;
    if (width >= 600) return 1.15;
    return 1.0;
  }
}