import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../repositories/flash_mind_repository.dart';
import 'edit_card_page.dart';

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

  static const double _bottomBarHeight = 65;

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
    final extraBottomPadding = (keyboardInset - _bottomBarHeight)
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
      floatingActionButton: _buildHomeButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
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

  Widget _buildHomeButton() {
    return Transform.translate(
      offset: const Offset(0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: FloatingActionButton(
              onPressed: _isDeleting ? null : _goBack,
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              child: const Icon(Icons.home_rounded, size: 30),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Beranda',
            style: TextStyle(
              fontSize: 9,
              color: _primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 2,
      height: _bottomBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomNavItem(
            icon: Icons.article_outlined,
            label: 'Berkas',
            onTap: _isDeleting ? null : _goBack,
          ),
          const SizedBox(width: 72),
          _buildBottomNavItem(
            icon: Icons.timer_outlined,
            label: 'Statistik',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final color = label == 'Berkas' ? _primaryColor : Colors.grey.shade400;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: _bottomBarHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
