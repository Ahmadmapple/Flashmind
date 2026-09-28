import 'package:flutter/material.dart';

import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import 'add_card_page.dart';
import 'edit_set_page.dart';

class DetailSetPage extends StatefulWidget {
  const DetailSetPage({
    super.key,
    required this.setId,
    this.showCreatedNotification = false,
  });

  final String setId;
  final bool showCreatedNotification;

  @override
  State<DetailSetPage> createState() => _DetailSetPageState();
}

class _DetailSetPageState extends State<DetailSetPage> {
  static const Color _primaryColor = Color(0xFF192A3A);
  static const Color _accentColor = Color(0xFFF3C279);
  static const Color _headerColor = Color(0xFFFFE5B4);
  static const Color _backgroundColor = Color(0xFFFBF9F6);
  static const Color _dangerColor = Color(0xFFEF5350);

  final FlashMindRepository _repository = FlashMindRepository.instance;

  bool _isDeleting = false;
  bool _notificationShown = false;

  @override
  void initState() {
    super.initState();

    if (widget.showCreatedNotification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _notificationShown) return;
        _notificationShown = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Set berhasil dibuat.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          ),
        );
      });
    }
  }

  Future<void> _confirmDelete(FlashcardSet set) async {
    if (_isDeleting) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Set'),
          content: Text(
            'Apakah Anda yakin ingin menghapus set "${set.title}"?',
          ),
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

    await _repository.deleteSet(set.id);

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  Future<void> _openEditSet(FlashcardSet set) async {
    if (_isDeleting) return;

    final edited = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => EditSetPage(set: set)),
    );

    if (edited == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      );
    }
  }

  void _showNextStageMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan dikembangkan pada tahap berikutnya.'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _repository,
        builder: (context, _) {
          final set = _repository.getSetById(widget.setId);

          if (set == null) {
            return const Center(child: Text('Set tidak ditemukan.'));
          }

          return _buildContent(set);
        },
      ),
      floatingActionButton: _buildHomeButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _headerColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, size: 28),
        color: _primaryColor,
        tooltip: 'Kembali',
      ),
      title: const Text(
        'Detail Set',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          color: _primaryColor,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
          child: TextButton(
            onPressed: _isDeleting
                ? null
                : () {
                    final set = _repository.getSetById(widget.setId);
                    if (set != null) {
                      _openEditSet(set);
                    }
                  },
            style: TextButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(95, 34),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Edit Set'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(FlashcardSet set) {
    final bool isEmpty = set.cardCount == 0;

    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    set.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    set.description.isEmpty
                        ? 'Tidak ada deskripsi set.'
                        : set.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDeleteButton(set),
                      _buildStudyButton(enabled: !isEmpty),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (isEmpty) _buildEmptyState(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(FlashcardSet set) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: _isDeleting ? null : () => _confirmDelete(set),
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(_dangerColor),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
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
            : const Text('Hapus Set'),
      ),
    );
  }

  Widget _buildStudyButton({required bool enabled}) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: enabled && !_isDeleting
            ? () => _showNextStageMessage('Mulai Sesi Belajar')
            : null,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled || states.contains(WidgetState.disabled)) {
              return Colors.grey.shade300;
            }
            return _accentColor;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled || states.contains(WidgetState.disabled)) {
              return Colors.grey.shade500;
            }
            return _primaryColor;
          }),
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
        child: const Text('Mulai Sesi Belajar'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Belum ada kartu dalam set ini.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const Spacer(),
          const Text(
            'Silakan tekan tombol berikut untuk menambahkan kartu ke dalam set.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9A9894),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: _accentColor,
            elevation: 3,
            shadowColor: Colors.black26,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _isDeleting
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AddCardPage(setId: widget.setId),
                        ),
                      );
                    },
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.add, color: _primaryColor, size: 28),
              ),
            ),
          ),
        ],
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
              onPressed: _isDeleting
                  ? null
                  : () =>
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst),
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
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomNavItem(
            icon: Icons.article_outlined,
            label: 'Berkas',
            onTap: _isDeleting ? null : () => Navigator.of(context).pop(),
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
        height: 65,
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
