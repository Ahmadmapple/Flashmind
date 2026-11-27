import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ai_source_file.dart';
import '../services/ai_source_file_picker.dart';
import '../services/ai_source_file_rules.dart';

// State dokumen sumber pada layar Tambah Kartu (AI)
// Dibuat per layar sehingga file otomatis dibuang ketika layar ditutup
enum AiSourcePickStatus { accepted, rejected, cancelled }

class AiSourceFileProvider extends ChangeNotifier {
  AiSourceFileProvider({this._picker = const AiSourceFilePicker()});

  final AiSourceFilePicker _picker;

  AiSourceFile? _file;
  bool _isPicking = false;
  String? _errorMessage;
  bool _disposed = false;

  AiSourceFile? get file => _file;
  bool get hasFile => _file != null;
  bool get isPicking => _isPicking;
  String? get errorMessage => _errorMessage;

  // Pemilihan hanya dapat dilakukan bila belum ada file (maksimal satu file).
  bool get canPick => !_isPicking && _file == null;

  Future<AiSourcePickStatus> pickFile() async {
    if (!canPick) return AiSourcePickStatus.cancelled;

    _isPicking = true;
    _errorMessage = null;
    notifyListeners();

    final AiSourceFileCheck? check = await _picker.pick();

    // Isi file sudah berada di memori, salinan sementara plugin tidak dibutuhkan.
    unawaited(_picker.clearTemporaryFiles());

    if (_disposed) return AiSourcePickStatus.cancelled;
    _isPicking = false;

    if (check == null) {
      notifyListeners();
      return AiSourcePickStatus.cancelled;
    }

    final AiSourceFile? accepted = check.file;
    if (accepted == null) {
      _errorMessage = check.error;
      notifyListeners();
      return AiSourcePickStatus.rejected;
    }

    _file = accepted;
    notifyListeners();
    return AiSourcePickStatus.accepted;
  }

  // Membuang file saat ini sehingga file lama tidak terbawa ke pembuatan kartu berikutnya.
  void releaseFile() {
    if (_file == null && _errorMessage == null) return;
    _file = null;
    _errorMessage = null;
    notifyListeners();
    unawaited(_picker.clearTemporaryFiles());
  }

  // Mengembalikan file untuk diproses, atau menampilkan error bila belum ada.
  AiSourceFile? requireFile() {
    if (_file != null) return _file;
    _errorMessage = AiSourceFileRules.missingFileMessage;
    notifyListeners();
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    _file = null;
    unawaited(_picker.clearTemporaryFiles());
    super.dispose();
  }
}
