import '../models/ai_source_file.dart';
import 'card_form_rules.dart';

// Kartu hasil AI yang belum disimpan ke set.
class GeneratedCard {
  const GeneratedCard({required this.frontText, required this.backText});

  final String frontText;
  final String backText;

  // Menyesuaikan keluaran AI dengan aturan kartu (CardFormRules):
  // teks dirapikan, dibatasi 999 karakter, dan kartu kosong dibuang.
  static GeneratedCard? normalize(String front, String back) {
    final String f = _clip(front.trim());
    final String b = _clip(back.trim());
    if (CardFormRules.evaluate(f, b) != CardFormIssue.none) return null;
    return GeneratedCard(frontText: f, backText: b);
  }

  static String _clip(String text) => text.length <= CardFormRules.maxLength
      ? text
      : text.substring(0, CardFormRules.maxLength);
}

// Kesalahan yang pesannya aman ditampilkan kepada pengguna.
class AiCardGenerationException implements Exception {
  const AiCardGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AiCardGenerator {
  const AiCardGenerator();

  // Membuat kartu dari dokumen sumber.
  // Implementasi nyata dapat:
  //  - mengirim file.bytes + file.type.mimeType ke backend/Cloud Function, atau
  //  - mengekstrak teks (PDF langsung, DOCX dari word/document.xml) lalu
  //    mengirimkannya ke model AI dengan instruksi membuat pasangan depan/belakang.
  // Hasil sebaiknya dilewatkan ke GeneratedCard.normalize sebelum dikembalikan.
  Future<List<GeneratedCard>> generateCards(AiSourceFile file);
}
