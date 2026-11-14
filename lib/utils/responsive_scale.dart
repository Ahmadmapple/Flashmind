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

// Pintasan: context.scale
extension ResponsiveContext on BuildContext {
  double get scale => ResponsiveScale.of(this);
}

// Skala ukuran font dasar (sebelum dikali context.scale).
// fontSize: AppFont.body * s
class AppFont {
  const AppFont._();
  static const double caption = 12; // label kecil
  static const double small = 13; // teks pendukung
  static const double body = 14; // teks isi
  static const double bodyLarge = 15; // isi utama, input
  static const double button = 16;
  static const double subtitle = 18;
  static const double title = 20; // judul bagian
  static const double heading = 22;
  static const double appBar = 25;
  static const double page = 30; // judul halaman
}

// Membatasi lebar konten agar tidak melebar berlebihan di tablet/monitor.
// Batas lebar ikut dikali skala sehingga komponen terasa proporsional.
class AppContentFrame extends StatelessWidget {
  const AppContentFrame({super.key, required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth * context.scale),
        child: child,
      ),
    );
  }
}
