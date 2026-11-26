import 'package:flutter/material.dart';

import '../models/ai_source_file.dart';
import '../repositories/flash_mind_repository.dart';
import '../services/ai_card_generator.dart';
import '../services/gemini_card_generator.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';
import '../widgets/app_button.dart';
import '../widgets/app_top_bar.dart';

/// Model sementara untuk kartu yang dibuat AI
class _AiCard {
  _AiCard({required this.front, required this.back});

  factory _AiCard.fromGenerated(GeneratedCard card) =>
      _AiCard(front: card.frontText, back: card.backText);

  final String front;
  final String back;
  bool accepted = true;
}

/// Halaman untuk meninjau kartu yang dibuat AI dari dokumen sumber.
/// Pengguna dapat menerima atau menolak tiap kartu sebelum disimpan ke set.
class AiCardReviewScreen extends StatefulWidget {
  const AiCardReviewScreen({
    super.key,
    required this.setId,
    required this.sourceFile,
    this.generator = const GeminiCardGenerator(),
  });

  final String setId;
  final AiSourceFile sourceFile;
  final AiCardGenerator generator;

  @override
  State<AiCardReviewScreen> createState() => _AiCardReviewScreenState();
}

class _AiCardReviewScreenState extends State<AiCardReviewScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Pesan bila pembuatan kartu gagal atau tidak menghasilkan kartu
  String? _generationError;

  // Kartu hasil AI yang ditinjau pengguna
  final List<_AiCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _generateCards();
  }

  // Kartu diperoleh dari AiCardGenerator
  Future<void> _generateCards() async {
    String? error;
    List<GeneratedCard> generated = const [];
    try {
      generated = await widget.generator.generateCards(widget.sourceFile);
      if (generated.isEmpty) {
        error = 'AI tidak menemukan materi yang dapat dijadikan kartu '
            'dari dokumen ini';
      }
    } on AiCardGenerationException catch (e) {
      error = e.message;
    } catch (e) {
      debugPrint('Gagal membuat kartu dengan AI: $e');
      error = 'Kartu gagal dibuat. Periksa koneksi lalu coba lagi';
    }

    if (!mounted) return;

    setState(() {
      _cards.addAll(generated.map(_AiCard.fromGenerated));
      _generationError = error;
      _isLoading = false;
    });
  }

  // Mengulang pembuatan kartu setelah gagal
  void _retryGeneration() {
    setState(() {
      _isLoading = true;
      _generationError = null;
      _cards.clear();
    });
    _generateCards();
  }

  int get _acceptedCount => _cards.where((c) => c.accepted).length;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ),
    );
  }

  // Bila ada kartu yang gagal disimpan, proses penambahan berhenti
  // Kartu dikeluarkan dari daftar sehingga tidak terduplikasi saat dicoba ulang
  Future<void> _saveAcceptedCards() async {
    if (_isSaving) return;

    final accepted = _cards.where((c) => c.accepted).toList();
    if (accepted.isEmpty) {
      _showMessage('Pilih minimal satu kartu untuk disimpan');
      return;
    }

    setState(() => _isSaving = true);

    final repo = FlashMindRepository.instance;
    final List<_AiCard> savedCards = [];
    bool failed = false;

    for (final card in accepted) {
      try {
        // addFlashcard menulis ke Firestore lalu memperbarui data lokal
        final created = await repo.addFlashcard(
          setId: widget.setId,
          frontText: card.front,
          backText: card.back,
        );
        if (created == null) {
          failed = true;
          break;
        }
        savedCards.add(card);
      } catch (e) {
        debugPrint('Gagal menyimpan kartu AI: $e');
        failed = true;
        break;
      }
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (failed) _cards.removeWhere(savedCards.contains);
    });

    if (failed) {
      _showMessage(
        savedCards.isEmpty
            ? 'Kartu gagal disimpan. Periksa koneksi lalu coba lagi'
            : '${savedCards.length} kartu tersimpan, sisanya gagal. '
                'Silakan coba simpan lagi',
      );
      return;
    }

    _showMessage('${savedCards.length} kartu berhasil ditambahkan ke set');

    // Mengembalikan true agar layar Tambah Kartu (AI) ikut ditutup
    // dan pengguna kembali ke Detail Set
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    // Bilah bawah hanya tampil bila kartu berhasil dibuat
    final bool showBottomBar = !_isLoading && _generationError == null;

    // PopScope mencegah penutupan layar dengan tombol kembali saat menyimpan
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopBar(
          title: 'Tinjau Kartu AI',
          centerTitle: false,
          onBack: _isSaving ? null : () => Navigator.of(context).pop(),
        ),
        body: _isLoading
            ? _buildLoadingState()
            : _generationError != null
            ? _buildErrorState(_generationError!)
            : _buildReviewBody(),
        bottomNavigationBar: showBottomBar ? _buildBottomBar() : null,
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    final double s = context.scale;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'AI sedang membuat kartu\ndari dokumen kamu...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFont.button * s,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Gagal/tanpa hasil
  Widget _buildErrorState(String message) {
    final double s = context.scale;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: AppContentFrame(
          shrinkHeight: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48 * s, color: AppColors.danger),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFont.button * s,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Coba Lagi',
                size: AppButtonSize.large,
                onPressed: _retryGeneration,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────
  Widget _buildReviewBody() {
    final double s = context.scale;
    // Ikon mengikuti format dokumen sumber
    final IconData fileIcon = switch (widget.sourceFile.type) {
      AiSourceFileType.pdf => Icons.picture_as_pdf,
      AiSourceFileType.docx => Icons.description,
    };

    return AppContentFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama file
                Row(
                  children: [
                    Icon(fileIcon, color: AppColors.link, size: 18 * s),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.sourceFile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFont.small * s,
                          color: AppColors.link,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'AI membuat ${_cards.length} kartu. '
                  'Centang kartu yang ingin disimpan ke set',
                  style: TextStyle(fontSize: AppFont.body * s, color: AppColors.muted),
                ),
              ],
            ),
          ),

          // Toggle pilih semua
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () {
                          final allAccepted = _acceptedCount == _cards.length;
                          setState(() {
                            for (final c in _cards) {
                              c.accepted = !allAccepted;
                            }
                          });
                        },
                  icon: Icon(
                    _acceptedCount == _cards.length
                        ? Icons.deselect
                        : Icons.select_all,
                    size: 20 * s,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    _acceptedCount == _cards.length
                        ? 'Batalkan Semua'
                        : 'Pilih Semua',
                    style: TextStyle(
                      fontSize: AppFont.body * s,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Text(
                  '$_acceptedCount/${_cards.length} dipilih',
                  style: TextStyle(fontSize: AppFont.small * s, color: AppColors.muted),
                ),
              ],
            ),
          ),

          // Daftar kartu
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              itemCount: _cards.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildCardItem(_cards[index], index, s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(_AiCard card, int index, double s) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: card.accepted ? AppColors.success : AppColors.border,
          width: card.accepted ? 2 : 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _isSaving
            ? null
            : () {
                setState(() {
                  card.accepted = !card.accepted;
                });
              },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox custom
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 24 * s,
                  height: 24 * s,
                  decoration: BoxDecoration(
                    color: card.accepted ? AppColors.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: card.accepted ? AppColors.success : AppColors.inactive,
                      width: 2,
                    ),
                  ),
                  child: card.accepted
                      ? Icon(Icons.check, color: Colors.white, size: 16 * s)
                      : null,
                ),
              ),

              // Konten kartu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label + nomor
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'KARTU ${index + 1}',
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Depan
                    Text(
                      'Depan',
                      style: TextStyle(
                        fontSize: AppFont.caption * s,
                        fontWeight: FontWeight.bold,
                        color: AppColors.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      card.front,
                      style: TextStyle(
                        fontSize: AppFont.bodyLarge * s,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Divider tipis
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 10),

                    // Belakang
                    Text(
                      'Belakang',
                      style: TextStyle(
                        fontSize: AppFont.caption * s,
                        fontWeight: FontWeight.bold,
                        color: AppColors.muted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      card.back,
                      style: TextStyle(
                        fontSize: AppFont.body * s,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final hasAccepted = _acceptedCount > 0;

    return SafeArea(
      child: AppContentFrame(
        shrinkHeight: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: AppButton(
            label: hasAccepted
                ? 'Simpan $_acceptedCount Kartu ke Set'
                : 'Pilih minimal 1 kartu',
            tone: AppButtonTone.primary,
            size: AppButtonSize.large,
            expand: true,
            isLoading: _isSaving,
            onPressed: hasAccepted ? _saveAcceptedCards : null,
          ),
        ),
      ),
    );
  }
}