import 'package:flutter/material.dart';

import '../models/ai_source_file.dart';
import '../providers/ai_source_file_provider.dart';
import '../services/ai_source_file_rules.dart';
import '../utils/app_colors.dart';
import '../utils/formatter.dart';
import '../utils/responsive_scale.dart';
import '../widgets/app_button.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/card_side_layout.dart';
import 'ai_card_review_screen.dart';

// Layar Tambah Kartu khusus pembuatan kartu dengan bantuan AI.
class AiAddCardScreen extends StatefulWidget {
  const AiAddCardScreen({super.key, required this.setId});

  final String setId;

  @override
  State<AiAddCardScreen> createState() => _AiAddCardScreenState();
}

class _AiAddCardScreenState extends State<AiAddCardScreen> {
  // Ukuran kotak sama dengan kotak input pada AddCardScreen.
  static const double _boxHeightFactor = 0.45;
  static const double _boxMinHeight = 280;
  static const double _boxMaxHeight = 460;

  final AiSourceFileProvider _source = AiSourceFileProvider();

  bool _isOpeningReview = false;

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      );
  }

  Future<void> _pickFile() async {
    final AiSourcePickStatus status = await _source.pickFile();
    if (!mounted) return;
    if (status == AiSourcePickStatus.accepted) {
      _showMessage('File berhasil dicantumkan');
    }
  }

  void _releaseFile() {
    _source.releaseFile();
    _showMessage('File telah dilepas');
  }

  Future<void> _openReview() async {
    if (_isOpeningReview) return;
    final AiSourceFile? file = _source.requireFile();
    if (file == null) return;

    setState(() => _isOpeningReview = true);
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            AiCardReviewScreen(setId: widget.setId, sourceFile: file),
      ),
    );
    if (!mounted) return;
    setState(() => _isOpeningReview = false);

    // Kartu sudah disimpan -> file dibuang dan kembali ke Detail Set.
    if (saved == true) {
      _source.releaseFile();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double s = context.scale;
    final double boxHeight =
        (MediaQuery.sizeOf(context).height * _boxHeightFactor)
            .clamp(_boxMinHeight, _boxMaxHeight * s)
            .toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'Tambah Kartu',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _source,
          builder: (context, _) => _buildContent(s, boxHeight),
        ),
      ),
    );
  }

  Widget _buildContent(double s, double boxHeight) {
    final bool busy = _source.isPicking || _isOpeningReview;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: AppContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Dokumen Materi',
                    style: TextStyle(
                      fontSize: AppFont.title * s,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: boxHeight,
              child: CardSideBox(
                padding: EdgeInsets.zero,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: (_source.canPick && !_isOpeningReview)
                        ? _pickFile
                        : null,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _buildBoxContent(s),
                    ),
                  ),
                ),
              ),
            ),
            _buildFooter(s),
            const SizedBox(height: 12),
            Row(
              children: [
                // "Lepas File" hanya muncul ketika ada file yang dicantumkan.
                if (_source.hasFile)
                  AppButton(
                    label: 'Lepas File',
                    tone: AppButtonTone.danger,
                    size: AppButtonSize.large,
                    onPressed: busy ? null : _releaseFile,
                  ),
                const Spacer(),
                AppButton(
                  label: 'Buat Kartu',
                  size: AppButtonSize.large,
                  onPressed: busy ? null : _openReview,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxContent(double s) {
    final AiSourceFile? file = _source.file;
    if (_source.isPicking) {
      return _buildPickingState(s);
    }
    if (file != null) {
      return _buildAttachedState(file, s);
    }
    return _buildEmptyState(s);
  }

  // Kerangka isi kotak: terpusat dan dapat di-scroll bila teks diperbesar.
  Widget _boxBody({required Key key, required List<Widget> children}) {
    return Center(
      key: key,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _fileIcon(IconData icon, Color background, double s) {
    return Container(
      width: 84 * s,
      height: 84 * s,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: 42 * s, color: AppColors.primary),
    );
  }

  Widget _buildEmptyState(double s) {
    return _boxBody(
      key: const ValueKey<String>('empty'),
      children: [
        _fileIcon(Icons.upload_file_rounded, AppColors.accentSoft, s),
        const SizedBox(height: 16),
        Text(
          'Ketuk untuk memilih file',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.subtitle * s,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Silakan masukkan satu file '
          '${AiSourceFileRules.allowedExtensionsLabel} berisi materi yang '
          'ingin dipelajari. AI akan menyusun kartu dari isi dokumen sumber',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.body * s,
            color: AppColors.muted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final AiSourceFileType type in AiSourceFileType.values)
              _infoChip(type.label, s),
            _infoChip('Maks. ${AiSourceFileRules.maxSizeLabel}', s),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Dokumen hasil pindaian atau yang hanya berisi gambar belum dapat dibaca',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.caption * s,
            color: AppColors.hint,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildPickingState(double s) {
    return _boxBody(
      key: const ValueKey<String>('picking'),
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'Memeriksa file...',
          style: TextStyle(fontSize: AppFont.body * s, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildAttachedState(AiSourceFile file, double s) {
    final IconData icon = switch (file.type) {
      AiSourceFileType.pdf => Icons.picture_as_pdf_rounded,
      AiSourceFileType.docx => Icons.description_rounded,
    };

    return _boxBody(
      key: ValueKey<String>('file:${file.name}'),
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _fileIcon(icon, AppColors.success.withValues(alpha: 0.14), s),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: Icon(Icons.check, size: 16 * s, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          file.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.subtitle * s,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${file.type.label} · ${Formatter.fileSize(file.sizeInBytes)}',
          style: TextStyle(fontSize: AppFont.small * s, color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 18 * s, color: AppColors.success),
            SizedBox(width: 6 * s),
            Flexible(
              child: Text(
                'File diterima dan siap digunakan',
                style: TextStyle(
                  fontSize: AppFont.body * s,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tekan "Lepas File" untuk mengganti dokumen',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppFont.caption * s,
            color: AppColors.hint,
          ),
        ),
      ],
    );
  }

  Widget _infoChip(String label, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppFont.caption * s,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // Footer seperti AppInputFooter: pesan error merah di kiri, penghitung
  // jumlah file di kanan. Tinggi minimum tetap; pesan panjang boleh 2 baris
  // agar tidak terpotong di layar sempit (360 px).
  Widget _buildFooter(double s) {
    final String? error = _source.errorMessage;
    final int count = _source.hasFile ? 1 : 0;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 28 * s),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: error == null
                    ? const SizedBox.shrink()
                    : Text(
                        error,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: AppFont.small * s,
                          height: 1.2,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                '$count/${AiSourceFileRules.maxFileCount} file',
                style: TextStyle(
                  fontSize: AppFont.caption * s,
                  color: AppColors.muted,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
