// Utilitas format untuk durasi, rentang waktu, tanggal, dan persentase.
class Formatter {
  const Formatter._();

  static String _two(int n) => n.toString().padLeft(2, '0');

  // Durasi -> "jj:mm:dd". Sisa detik dibulatkan ke bawah, nilai negatif menjadi 00:00:00.
  static String duration(Duration d) {
    final int total = d.isNegative ? 0 : d.inSeconds;
    final int h = total ~/ 3600;
    final int m = (total % 3600) ~/ 60;
    final int s = total % 60;
    return '${_two(h)}:${_two(m)}:${_two(s)}';
  }

  // Tanggal -> "dd/mm/yyyy"
  static String date(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

  // Selisih waktu terhadap sekarang:
  //  < 1 menit -> "Baru saja"
  //  < 1 jam   -> "[n] menit lalu"
  //  < 1 hari  -> "[n] jam lalu"
  //  1 hari    -> "Kemarin"
  //  < 7 hari  -> "[n] hari lalu"
  //  >= 7 hari -> "dd/mm/yyyy"
  // Nilai null ditangani oleh pemanggil karena teksnya berbeda per layar
  static String relativeTime(DateTime time, {DateTime? now}) {
    final Duration diff = (now ?? DateTime.now()).difference(time);
    if (diff.isNegative || diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return date(time);
  }

  // Persentase -> "[0..100]%", desimal dibulatkan.
  static String percent(num value) {
    if (value.isNaN) return '0%';
    return '${value.clamp(0, 100).round()}%';
  }
}