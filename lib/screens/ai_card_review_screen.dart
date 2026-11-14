import 'package:flutter/material.dart';

import '../repositories/flash_mind_repository.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';
import '../widgets/app_button.dart';
import '../widgets/app_top_bar.dart';

/// Model sementara untuk kartu yang dibuat AI dari PDF.
class _AiCard {
  _AiCard({required this.front, required this.back});

  final String front;
  final String back;
  bool accepted = true;
}

/// Halaman untuk meninjau kartu yang dibuat AI dari dokumen PDF.
/// Pengguna dapat menerima atau menolak tiap kartu sebelum disimpan ke set.
class AiCardReviewScreen extends StatefulWidget {
  const AiCardReviewScreen({
    super.key,
    required this.setId,
    required this.fileName,
  });

  final String setId;
  final String fileName;

  @override
  State<AiCardReviewScreen> createState() => _AiCardReviewScreenState();
}

class _AiCardReviewScreenState extends State<AiCardReviewScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  // Kartu dummy hasil "AI" — dalam produksi ini diganti dengan respons API
  final List<_AiCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _simulateAiGeneration();
  }

  /// Simulasi delay pemrosesan AI lalu isi kartu dummy.
  Future<void> _simulateAiGeneration() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _cards.addAll([
        _AiCard(
          front: 'Apa fungsi utama membran sel?',
          back:
              'Membran sel mengatur apa yang masuk dan keluar dari sel, menjaga lingkungan internal sel tetap stabil.',
        ),
        _AiCard(
          front: 'Apa itu mitokondria?',
          back:
              'Mitokondria adalah organel penghasil energi sel dalam bentuk ATP melalui proses respirasi seluler.',
        ),
        _AiCard(
          front: 'Jelaskan proses fotosintesis secara singkat.',
          back:
              'Fotosintesis adalah proses tumbuhan mengubah cahaya matahari, air, dan CO₂ menjadi glukosa dan oksigen.',
        ),
        _AiCard(
          front: 'Apa perbedaan sel prokariotik dan eukariotik?',
          back:
              'Sel prokariotik tidak memiliki nukleus bermembran, sedangkan sel eukariotik memiliki nukleus yang terlindungi membran inti.',
        ),
        _AiCard(
          front: 'Apa fungsi ribosom dalam sel?',
          back:
              'Ribosom berperan dalam sintesis protein dengan menerjemahkan informasi genetik dari mRNA menjadi rantai asam amino.',
        ),
      ]);
      _isLoading = false;
    });
  }

  int get _acceptedCount => _cards.where((c) => c.accepted).length;

  Future<void> _saveAcceptedCards() async {
    final accepted = _cards.where((c) => c.accepted).toList();
    if (accepted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu kartu untuk disimpan.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = FlashMindRepository.instance;
    for (final card in accepted) {
      await repo.addFlashcard(
        setId: widget.setId,
        frontText: card.front,
        backText: card.back,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${accepted.length} kartu berhasil ditambahkan ke set.',
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ),
    );

    // Kembali ke detail set (2 halaman: review + pilih PDF)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'Tinjau Kartu AI',
        centerTitle: false,
        onBack: _isSaving ? null : () => Navigator.of(context).pop(),
      ),
      body: _isLoading ? _buildLoadingState() : _buildReviewBody(),
      bottomNavigationBar: _isLoading ? null : _buildBottomBar(),
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

  // ── Body ─────────────────────────────────────────────────────────────────
  Widget _buildReviewBody() {
    final double s = context.scale;
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
                    Icon(Icons.picture_as_pdf, color: AppColors.link, size: 18 * s),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.fileName,
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
                  'Centang kartu yang ingin disimpan ke set.',
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
                  onPressed: () {
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
        onTap: () {
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