import 'package:flutter/material.dart';

// Sumber tunggal warna aplikasi.
class AppColors {
  const AppColors._();

  // Warna dasar
  static const Color primary = Color(0xFF192A3A); // biru gelap
  static const Color accent = Color(0xFFF3C279); // kuning emas
  static const Color accentBorder = Color(0xFFD7A957);
  static const Color accentSoft = Color(0xFFFFE5B4); // latar AppBar sesi belajar
  static const Color accentDark = Color(0xFF8B6914);
  static const Color link = Color(0xFFE87A5D); // tautan, subjudul

  // Status
  static const Color danger = Color(0xFFEF5350); // merah
  static const Color dangerSoft = Color(0xFFFDE8E8);
  static const Color success = Color(0xFF3B8C68); // hijau

  // Permukaan dan garis
  static const Color background = Color(0xFFFBF9F6);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE8E4DB);
  static const Color borderStrong = Color(0xFFB8B5AF);

  // Teks dan keadaan nonaktif
  static const Color muted = Color(0xFF9A9894); // teks pendukung berwarna abu-abu
  static const Color hint = Color(0xFFB4B1AC);
  static const Color textSecondary = Colors.black54;
  static const Color inactive = Color(0xFFBDBDBD); // ikon atau teks nonaktif
  static const Color disabledBg = Color(0xFFEEEEEE); // tombol terkunci
}