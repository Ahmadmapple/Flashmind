import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import '../repositories/flash_mind_repository.dart';
import 'add_card_page.dart';
import 'edit_set_page.dart';
import 'detail_card_page.dart';
import 'study_session_start_page.dart';

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

  static const TextStyle _cardBodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _primaryColor,
    height: 1.25,
  );

  static const String _ellipsis = ' ...';

  static const double _cardHeight = 136;
  static const double _bodyToActionsGap = 12;

  final FlashMindRepository _repository = FlashMindRepository.instance;

  bool _isDeleting = false;
  bool _notificationShown = false;

  final Set<String> _backVisibleCardIds = <String>{};

  static String _truncateToFitWords(
    String text,
    TextStyle style,
    double maxWidth,
    TextScaler textScaler, {
    int maxLines = 1,
  }) {
    bool fits(String value) {
      final painter = TextPainter(
        text: TextSpan(text: value, style: style),
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        textScaler: textScaler,
      )..layout(maxWidth: maxWidth);
      final bool exceeded = painter.didExceedMaxLines;
      painter.dispose();
      return !exceeded;
    }

    if (fits(text)) return text;

    final words = text.trim().split(RegExp(r'\s+'));
    for (int count = words.length - 1; count >= 1; count--) {
      final candidate = '${words.sublist(0, count).join(' ')}$_ellipsis';
      if (fits(candidate)) return candidate;
    }

    return text;
  }

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

  Future<void> _openAddCard() async {
    if (_isDeleting) return;

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => AddCardPage(setId: widget.setId)),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kartu berhasil dibuat.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
        ),
      );
    }
  }

  Future<void> _openDetailCard(Flashcard card) async {
    if (_isDeleting) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => DetailCardPage(setId: card.setId, cardId: card.id),
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
                  if (isEmpty)
                    _buildEmptyState()
                  else ...[
                    _buildCardList(set.cards),
                    const SizedBox(height: 18),
                    Center(child: _buildAddCardButton()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(List<Flashcard> cards) {
    return Column(
      children: [
        for (int index = 0; index < cards.length; index++) ...[
          _buildFlashcardCard(cards[index]),
          if (index < cards.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildFlashcardCard(Flashcard card) {
    final bool isBackVisible = _backVisibleCardIds.contains(card.id);
    final String text = isBackVisible ? card.backText : card.frontText;
    final String sideLabel = isBackVisible ? 'Sisi Belakang' : 'Sisi Depan';
    final String flipTooltip = isBackVisible
        ? 'Tampilkan sisi depan'
        : 'Balikkan kartu';

    final TextStyle effectiveBodyStyle = DefaultTextStyle.of(context).style
        .merge(_cardBodyStyle);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);

    return Container(
      width: double.infinity,
      height: _cardHeight,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8E4DB), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sideLabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: Color(0xFF9A9894),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double lineHeight =
                    effectiveBodyStyle.fontSize! *
                    (effectiveBodyStyle.height ?? 1.0);

                final int availableLines = (constraints.maxHeight / lineHeight)
                    .floor()
                    .clamp(1, 10);

                final String displayText = _truncateToFitWords(
                  text,
                  effectiveBodyStyle,
                  constraints.maxWidth,
                  textScaler,
                  maxLines: availableLines,
                );

                return Text(
                  displayText,
                  maxLines: availableLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                  style: _cardBodyStyle,
                );
              },
            ),
          ),
          const SizedBox(height: _bodyToActionsGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Tooltip(
                message: flipTooltip,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (isBackVisible) {
                        _backVisibleCardIds.remove(card.id);
                      } else {
                        _backVisibleCardIds.add(card.id);
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF9A9894),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.swap_horiz, size: 23),
                  label: const Text(
                    'Balikkan Kartu',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _openDetailCard(card),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD97745),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lihat Detail →',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton() {
    return Material(
      color: _accentColor,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _isDeleting ? null : _openAddCard,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.add, color: _primaryColor, size: 28),
        ),
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

  Future<void> _openStudySessionStart() async {
    if (_isDeleting) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudySessionStartPage(setId: widget.setId),
      ),
    );
  }

  Widget _buildStudyButton({required bool enabled}) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: enabled && !_isDeleting ? _openStudySessionStart : null,
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
          _buildAddCardButton(),
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
