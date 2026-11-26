import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

// Mengambil teks polos dari file .docx (arsip ZIP berisi word/document.xml)
// Hanya teks yang diambil sehingga gambar dan format diabaikan.
class DocxTextExtractor {
  const DocxTextExtractor._();

  // Mengembalikan teks dokumen atau string kosong bila tidak ada teks
  static String extract(Uint8List bytes) {
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    final ArchiveFile? entry = archive.findFile('word/document.xml');
    if (entry == null) return '';

    final String xml = utf8.decode(
      entry.content as List<int>,
      allowMalformed: true,
    );

    final String text = xml
        .replaceAll(RegExp(r'<w:tab\s*/>'), '\t')
        .replaceAll(RegExp(r'<w:br\s*/>'), '\n')
        .replaceAll('</w:p>', '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');

    return text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }
}