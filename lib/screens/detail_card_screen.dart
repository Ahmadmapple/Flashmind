import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../repositories/flash_mind_repository.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_scale.dart';
import 'edit_card_screen.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_top_bar.dart';

import '../widgets/confirm_delete_dialog.dart';
import '../widgets/app_button.dart';

class DetailCardScreen extends StatefulWidget {
  const DetailCardScreen({super.key, required this.setId, required this.cardId});

  final String setId;
  final String cardId;

  @override
  State<DetailCardScreen> createState() => _DetailCardScreenState();
}

class _DetailCardScreenState extends State<DetailCardScreen> {
  final FlashMindRepository _repository = FlashMindRepository.instance;

  bool _isBackSide = false;
  bool _isDeleting = false;

  void _goBack() {
    if (_isDeleting) return;
    Navigator.of(context).pop();
  }

  void _toggleCardSide() {
    if (_isDeleting) return;
    setState(() {
      _isBackSide = !_isBackSide;
    });
  }

  Future<void> _confirmDelete(Flashcard card) async {
    if (_isDeleting) return;

    final bool? confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Hapus Kartu',
      message: 'Kartu ini akan dihapus dari set dan tidak dapat dikembalikan.',
      confirmLabel: 'Hapus',
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    final deleted = await _repository.deleteFlashcard(card.id);

    if (!mounted) return;

    if (!deleted) {
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kartu tidak ditemukan.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _openEditCard(Flashcard card) async {
    if (_isDeleting) return;

    final result = await Navigator.of(context).push<EditCardResult>(
      MaterialPageRoute<EditCardResult>(
        builder: (_) => EditCardScreen(setId: widget.setId, card: card),
      ),
    );

    if (!mounted) return;

    if (result == EditCardResult.deleted) {
      Navigator.of(context).pop(true);
      return;
    }

    if (result == EditCardResult.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kartu berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final extraBottomPadding = (keyboardInset - AppNavStyle.barHeight)
        .clamp(0.0, double.infinity)
        .toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppTopBar(
        title: 'Detail Kartu',
        onBack: _isDeleting ? null : _goBack,
      ),
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _repository,
          builder: (context, _) {
            final set = _repository.getSetById(widget.setId);
            final card = set?.cards.cast<Flashcard?>().firstWhere(
              (item) => item?.id == widget.cardId,
              orElse: () => null,
            );

            if (card == null) {
              return const Center(child: Text('Kartu tidak ditemukan.'));
            }

            return AppContentFrame(child: _buildContent(card, extraBottomPadding));
          },
        ),
      ),
      floatingActionButton: AppHomeFab(
        isActive: true,
        compact: true,
        onPressed: _isDeleting ? null : _goBack,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        selectedTab: AppNavTab.berkas,
        compact: true,
        elevation: 2,
        onBerkasTap: _isDeleting ? null : _goBack,
        onStatistikTap: null,
      ),
    );
  }

  Widget _buildContent(Flashcard card, double extraBottomPadding) {
    final double s = context.scale;
    final String text = _isBackSide ? card.backText : card.frontText;
    final String sideLabel = _isBackSide ? 'Sisi Belakang' : 'Sisi Depan';
    final String flipTooltip = _isBackSide
        ? 'Tampilkan sisi depan'
        : 'Balikkan kartu';

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 50 + extraBottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  sideLabel,
                  style: TextStyle(
                    fontSize: AppFont.title * s,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: AppColors.primary,
                  ),
                ),
              ),
              Tooltip(
                message: flipTooltip,
                child: TextButton.icon(
                  onPressed: _toggleCardSide,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 6 * s),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(Icons.swap_horiz, size: 25 * s),
                  label: Text(
                    'Balikkan Kartu',
                    style: TextStyle(fontSize: AppFont.bodyLarge * s, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.borderStrong, width: 1),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 13),
                  child: Text(
                    text,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: AppFont.bodyLarge * s,
                      color: AppColors.primary,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  label: 'Hapus Kartu',
                  tone: AppButtonTone.danger,
                  isLoading: _isDeleting,
                  onPressed: _isDeleting ? null : () => _confirmDelete(card),
                ),
                AppButton(
                  label: 'Edit Kartu',
                  onPressed: _isDeleting ? null : () => _openEditCard(card),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}