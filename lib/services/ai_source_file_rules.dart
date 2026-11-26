import 'dart:convert';
import 'dart:typed_data';

import '../models/ai_source_file.dart';
import '../utils/formatter.dart';

// Aturan validasi dokumen sumber untuk pembuatan kartu dengan AI

// Hasil pemeriksaan satu file berisi file yang diterima atau pesan penolakan.
class AiSourceFileCheck {
  const AiSourceFileCheck.accepted(AiSourceFile this.file) : error = null;
  const AiSourceFileCheck.rejected(String this.error) : file = null;

  final AiSourceFile? file;
  final String? error;

  bool get isAccepted => file != null;
}

class AiSourceFileRules {
  const AiSourceFileRules._();

  // Batas ukuran file. Menjaga waktu unggah dan pemrosesan AI tetap wajar 
  // serta berada di bawah batas umum API dokumen model AI.
  static const int maxSizeInBytes = 10 * 1024 * 1024;

  // Jumlah file per satu kali pembuatan kartu.
  static const int maxFileCount = 1;

  static List<String> get allowedExtensions => [
    for (final AiSourceFileType type in AiSourceFileType.values)
      type.fileExtension,
  ];

  // ".pdf atau .docx"
  static String get allowedExtensionsLabel =>
      allowedExtensions.map((e) => '.$e').join(' atau ');

  static String get maxSizeLabel => Formatter.fileSize(maxSizeInBytes);

  // Pesan validasi
  static const String missingFileMessage = 'Cantumkan satu file terlebih dahulu';
  static const String unreadableMessage =
      'File tidak dapat dibaca. Silakan pilih ulang';
  static String get unsupportedMessage =>
      'Format tidak didukung, gunakan file $allowedExtensionsLabel';
  static String get tooLargeMessage =>
      'Ukuran file melebihi batas $maxSizeLabel';
  static const String emptyMessage = 'File kosong sehingga tidak dapat digunakan';
  static String invalidContentMessage(AiSourceFileType type) =>
      'Isi file bukan .${type.fileExtension} yang valid atau file rusak';

  // Memeriksa nama, ukuran, dan isi file secara berurutan.
  static AiSourceFileCheck check({
    required String name,
    required int sizeInBytes,
    required Uint8List? bytes,
  }) {
    final AiSourceFileType? type = AiSourceFileType.fromFileName(name);
    if (type == null) return AiSourceFileCheck.rejected(unsupportedMessage);

    if (sizeInBytes > maxSizeInBytes) {
      return AiSourceFileCheck.rejected(tooLargeMessage);
    }
    if (bytes == null) return const AiSourceFileCheck.rejected(unreadableMessage);
    if (bytes.isEmpty || sizeInBytes == 0) {
      return const AiSourceFileCheck.rejected(emptyMessage);
    }
    if (bytes.lengthInBytes > maxSizeInBytes) {
      return AiSourceFileCheck.rejected(tooLargeMessage);
    }

    // Ekstensi dapat diganti sembarangan, jadi isi file juga diperiksa.
    if (!_hasValidSignature(type, bytes)) {
      return AiSourceFileCheck.rejected(invalidContentMessage(type));
    }

    return AiSourceFileCheck.accepted(
      AiSourceFile(name: name, type: type, bytes: bytes),
    );
  }

  static bool _hasValidSignature(AiSourceFileType type, Uint8List bytes) =>
      switch (type) {
        AiSourceFileType.pdf => _isPdf(bytes),
        AiSourceFileType.docx => _isDocx(bytes),
      };

  // PDF diawali penanda "%PDF-" yang boleh didahului beberapa byte lain
  static bool _isPdf(Uint8List bytes) {
    final int limit = bytes.length < 1024 ? bytes.length : 1024;
    final String head = latin1.decode(bytes.sublist(0, limit));
    return head.contains('%PDF-');
  }

  // DOCX adalah arsip ZIP ("PK\x03\x04") yang memuat "word/document.xml"
  // Pemeriksaan kedua menolak ZIP/XLSX/PPTX yang diganti ekstensinya.
  static bool _isDocx(Uint8List bytes) {
    if (bytes.length < 4) return false;
    final bool isZip =
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        bytes[2] == 0x03 &&
        bytes[3] == 0x04;
    if (!isZip) return false;
    return _containsAscii(bytes, 'word/document.xml');
  }

  static bool _containsAscii(Uint8List bytes, String pattern) {
    final List<int> p = ascii.encode(pattern);
    final int last = bytes.length - p.length;
    outer:
    for (int i = 0; i <= last; i++) {
      for (int j = 0; j < p.length; j++) {
        if (bytes[i + j] != p[j]) continue outer;
      }
      return true;
    }
    return false;
  }
}
