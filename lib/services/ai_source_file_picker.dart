import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../models/ai_source_file.dart';
import 'ai_source_file_rules.dart';

class AiSourceFilePicker {
  const AiSourceFilePicker();

  // Membuka pemilih file dan langsung memvalidasi hasilnya.
  // null = pengguna membatalkan pemilihan.
  Future<AiSourceFileCheck?> pick() async {
    PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: AiSourceFileRules.allowedExtensions,
      );
    } catch (e, stackTrace) {
      debugPrint('Gagal membuka pemilih file: $e');
      debugPrintStack(stackTrace: stackTrace);
      return const AiSourceFileCheck.rejected(
        AiSourceFileRules.unreadableMessage,
      );
    }

    // Pengguna membatalkan pemilihan.
    if (picked == null) return null;

    try {
      // Validasi nama file.
      final String name = picked.name.trim();
      if (name.isEmpty) {
        return const AiSourceFileCheck.rejected(
          AiSourceFileRules.unreadableMessage,
        );
      }

      // ekstensi dicek sebelum file dibaca
      if (AiSourceFileType.fromFileName(name) == null) {
        return AiSourceFileCheck.rejected(AiSourceFileRules.unsupportedMessage);
      }

      // Baca ukuran file.
      final int? size = await picked.length();
      if (size == null) {
        return const AiSourceFileCheck.rejected(
          AiSourceFileRules.unreadableMessage,
        );
      }
      if (size <= 0) {
        return const AiSourceFileCheck.rejected(AiSourceFileRules.emptyMessage);
      }

      // ukuran dicek sebelum isi file dimuat ke memori
      if (size > AiSourceFileRules.maxSizeInBytes) {
        return AiSourceFileCheck.rejected(AiSourceFileRules.tooLargeMessage);
      }

      final bytes = await picked.readAsBytes();

      // ukuran memakai panjang byte yang benar-benar terbaca
      return AiSourceFileRules.check(
        name: name,
        sizeInBytes: bytes.lengthInBytes,
        bytes: bytes,
      );
    } catch (e, stackTrace) {
      debugPrint('Gagal membaca file: $e');
      debugPrintStack(stackTrace: stackTrace);
      return const AiSourceFileCheck.rejected(
        AiSourceFileRules.unreadableMessage,
      );
    }
  }

  // membersihkan salinan sementara yang dibuat plugin (Android/iOS)
  Future<void> clearTemporaryFiles() async {
    if (kIsWeb) return;
    try {
      await FilePicker.clearTemporaryFiles();
    } catch (e) {
      debugPrint('Gagal membersihkan file sementara: $e');
    }
  }
}