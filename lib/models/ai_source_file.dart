// Model dokumen sumber untuk fitur pembuatan kartu dengan bantuan AI.

import 'dart:typed_data';

// Format dokumen yang dapat dijadikan bahan pembuatan kartu dengan AI.
enum AiSourceFileType {
  pdf(fileExtension: 'pdf', label: 'PDF', mimeType: 'application/pdf'),
  docx(
    fileExtension: 'docx',
    label: 'DOCX',
    mimeType:
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  );

  const AiSourceFileType({
    required this.fileExtension,
    required this.label,
    required this.mimeType,
  });

  final String fileExtension;
  final String label;

  // Disiapkan untuk dikirim ke layanan AI/backend saat integrasi.
  final String mimeType;

  // Menentukan format dari nama file. Null bila ekstensi tidak didukung.
  static AiSourceFileType? fromFileName(String name) {
    final int dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return null;
    final String ext = name.substring(dot + 1).toLowerCase();
    for (final AiSourceFileType type in values) {
      if (type.fileExtension == ext) return type;
    }
    return null;
  }
}

// Dokumen yang sudah lolos validasi dan siap diproses AI.
// Isi file hanya disimpan di memori (bytes), tidak ditulis ke penyimpanan.
class AiSourceFile {
  const AiSourceFile({
    required this.name,
    required this.type,
    required this.bytes,
  });

  final String name;
  final AiSourceFileType type;
  final Uint8List bytes;

  int get sizeInBytes => bytes.lengthInBytes;
}
