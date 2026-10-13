import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../repositories/flash_mind_repository.dart';
import 'edit_card_page.dart';
import '../widgets/app_bottom_nav.dart';

class DetailCardPage extends StatefulWidget {
  const DetailCardPage({super.key, required this.setId, required this.cardId});

  final String setId;
  final String cardId;

  @override
  State<DetailCardPage> createState() => _DetailCardPageState();
}

class _DetailCardPageState extends State<DetailCardPage> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _dangerColor = Color(0xFFEF5350);

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

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Kartu'),
          content: const Text('Apakah Anda yakin ingin menghapus kartu ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: _dangerColor),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
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
        builder: (_) => EditCardPage(setId: widget.setId, card: card),
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
      backgroundColor: _backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
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

            return _buildContent(card, extraBottomPadding);
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _isDeleting ? null : _goBack,
        icon: const Icon(Icons.arrow_back, size: 28),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: const Text(
        'Detail Kartu',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: _primaryColor,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent(Flashcard card, double extraBottomPadding) {
    final String text = _isBackSide ? card.backText : card.frontText;
    final String sideLabel = _isBackSide ? 'Sisi Belakang' : 'Sisi Depan';
    final String flipTooltip = _isBackSide
        ? 'Tampilkan sisi depan'
        : 'Balikkan kartu';

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + extraBottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  sideLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: _primaryColor,
                  ),
                ),
              ),
              Tooltip(
                message: flipTooltip,
                child: TextButton.icon(
                  onPressed: _toggleCardSide,
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.swap_horiz, size: 23),
                  label: const Text(
                    'Balikkan Kartu',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 420,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFB8B5AF), width: 1),
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: _primaryColor,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 35),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDeleteButton(card), _buildEditButton(card)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(Flashcard card) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: _isDeleting ? null : () => _confirmDelete(card),
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_dangerColor),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(95, 32)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        child: _isDeleting
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white,
                ),
              )
            : const Text('Hapus Kartu'),
      ),
    );
  }

  Widget _buildEditButton(Flashcard card) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: _isDeleting ? null : () => _openEditCard(card),
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_accentColor),
          foregroundColor: const WidgetStatePropertyAll(_primaryColor),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 14),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(95, 32)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        child: const Text('Edit Kartu'),
      ),
    );
  }
}
