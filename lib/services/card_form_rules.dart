// Hasil pemeriksaan isi formulir kartu untuk layar Tambah Kartu dan Edit Kartu
enum CardFormIssue { none, both, frontOnly, backOnly }

// Aturan formulir kartu yang dipakai oleh Tambah Kartu dan Edit Kartu.
class CardFormRules {
  const CardFormRules._();

  static const int maxLength = 999;

  // Sisi yang masih kosong
  static CardFormIssue evaluate(String front, String back) {
    final bool frontEmpty = front.trim().isEmpty;
    final bool backEmpty = back.trim().isEmpty;
    if (frontEmpty && backEmpty) return CardFormIssue.both;
    if (frontEmpty) return CardFormIssue.frontOnly;
    if (backEmpty) return CardFormIssue.backOnly;
    return CardFormIssue.none;
  }

  // Pesan error footer untuk sisi yang sedang tampil dengan null bila tidak ada error
  static String? footerError({
    required bool isBack,
    required bool showError,
    required String front,
    required String back,
  }) {
    if (!showError) return null;
    final bool bothEmpty = front.trim().isEmpty && back.trim().isEmpty;
    if (bothEmpty) return 'Sisi depan dan belakang perlu diisi.';
    return isBack ? 'Sisi belakang perlu diisi.' : 'Sisi depan perlu diisi.';
  }
}